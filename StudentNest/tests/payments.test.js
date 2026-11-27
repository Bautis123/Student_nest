const { test } = require('node:test');
const assert = require('node:assert/strict');
const crypto = require('crypto');

// Database double: records SQL, returns queued results. Never touches real data.
const dbPath = require.resolve('../src/config/db');
const queries = [];
let results = [];
require.cache[dbPath] = { id: dbPath, filename: dbPath, loaded: true, exports: {
  query: async (sql, params) => { queries.push({ sql, params }); return results.shift() || { rows: [] }; },
} };

const { setPaymentProvider } = require('../src/services/payments');
const service = require('../src/services/paymentService');
const { createLencoProvider } = require('../src/services/payments/lencoProvider');
const { createMockProvider } = require('../src/services/payments/mockProvider');
const { normalizePhone, detectOperator } = require('../src/services/payments/mobileMoney');

const PROPERTY = '11111111-1111-4111-8111-111111111111';
const PAYMENT = '22222222-2222-4222-8222-222222222222';
function reset() { queries.length = 0; results = []; }
function fakeProvider(result = { status: 'pending', providerReference: 'L-1' }) {
  const calls = [];
  return { calls, provider: { name: 'fake', startCollection: async (args) => { calls.push(args); return result; }, getCollection: async () => result, parseWebhook: () => null } };
}
const pendingPayment = (extra = {}) => ({ id: PAYMENT, property_id: PROPERTY, amount: '300.00', status: 'pending', provider: 'fake', payment_reference: 'SN-x', ...extra });

test('phone numbers are normalised and operators detected', () => {
  assert.equal(normalizePhone('+260 97 123 4567'), '0971234567');
  assert.equal(normalizePhone('260961234567'), '0961234567');
  assert.equal(normalizePhone('12345'), null);
  assert.equal(detectOperator('0961234567'), 'mtn');
  assert.equal(detectOperator('0771234567'), 'airtel');
  assert.equal(detectOperator('0951234567'), 'zamtel');
});

test('payments are refused while no provider is configured', async () => {
  reset(); setPaymentProvider(null);
  await assert.rejects(
    service.startListingPayment({ landlordId: 'l', propertyId: PROPERTY, planId: 'basic', phone: '0971234567' }),
    { status: 503 }
  );
  assert.equal(queries.length, 0);
});

test('unknown plans and bad numbers are rejected before any database work', async () => {
  reset(); setPaymentProvider(fakeProvider().provider);
  await assert.rejects(service.startListingPayment({ landlordId: 'l', propertyId: PROPERTY, planId: 'gold', phone: '0971234567' }), { status: 400 });
  await assert.rejects(service.startListingPayment({ landlordId: 'l', propertyId: PROPERTY, planId: 'basic', phone: '123' }), { status: 400 });
  assert.equal(queries.length, 0);
});

test('only the owner can pay, and only for an approved listing', async () => {
  reset(); setPaymentProvider(fakeProvider().provider);
  results = [{ rows: [] }];
  await assert.rejects(service.startListingPayment({ landlordId: 'l', propertyId: PROPERTY, planId: 'basic', phone: '0971234567' }), { status: 404 });
  assert.match(queries[0].sql, /landlord_id = \$2/);

  reset(); results = [{ rows: [{ id: PROPERTY, is_approved: false }] }];
  await assert.rejects(service.startListingPayment({ landlordId: 'l', propertyId: PROPERTY, planId: 'basic', phone: '0971234567' }), { status: 400 });
});

test('a second payment is blocked while one awaits phone approval', async () => {
  reset(); setPaymentProvider(fakeProvider().provider);
  results = [{ rows: [{ id: PROPERTY, is_approved: true }] }, { rows: [{ id: PAYMENT }] }];
  await assert.rejects(
    service.startListingPayment({ landlordId: 'l', propertyId: PROPERTY, planId: 'basic', phone: '0971234567' }),
    { status: 409, paymentId: PAYMENT }
  );
});

test('the amount charged comes from the plan, never the client', async () => {
  reset(); const fake = fakeProvider(); setPaymentProvider(fake.provider);
  results = [{ rows: [{ id: PROPERTY, is_approved: true }] }, { rows: [] }, { rows: [pendingPayment({ amount: '750.00' })] }, { rows: [pendingPayment({ amount: '750.00', provider_reference: 'L-1' })] }];
  const payment = await service.startListingPayment({ landlordId: 'l', propertyId: PROPERTY, planId: 'premium', phone: '+260961111111', amount: 1 });
  assert.equal(fake.calls[0].amount, 750);
  assert.equal(fake.calls[0].operator, 'mtn');
  assert.equal(fake.calls[0].phone, '0961111111');
  assert.match(fake.calls[0].reference, /^SN-[0-9a-f-]{36}$/);
  assert.equal(payment.status, 'pending');
  assert.equal(payment.landlord_id, undefined, 'internal fields are not exposed');
});

test('a network error marks the payment failed and reports 502', async () => {
  reset(); setPaymentProvider({ name: 'fake', startCollection: async () => { throw new Error('ECONNRESET'); } });
  results = [{ rows: [{ id: PROPERTY, is_approved: true }] }, { rows: [] }, { rows: [pendingPayment()] }];
  await assert.rejects(service.startListingPayment({ landlordId: 'l', propertyId: PROPERTY, planId: 'basic', phone: '0971234567' }), { status: 502 });
  assert.match(queries.at(-1).sql, /SET status = 'failed'/);
});

test('a successful payment activates and extends the listing atomically', async () => {
  reset(); results = [{ rows: [pendingPayment({ status: 'confirmed' })] }];
  const payment = await service.applyProviderResult(pendingPayment(), { status: 'successful', amount: 300, providerReference: 'L-9' });
  assert.equal(payment.status, 'confirmed');
  assert.equal(queries.length, 1);
  assert.match(queries[0].sql, /status = 'pending'/);
  assert.match(queries[0].sql, /GREATEST\(COALESCE\(p\.listing_expires_at, NOW\(\)\), NOW\(\)\)/);
  assert.match(queries[0].sql, /SET is_active = true/);
});

test('a success for the wrong amount is rejected', async () => {
  reset(); results = [{ rows: [pendingPayment({ status: 'failed' })] }];
  await service.applyProviderResult(pendingPayment(), { status: 'successful', amount: 3, providerReference: 'L-9' });
  assert.match(queries[0].sql, /SET status = 'failed'/);
  assert.match(queries[0].params[1], /Amount mismatch/);
});

test('settled payments are never re-applied', async () => {
  reset();
  const payment = await service.applyProviderResult(pendingPayment({ status: 'confirmed' }), { status: 'successful', amount: 300 });
  assert.equal(payment.status, 'confirmed');
  assert.equal(queries.length, 0);
});

test('landlords can only read their own payments', async () => {
  reset(); setPaymentProvider(fakeProvider().provider); results = [{ rows: [] }];
  await assert.rejects(service.getLandlordPayment({ landlordId: 'l', paymentId: PAYMENT }), { status: 404 });
  assert.match(queries[0].sql, /landlord_id = \$2/);
  await assert.rejects(service.getLandlordPayment({ landlordId: 'l', paymentId: 'not-a-uuid' }), { status: 404 });
});

test('Lenco webhooks are accepted only with a valid signature over the raw body', () => {
  const token = 'test-token';
  const provider = createLencoProvider({ apiToken: token, fetchImpl: async () => { throw new Error('no network'); } });
  const body = Buffer.from(JSON.stringify({ event: 'collection.successful', data: { reference: 'SN-1', lencoReference: '240', status: 'successful', amount: '300.00' } }));
  const key = crypto.createHash('sha256').update(token).digest('hex');
  const signature = crypto.createHmac('sha512', key).update(body).digest('hex');

  const parsed = provider.parseWebhook(body, signature);
  assert.equal(parsed.reference, 'SN-1');
  assert.equal(parsed.result.status, 'successful');
  assert.equal(parsed.result.amount, 300);
  assert.equal(provider.parseWebhook(body, signature.replace(/.$/, (c) => (c === '0' ? '1' : '0'))), null);
  assert.equal(provider.parseWebhook(Buffer.from(body.toString().replace('300.00', '1.00')), signature), null);
  assert.equal(provider.parseWebhook(body, undefined), null);
});

test('Lenco collection requests use the documented endpoint and fields', async () => {
  const calls = [];
  const provider = createLencoProvider({ apiToken: 't', baseUrl: 'https://lenco.test/v2/', fetchImpl: async (url, init) => {
    calls.push({ url, init });
    return { ok: true, status: 200, json: async () => ({ status: true, data: { id: 'uuid', lencoReference: '240', status: 'pay-offline', amount: '300.00' } }) };
  } });
  const result = await provider.startCollection({ amount: 300, reference: 'SN-1', phone: '0971111111', operator: 'airtel' });
  assert.equal(calls[0].url, 'https://lenco.test/v2/collections/mobile-money');
  assert.equal(calls[0].init.headers.Authorization, 'Bearer t');
  assert.deepEqual(JSON.parse(calls[0].init.body), { amount: 300, reference: 'SN-1', phone: '0971111111', operator: 'airtel', country: 'zm', bearer: 'merchant' });
  assert.equal(result.status, 'pending', 'pay-offline means waiting for the phone prompt');
  assert.equal(result.providerReference, '240');
});

test('the mock provider approves test numbers after a short delay', async () => {
  let clock = 0;
  const mock = createMockProvider({ now: () => clock, delayMs: 1000 });
  await mock.startCollection({ amount: 300, reference: 'ok', phone: '0961111111' });
  await mock.startCollection({ amount: 300, reference: 'bad', phone: '0962222222' });
  assert.equal((await mock.getCollection('ok')).status, 'pending');
  clock = 1000;
  assert.equal((await mock.getCollection('ok')).status, 'successful');
  assert.equal((await mock.getCollection('bad')).status, 'failed');
});

const { test } = require('node:test');
const assert = require('node:assert/strict');

// Database double: records SQL, returns queued results. Never touches real data.
const dbPath = require.resolve('../src/config/db');
const queries = [];
let results = [];
require.cache[dbPath] = { id: dbPath, filename: dbPath, loaded: true, exports: {
  query: async (sql, params) => { queries.push({ sql, params }); return results.shift() || { rows: [] }; },
} };
const viewings = require('../src/services/viewingService');
const { createMetaProvider, createLogProvider, setWhatsAppProvider, toInternational } = require('../src/services/notifications/whatsapp');

const HOME = '88888888-8888-4888-8888-888888888888';
const REQUEST = '99999999-9999-4999-8999-999999999999';
const today = viewings.lusakaToday();
const inDays = (n) => { const d = new Date(`${today}T12:00:00Z`); d.setUTCDate(d.getUTCDate() + n); return d.toISOString().slice(0, 10); };
const valid = { property_id: HOME, student_name: 'Mwila', student_phone: '+260 97 123 4567', preferred_date: inDays(3), preferred_time: 'afternoon', message: 'Is the twin room still free?' };
const home = { id: HOME, title: 'Garden View Lodge', landlord_name: 'Jane Banda', landlord_phone: '0961234567' };
function reset() { queries.length = 0; results = []; }

test('requests are validated: name, number, a day within 60 days, time of day', () => {
  assert.equal(viewings.validateRequest(valid).student_phone, '0971234567');
  for (const change of [{ student_name: 'M' }, { student_phone: '123' }, { preferred_date: inDays(-1) }, { preferred_date: inDays(61) }, { preferred_date: 'soon' }, { preferred_time: 'midnight' }, { message: 'x'.repeat(501) }]) {
    assert.throws(() => viewings.validateRequest({ ...valid, ...change }), { status: 400 }, JSON.stringify(change));
  }
  assert.doesNotThrow(() => viewings.validateRequest({ ...valid, preferred_date: today }));
});

test('only publicly visible homes can be booked', async () => {
  reset(); setWhatsAppProvider(null); results = [{ rows: [] }];
  await assert.rejects(viewings.createRequest(HOME, valid), { status: 404 });
  assert.match(queries[0].sql, /p\.flagged_at IS NULL/);
  assert.match(queries[0].sql, /p\.is_approved = true AND p\.is_active = true/);
});

test('booking returns a pre-written WhatsApp message to the landlord', async () => {
  reset(); setWhatsAppProvider(null);
  results = [{ rows: [home] }, { rows: [{ count: 0 }] }, { rows: [{ id: REQUEST, status: 'pending' }] }];
  const result = await viewings.createRequest(HOME, valid);
  assert.equal(result.request.status, 'pending');
  assert.ok(result.whatsapp_link.startsWith('https://wa.me/260961234567?text='));
  const text = decodeURIComponent(result.whatsapp_link.split('text=')[1]);
  assert.match(text, /I'm Mwila/);
  assert.match(text, /"Garden View Lodge"/);
  assert.match(text, /afternoon \(12–4pm\)/);
  assert.match(text, /Is the twin room still free\?/);
  assert.ok(!queries.some(({ sql }) => sql.includes('notify_status')), 'no alert attempted when alerts are off');
});

test('a student can have only a few pending requests at once', async () => {
  reset(); setWhatsAppProvider(null); results = [{ rows: [home] }, { rows: [{ count: 5 }] }];
  await assert.rejects(viewings.createRequest(HOME, valid), { status: 409 });
});

test('a failed WhatsApp alert is recorded but never fails the booking', async () => {
  reset();
  setWhatsAppProvider({ name: 'fake', sendViewingAlert: async () => { throw new Error('template not approved'); } });
  results = [{ rows: [home] }, { rows: [{ count: 0 }] }, { rows: [{ id: REQUEST, status: 'pending' }] }];
  const result = await viewings.createRequest(HOME, valid);
  assert.equal(result.request.id, REQUEST);
  const update = queries.find(({ sql }) => sql.includes('SET notify_status'));
  assert.deepEqual(update.params, [REQUEST, 'failed', 'template not approved']);
  setWhatsAppProvider(null);
});

test('landlords can only answer requests for their own homes, with a ready reply', async () => {
  reset();
  await assert.rejects(viewings.respond('landlord-1', REQUEST, 'maybe'), { status: 400 });
  results = [{ rows: [] }];
  await assert.rejects(viewings.respond('landlord-1', REQUEST, 'confirmed'), { status: 404 });
  assert.match(queries[0].sql, /p\.landlord_id = \$2/);

  reset();
  results = [{ rows: [{ id: REQUEST, property_title: 'Garden View Lodge', student_name: 'Mwila', student_phone: '0971234567', preferred_date: inDays(3), preferred_time: 'morning', status: 'confirmed', landlord_note: 'Ask for Jane at the gate.' }] }];
  const answered = await viewings.respond('landlord-1', REQUEST, 'confirmed', ' Ask for Jane at the gate. ');
  assert.equal(queries[0].params[3], 'Ask for Jane at the gate.');
  const text = decodeURIComponent(answered.reply_link.split('text=')[1]);
  assert.ok(answered.reply_link.startsWith('https://wa.me/260971234567?text='));
  assert.match(text, /is confirmed for/);
  assert.match(text, /Ask for Jane at the gate\./);
});

test('Meta WhatsApp alerts use an approved template with four body parameters', async () => {
  const calls = [];
  const meta = createMetaProvider({ token: 't0k', phoneNumberId: '12345', template: 'viewing_request', fetchImpl: async (url, init) => { calls.push({ url, init }); return { ok: true, json: async () => ({}) }; } });
  await meta.sendViewingAlert({ to: '0961234567', studentName: 'Mwila', propertyTitle: 'Garden View Lodge', when: 'Sat 6 Dec, morning', link: 'https://example.test/landlord' });
  assert.equal(calls[0].url, 'https://graph.facebook.com/v21.0/12345/messages');
  assert.equal(calls[0].init.headers.Authorization, 'Bearer t0k');
  const body = JSON.parse(calls[0].init.body);
  assert.equal(body.to, '260961234567');
  assert.equal(body.type, 'template');
  assert.equal(body.template.name, 'viewing_request');
  assert.deepEqual(body.template.components[0].parameters.map((p) => p.text), ['Mwila', 'Garden View Lodge', 'Sat 6 Dec, morning', 'https://example.test/landlord']);

  const failing = createMetaProvider({ token: 't', phoneNumberId: '1', fetchImpl: async () => ({ ok: false, status: 400, json: async () => ({ error: { message: 'Template name does not exist' } }) }) });
  await assert.rejects(failing.sendViewingAlert({ to: '0961234567', studentName: 'a', propertyTitle: 'b', when: 'c', link: 'd' }), /Template name does not exist/);
  assert.throws(() => createMetaProvider({ token: '', phoneNumberId: '' }), /required/);
});

test('demo mode logs the alert instead of sending it', async () => {
  const lines = [];
  await createLogProvider({ log: (line) => lines.push(line) }).sendViewingAlert({ to: '0961234567', studentName: 'Mwila', propertyTitle: 'Lodge', when: 'Sat', link: 'L' });
  assert.match(lines[0], /\[whatsapp demo\] to 260961234567: Mwila wants to view "Lodge"/);
  assert.equal(toInternational('0971234567'), '260971234567');
});

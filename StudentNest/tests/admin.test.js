const { test } = require('node:test');
const assert = require('node:assert/strict');

// Inject a database double so these checks never read or mutate real data.
const dbPath = require.resolve('../src/config/db');
const queries = [];
let results = [];
require.cache[dbPath] = { id: dbPath, filename: dbPath, loaded: true, exports: {
  query: async (sql, params) => { queries.push({ sql, params }); return results.shift() || { rows: [] }; },
} };
const admin = require('../src/controllers/admin');

function response() { return { statusCode: 200, status(code) { this.statusCode = code; return this; }, json(value) { this.body = value; return this; } }; }
function reset() { queries.length = 0; results = []; }
const request = (extra) => ({ user: { id: 'admin', role: 'admin', access_level: 'manager' }, ip: '127.0.0.1', get: () => 'test', ...extra });

test('password reset is limited to landlord accounts', async () => {
  reset(); results = [{ rows: [] }]; const res = response();
  await admin.resetLandlordPassword(request({ params: { id: 'owner-admin' }, body: { password: 'new-secret' } }), res);
  assert.equal(res.statusCode, 404);
  assert.match(queries[0].sql, /role = 'landlord'/);
});

test('password reset rejects a missing or short password before hashing', async () => {
  reset(); const res = response();
  await admin.resetLandlordPassword(request({ params: { id: 'landlord' }, body: {} }), res);
  assert.equal(res.statusCode, 400);
  assert.equal(queries.length, 0);
});

test('deleting an unknown landlord reports 404', async () => {
  reset(); results = [{ rows: [] }]; const res = response();
  await admin.deleteLandlord(request({ params: { id: 'missing' } }), res);
  assert.equal(res.statusCode, 404);
});

test('only owners can create admins, and input is validated', async () => {
  reset(); let res = response();
  await admin.createAdmin(request({ body: { full_name: 'A', phone: '1', password: 'secret1' } }), res);
  assert.equal(res.statusCode, 403);

  reset(); res = response();
  await admin.createAdmin(request({ user: { id: 'o', role: 'admin', access_level: 'owner' }, body: { phone: '1' } }), res);
  assert.equal(res.statusCode, 400);
  assert.equal(queries.length, 0);
});

test('recording a payment issues no schema changes', async () => {
  reset();
  results = [{ rows: [{ id: 'prop', landlord_id: 'landlord' }] }, { rows: [{ id: 'pay' }] }, { rows: [] }];
  const res = response();
  await admin.recordPayment(request({ body: { property_id: 'prop', amount: 500, payment_method: 'cash', duration_months: 6 } }), res);
  assert.equal(res.statusCode, 201);
  assert.ok(queries.every(({ sql }) => !/ALTER TABLE|information_schema/i.test(sql)));
  const insert = queries.find(({ sql }) => sql.includes('INSERT INTO payments'));
  assert.ok(insert.params.includes(6));
});

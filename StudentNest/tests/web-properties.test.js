const { test } = require('node:test');
const assert = require('node:assert/strict');
// Inject a database double so these checks never read or mutate production data.
const dbPath = require.resolve('../src/config/db');
const queries = [];
let results = [];
require.cache[dbPath] = { id: dbPath, filename: dbPath, loaded: true, exports: {
  query: async (sql, params) => { queries.push({ sql, params }); return results.shift() || { rows: [] }; },
} };
const controller = require('../src/controllers/properties');
const cloudinaryPath = require.resolve('../src/config/cloudinary');
require.cache[cloudinaryPath] = { id: cloudinaryPath, filename: cloudinaryPath, loaded: true, exports: {} };
const { setCoverPhoto } = require('../src/controllers/photos');
function response() { return { statusCode: 200, status(code) { this.statusCode = code; return this; }, json(value) { this.body = value; return this; } }; }
function reset() { queries.length = 0; results = []; }

test('private detail lookup is constrained to the authenticated owner', async () => {
  reset(); results = [{ rows: [] }]; const res = response();
  await controller.getMyPropertyById({ params: { id: 'someone-elses-property' }, user: { id: 'landlord' } }, res);
  assert.equal(res.statusCode, 404);
  assert.deepEqual(queries[0].params, ['someone-elses-property', 'landlord']);
  assert.match(queries[0].sql, /landlord_id = \$2/);
  assert.equal(queries.length, 1);
});
test('owner can load an unpublished listing with rooms and photos', async () => {
  reset(); results = [{ rows: [{ id: 'own', is_approved: false }] }, { rows: [{ id: 'room' }] }, { rows: [{ id: 'photo' }] }]; const res = response();
  await controller.getMyPropertyById({ params: { id: 'own' }, user: { id: 'landlord' } }, res);
  assert.equal(res.body.property.is_approved, false);
  assert.equal(res.body.property.rooms[0].id, 'room');
  assert.equal(res.body.property.photos[0].id, 'photo');
});
test('editing details cannot publish a listing and requires re-review', async () => {
  reset(); results = [{ rows: [{ id: 'own' }] }, { rows: [{ id: 'own' }] }]; const res = response();
  await controller.updateProperty({ params: { id: 'own' }, user: { id: 'landlord' }, body: { title: 'Home', address: 'Lusaka', is_active: true, is_approved: true } }, res);
  assert.match(queries[1].sql, /is_active = false/);
  assert.match(queries[1].sql, /is_approved = false/);
  assert.deepEqual(queries[1].params.slice(-2), ['own', 'landlord']);
});
test('invalid availability is rejected before touching the database', async () => {
  reset(); const res = response();
  await controller.updateRoomAvailability({ params: { room_id: 'room' }, user: { id: 'landlord' }, body: { available_rooms: -1 } }, res);
  assert.equal(res.statusCode, 400); assert.equal(queries.length, 0);
});
test('availability cannot exceed room capacity', async () => {
  reset(); results = [{ rows: [{ id: 'room', total_rooms: 2 }] }]; const res = response();
  await controller.updateRoomAvailability({ params: { room_id: 'room' }, user: { id: 'landlord' }, body: { available_rooms: 3 } }, res);
  assert.equal(res.statusCode, 400); assert.equal(queries.length, 1);
});
test('invalid room batches are rejected before creating any rooms', async () => {
  reset(); const res = response();
  await controller.addRooms({ params: { property_id: 'own' }, user: { id: 'landlord' }, body: { rooms: [{ room_type: 'Single', price_per_month: 500, total_rooms: 2, available_rooms: 3, students_per_room: 1 }] } }, res);
  assert.equal(res.statusCode, 400); assert.equal(queries.length, 0);
});
test('property creation rejects missing coordinates', async () => {
  reset(); const res = response();
  await controller.createProperty({ user: { id: 'landlord' }, body: { title: 'House', address: 'Lusaka', latitude: null, longitude: '' } }, res);
  assert.equal(res.statusCode, 400); assert.equal(queries.length, 0);
});

test('cover selection ignores a supplied foreign property ID', async () => {
  reset(); results = [{ rows: [{ id: 'photo', property_id: 'owned-property' }] }]; const res = response();
  await setCoverPhoto({ user: { id: 'landlord' }, params: { photo_id: 'photo' }, body: { property_id: 'someone-elses-property' } }, res);
  assert.equal(res.statusCode, 200);
  assert.deepEqual(queries[1].params, ['owned-property']);
});

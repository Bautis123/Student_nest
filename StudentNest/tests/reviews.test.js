const { test } = require('node:test');
const assert = require('node:assert/strict');

// Database double: records SQL, returns queued results. Never touches real data.
const dbPath = require.resolve('../src/config/db');
const queries = [];
let results = [];
let failNext = null;
require.cache[dbPath] = { id: dbPath, filename: dbPath, loaded: true, exports: {
  query: async (sql, params) => {
    queries.push({ sql, params });
    if (failNext) { const err = failNext; failNext = null; throw err; }
    return results.shift() || { rows: [] };
  },
} };
const reviews = require('../src/services/reviewService');

const HOME = '55555555-5555-4555-8555-555555555555';
const REVIEW = '66666666-6666-4666-8666-666666666666';
const valid = { property_id: HOME, reviewer_name: 'Mutale', phone: '0971234567', stay_from: '2025-01', stay_to: '2025-12',
  rating_overall: 4, rating_landlord: 5, rating_utilities: 3, rating_security: 4, rating_value: 4,
  comment: 'Water was reliable and the landlord fixed things quickly.' };
function reset() { queries.length = 0; results = []; failNext = null; }

test('valid reviews are normalised', () => {
  const input = reviews.validateReview(valid);
  assert.equal(input.stay_from, '2025-01-01');
  assert.equal(input.stay_to, '2025-12-01');
  assert.equal(input.rating_utilities, 3);
  assert.equal(reviews.validateReview({ ...valid, reviewer_name: '  ' }).reviewer_name, 'Student');
});

test('bad reviews are rejected with a readable message', () => {
  const future = new Date(Date.now() + 62 * 86400000).toISOString().slice(0, 7);
  const cases = [
    { rating_overall: 0 }, { rating_value: 6 }, { rating_security: 3.5 }, { rating_landlord: undefined },
    { comment: 'Too short' }, { comment: 'x'.repeat(1001) },
    { stay_from: '2025-13' }, { stay_from: future }, { stay_to: '2024-12' }, { stay_to: future },
    { phone: '123' },
  ];
  for (const change of cases) assert.throws(() => reviews.validateReview({ ...valid, ...change }), { status: 400 }, JSON.stringify(change));
});

test('reviews can only be left for approved homes and start pending', async () => {
  reset(); results = [{ rows: [] }];
  await assert.rejects(reviews.createReview(HOME, valid), { status: 404 });
  assert.match(queries[0].sql, /is_approved = true/);

  reset(); results = [{ rows: [{ id: HOME }] }, { rows: [{ id: REVIEW, status: 'pending' }] }];
  assert.deepEqual(await reviews.createReview(HOME, valid), { id: REVIEW, status: 'pending' });
});

test('one review per phone number per home', async () => {
  // The home exists; the INSERT then hits the unique (property, phone) index.
  reset(); results = [{ rows: [{ id: HOME }] }];
  failNext = null;
  const insertFails = Object.assign(new Error('duplicate key'), { code: '23505' });
  const query = require.cache[dbPath].exports.query;
  require.cache[dbPath].exports.query = async (sql, params) => {
    if (sql.includes('INSERT INTO reviews')) throw insertFails;
    return query(sql, params);
  };
  await assert.rejects(reviews.createReview(HOME, valid), { status: 409 });
  require.cache[dbPath].exports.query = query;
});

test('public listing never includes the reviewer phone and only approved reviews', async () => {
  let captured = [];
  require.cache[dbPath].exports.query = async (sql, params) => { captured.push({ sql, params }); return { rows: [{ count: 0 }] }; };
  await reviews.listForProperty(HOME);
  const list = captured.find(({ sql }) => sql.includes('ORDER BY approved_at'));
  assert.doesNotMatch(list.sql.split('FROM')[0], /phone|review_note/);
  assert.ok(captured.every(({ sql }) => sql.includes("status = 'approved'")));
});

test('only the owning landlord can reply, and only to approved reviews', async () => {
  let captured = [];
  require.cache[dbPath].exports.query = async (sql, params) => { captured.push({ sql, params }); return { rows: [] }; };
  await assert.rejects(reviews.replyAsLandlord(REVIEW, 'landlord-1', 'Thanks!'), { status: 404 });
  assert.match(captured[0].sql, /p\.landlord_id = \$2/);
  assert.match(captured[0].sql, /r\.status = 'approved'/);
  await assert.rejects(reviews.replyAsLandlord(REVIEW, 'landlord-1', 'x'.repeat(1001)), { status: 400 });
});

test('moderation validates the decision', async () => {
  await assert.rejects(reviews.moderateReview(REVIEW, 'maybe'), { status: 400 });
  await assert.rejects(reviews.moderateReview('nope', 'approved'), { status: 404 });
});

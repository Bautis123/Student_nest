const { test } = require('node:test');
const assert = require('node:assert/strict');

// Database double: records SQL, returns queued results. Never touches real data.
const dbPath = require.resolve('../src/config/db');
const queries = [];
let results = [];
let failOn = null;
require.cache[dbPath] = { id: dbPath, filename: dbPath, loaded: true, exports: {
  query: async (sql, params) => {
    queries.push({ sql, params });
    if (failOn && sql.includes(failOn.match)) throw failOn.error;
    return results.shift() || { rows: [] };
  },
} };
const reports = require('../src/services/listingReportService');

const HOME = '77777777-7777-4777-8777-777777777777';
function reset() { queries.length = 0; results = []; failOn = null; }

test('reports need a known reason, sensible details and an optional valid phone', async () => {
  reset();
  await assert.rejects(reports.reportListing(HOME, { reason: 'spam' }), { status: 400 });
  await assert.rejects(reports.reportListing(HOME, { reason: 'other', details: 'bad' }), { status: 400 });
  await assert.rejects(reports.reportListing(HOME, { reason: 'misleading', details: 'x'.repeat(1001) }), { status: 400 });
  await assert.rejects(reports.reportListing(HOME, { reason: 'upfront_payment', phone: '123' }), { status: 400 });
  await assert.rejects(reports.reportListing('not-a-uuid', { reason: 'fake_listing' }), { status: 404 });
  assert.equal(queries.length, 0);
});

test('a report is stored with a normalised phone and checks the auto-hide rule', async () => {
  reset(); results = [{ rows: [{ id: HOME }] }, { rows: [] }, { rows: [] }];
  const result = await reports.reportListing(HOME, { reason: 'upfront_payment', details: 'Asked for K500 deposit by mobile money before viewing', phone: '+260 97 123 4567' });
  assert.deepEqual(result, { hidden: false });
  const insert = queries.find(({ sql }) => sql.includes('INSERT INTO listing_reports'));
  assert.deepEqual(insert.params, [HOME, 'upfront_payment', 'Asked for K500 deposit by mobile money before viewing', '0971234567']);
  const flag = queries.find(({ sql }) => sql.includes('SET flagged_at = NOW()'));
  assert.match(flag.sql, /COUNT\(DISTINCT r\.reporter_phone\)/, 'only distinct phone numbers count towards hiding');
  assert.match(flag.sql, /r\.reporter_phone IS NOT NULL/, 'anonymous reports never hide a listing on their own');
  assert.deepEqual(flag.params, [HOME, reports.AUTO_HIDE_DISTINCT_REPORTERS, 30]);
});

test('the same phone number cannot report a listing twice while reports are open', async () => {
  reset(); results = [{ rows: [{ id: HOME }] }];
  failOn = { match: 'INSERT INTO listing_reports', error: Object.assign(new Error('duplicate'), { code: '23505' }) };
  await assert.rejects(reports.reportListing(HOME, { reason: 'fake_listing', phone: '0971234567' }), { status: 409 });
});

test('dismissing reports closes them and unhides the listing', async () => {
  reset(); results = [{ rows: [{ id: 1 }, { id: 2 }] }, { rows: [{ id: HOME, title: 'Lodge' }] }];
  const result = await reports.resolveReports(HOME, 'dismiss', 'Landlord verified in person', 'admin-1');
  assert.equal(result.reportsClosed, 2);
  assert.deepEqual(queries[0].params, [HOME, 'dismissed', 'Landlord verified in person', 'admin-1']);
  assert.match(queries[1].sql, /flagged_at = NULL/);
  assert.doesNotMatch(queries[1].sql, /is_approved/);
});

test('taking a listing down unpublishes it and removes the verified badge', async () => {
  reset(); results = [{ rows: [{ id: 1 }] }, { rows: [{ id: HOME, title: 'Lodge' }] }];
  await reports.resolveReports(HOME, 'take_down', null, 'admin-1');
  assert.equal(queries[0].params[1], 'resolved');
  assert.match(queries[1].sql, /is_approved = false, is_active = false, verified_at = NULL/);
  await assert.rejects(reports.resolveReports(HOME, 'delete', null, 'admin-1'), { status: 400 });
});

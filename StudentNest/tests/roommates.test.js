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
const roommates = require('../src/services/roommateService');

const SCHOOL = '33333333-3333-4333-8333-333333333333';
const POST = '44444444-4444-4444-8444-444444444444';
const valid = { display_name: 'Mwila', gender: 'female', share_with: 'female', school_id: SCHOOL, budget_max: '900', move_in: '2027-01-10', about: 'Second year nursing student', tags: ['quiet', 'tidy'], phone: '+260 97 123 4567' };
function reset() { queries.length = 0; results = []; }

test('valid input is normalised', () => {
  const input = roommates.validatePostInput(valid);
  assert.equal(input.phone, '0971234567');
  assert.equal(input.budget_max, 900);
  assert.deepEqual(input.tags, ['quiet', 'tidy']);
});

test('bad input is rejected with a readable message', () => {
  const cases = [
    { display_name: 'M' }, { gender: 'robot' }, { share_with: 'everyone' }, { school_id: 'unza' },
    { budget_max: '0' }, { budget_max: 'abc' }, { move_in: '10/01/2027' }, { about: 'x'.repeat(501) },
    { tags: ['quiet', 'party'] }, { phone: '12345' },
  ];
  for (const change of cases) {
    assert.throws(() => roommates.validatePostInput({ ...valid, ...change }), { status: 400 }, JSON.stringify(change));
  }
});

test('creating a post stores only a hash of the private link token and starts pending', async () => {
  reset(); results = [{ rows: [{ id: SCHOOL }] }, { rows: [{ count: 0 }] }, { rows: [{ id: POST, status: 'pending' }] }];
  const { post, manageToken } = await roommates.createPost(valid);
  assert.equal(post.status, 'pending');
  assert.match(manageToken, /^[A-Za-z0-9_-]{43}$/);
  const insert = queries.find(({ sql }) => sql.includes('INSERT INTO roommate_posts'));
  const storedHash = insert.params.at(-1);
  assert.equal(storedHash, crypto.createHash('sha256').update(manageToken).digest('hex'));
  assert.ok(!insert.params.includes(manageToken), 'plain token is never stored');
});

test('a phone number can only have a limited number of active posts', async () => {
  reset(); results = [{ rows: [{ id: SCHOOL }] }, { rows: [{ count: 2 }] }];
  await assert.rejects(roommates.createPost(valid), { status: 409 });
  assert.ok(!queries.some(({ sql }) => sql.includes('INSERT')));
});

test('public listing only returns approved, unexpired posts and never phone numbers', async () => {
  reset(); results = [{ rows: [] }];
  await roommates.listVisiblePosts({ school_id: SCHOOL, max_budget: '1000', share_with: 'female' });
  const { sql, params } = queries[0];
  assert.match(sql, /rp\.status = 'approved' AND rp\.expires_at > NOW\(\)/);
  assert.doesNotMatch(sql.split('FROM')[0], /phone|manage_token/);
  assert.match(sql, /rp\.share_with IN \(\$3, 'any'\)/);
  assert.deepEqual(params, [SCHOOL, 1000, 'female']);
});

test('contact is only revealed for visible posts, as a WhatsApp link', async () => {
  reset(); results = [{ rows: [{ phone: '0971234567' }] }];
  assert.deepEqual(await roommates.revealContact(POST), { phone: '0971234567', whatsapp: 'https://wa.me/260971234567' });
  assert.match(queries[0].sql, /contact_views = contact_views \+ 1/);
  assert.match(queries[0].sql, /rp\.status = 'approved'/);

  reset(); results = [{ rows: [] }];
  await assert.rejects(roommates.revealContact(POST), { status: 404 });
  await assert.rejects(roommates.revealContact('not-a-uuid'), { status: 404 });
});

test('repeated reports hide a post until an admin reviews it', async () => {
  reset(); results = [{ rows: [{ post_id: POST }] }];
  await roommates.reportPost(POST, 'Asked me for money');
  const { sql, params } = queries[0];
  assert.match(sql, /CASE WHEN report_count \+ 1 >= \$2 THEN 'pending'/);
  assert.deepEqual(params, [POST, roommates.REPORTS_BEFORE_AUTO_HIDE, 'Asked me for money']);
});

test('private links: invalid tokens are rejected without a query; edits go back for review', async () => {
  reset();
  await assert.rejects(roommates.findByToken('short'), { status: 404 });
  assert.equal(queries.length, 0);

  const token = crypto.randomBytes(32).toString('base64url');
  results = [{ rows: [{ id: POST, status: 'approved' }] }, { rows: [{ id: SCHOOL }] }, { rows: [] }, { rows: [{ id: POST, status: 'pending' }] }];
  const updated = await roommates.updateByToken(token, valid);
  assert.equal(queries[0].params[0], crypto.createHash('sha256').update(token).digest('hex'));
  const update = queries.find(({ sql }) => sql.startsWith('UPDATE roommate_posts'));
  assert.match(update.sql, /status = 'pending'/);
  assert.match(update.sql, /expires_at = NULL/);
  assert.equal(updated.status, 'pending');
});

test('approval makes a post visible for the configured lifetime and clears reports', async () => {
  reset(); results = [{ rows: [{ id: POST, display_name: 'Mwila', status: 'approved' }] }];
  await roommates.moderatePost(POST, 'approved', 'Looks genuine');
  assert.match(queries[0].sql, /report_count = 0/);
  assert.deepEqual(queries[0].params, [POST, 'Looks genuine', roommates.POST_LIFETIME_DAYS]);
  await assert.rejects(roommates.moderatePost(POST, 'maybe'), { status: 400 });
});

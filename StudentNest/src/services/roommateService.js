const crypto = require('crypto');
const pool = require('../config/db');
const { normalizeZambianMobile, whatsappLink } = require('../utils/phone');

// Rules for student roommate posts. Students have no accounts: a post is managed
// through a private link carrying a random token; only its SHA-256 is stored.
const POST_LIFETIME_DAYS = 30;
const MAX_ACTIVE_POSTS_PER_PHONE = 2;
const REPORTS_BEFORE_AUTO_HIDE = 3;
const MAX_BUDGET = 100000;

const GENDERS = ['female', 'male', 'unspecified'];
const SHARE_WITH = ['female', 'male', 'any'];
const TAGS = ['quiet', 'non_smoker', 'early_riser', 'night_owl', 'tidy', 'studious', 'social', 'cooks', 'religious', 'pets_ok'];
const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const TOKEN_PATTERN = /^[A-Za-z0-9_-]{43}$/;

const httpError = (status, message) => Object.assign(new Error(message), { status });
const hashToken = (token) => crypto.createHash('sha256').update(token).digest('hex');

// Never exposed publicly: phone, token hash, moderation fields.
const PUBLIC_COLUMNS = `rp.id, rp.display_name, rp.gender, rp.share_with, rp.school_id, rp.budget_max,
  rp.move_in, rp.about, rp.tags, rp.approved_at, rp.expires_at, s.name AS school_name`;
const VISIBLE = `rp.status = 'approved' AND rp.expires_at > NOW()`;

/** Validate and normalise the fields a student submits. Throws 400 with a readable message. */
const validatePostInput = (body = {}) => {
  const name = typeof body.display_name === 'string' ? body.display_name.trim() : '';
  if (name.length < 2 || name.length > 60) throw httpError(400, 'Enter your first name (2–60 characters)');
  if (!GENDERS.includes(body.gender)) throw httpError(400, 'Choose how you identify');
  const shareWith = body.share_with || 'any';
  if (!SHARE_WITH.includes(shareWith)) throw httpError(400, 'Choose who you would share with');
  if (!UUID_PATTERN.test(String(body.school_id || ''))) throw httpError(400, 'Choose your campus');
  const budget = Number(body.budget_max);
  if (!Number.isFinite(budget) || budget <= 0 || budget > MAX_BUDGET) throw httpError(400, 'Enter your monthly budget in Kwacha');
  let moveIn = null;
  if (body.move_in) {
    if (!/^\d{4}-\d{2}-\d{2}$/.test(body.move_in) || Number.isNaN(Date.parse(body.move_in))) throw httpError(400, 'Enter a valid move-in date');
    moveIn = body.move_in;
  }
  const about = typeof body.about === 'string' ? body.about.trim() : '';
  if (about.length > 500) throw httpError(400, 'Keep the description under 500 characters');
  const tags = Array.isArray(body.tags) ? [...new Set(body.tags)] : [];
  if (tags.some((tag) => !TAGS.includes(tag))) throw httpError(400, 'Unknown lifestyle tag');
  const phone = normalizeZambianMobile(body.phone);
  if (!phone) throw httpError(400, 'Enter a valid Zambian WhatsApp number, e.g. 0971234567');
  return { display_name: name, gender: body.gender, share_with: shareWith, school_id: body.school_id, budget_max: Math.round(budget * 100) / 100, move_in: moveIn, about: about || null, tags, phone };
};

const ensureSchoolExists = async (schoolId) => {
  const found = await pool.query('SELECT id FROM schools WHERE id = $1', [schoolId]);
  if (found.rows.length === 0) throw httpError(400, 'Choose your campus');
};

/** Student creates a post. It waits for admin approval. Returns the post and its one-time manage token. */
const createPost = async (body) => {
  const input = validatePostInput(body);
  await ensureSchoolExists(input.school_id);

  const active = await pool.query(
    `SELECT COUNT(*)::int AS count FROM roommate_posts
     WHERE phone = $1 AND status IN ('pending', 'approved') AND (expires_at IS NULL OR expires_at > NOW())`,
    [input.phone]
  );
  if (active.rows[0].count >= MAX_ACTIVE_POSTS_PER_PHONE) {
    throw httpError(409, 'This number already has active roommate posts. Use your private link to edit or remove one.');
  }

  const token = crypto.randomBytes(32).toString('base64url');
  const result = await pool.query(
    `INSERT INTO roommate_posts
       (display_name, gender, share_with, school_id, budget_max, move_in, about, tags, phone, manage_token_hash)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
     RETURNING id, status, created_at`,
    [input.display_name, input.gender, input.share_with, input.school_id, input.budget_max, input.move_in,
      input.about, JSON.stringify(input.tags), input.phone, hashToken(token)]
  );
  return { post: result.rows[0], manageToken: token };
};

/** Approved, unexpired posts for students to browse. No phone numbers. */
const listVisiblePosts = async ({ school_id: schoolId, max_budget: maxBudget, share_with: shareWith } = {}) => {
  const params = [];
  const where = [VISIBLE];
  if (schoolId && UUID_PATTERN.test(schoolId)) { params.push(schoolId); where.push(`rp.school_id = $${params.length}`); }
  if (maxBudget && Number.isFinite(Number(maxBudget))) { params.push(Number(maxBudget)); where.push(`rp.budget_max <= $${params.length}`); }
  // "Show people who'd share with me": a woman sees posts open to women or anyone.
  if (shareWith && ['female', 'male'].includes(shareWith)) { params.push(shareWith); where.push(`rp.share_with IN ($${params.length}, 'any')`); }
  const result = await pool.query(
    `SELECT ${PUBLIC_COLUMNS}
     FROM roommate_posts rp LEFT JOIN schools s ON s.id = rp.school_id
     WHERE ${where.join(' AND ')}
     ORDER BY rp.approved_at DESC
     LIMIT 200`,
    params
  );
  return result.rows;
};

/** Reveal the WhatsApp contact of a visible post (counted, so admins can spot scraping). */
const revealContact = async (postId) => {
  if (!UUID_PATTERN.test(String(postId || ''))) throw httpError(404, 'Post not found');
  const result = await pool.query(
    `UPDATE roommate_posts rp SET contact_views = contact_views + 1
     WHERE rp.id = $1 AND ${VISIBLE}
     RETURNING rp.phone`,
    [postId]
  );
  if (result.rows.length === 0) throw httpError(404, 'This post is no longer available');
  const { phone } = result.rows[0];
  return { phone, whatsapp: whatsappLink(phone) };
};

/** Anyone can report a post; enough reports hide it until an admin reviews it again. */
const reportPost = async (postId, reason) => {
  if (!UUID_PATTERN.test(String(postId || ''))) throw httpError(404, 'Post not found');
  const cleanReason = typeof reason === 'string' ? reason.trim().slice(0, 500) : '';
  const result = await pool.query(
    `WITH reported AS (
       UPDATE roommate_posts rp
       SET report_count = report_count + 1,
           status = CASE WHEN report_count + 1 >= $2 THEN 'pending' ELSE status END,
           review_note = CASE WHEN report_count + 1 >= $2 THEN 'Hidden automatically after repeated reports' ELSE review_note END,
           updated_at = NOW()
       WHERE rp.id = $1 AND ${VISIBLE}
       RETURNING rp.id
     )
     INSERT INTO roommate_reports (post_id, reason)
     SELECT id, $3 FROM reported
     RETURNING post_id`,
    [postId, REPORTS_BEFORE_AUTO_HIDE, cleanReason || null]
  );
  if (result.rows.length === 0) throw httpError(404, 'This post is no longer available');
};

const findByToken = async (token) => {
  if (!TOKEN_PATTERN.test(String(token || ''))) throw httpError(404, 'This link is not valid');
  const result = await pool.query(
    `SELECT rp.id, rp.display_name, rp.gender, rp.share_with, rp.school_id, rp.budget_max, rp.move_in,
            rp.about, rp.tags, rp.phone, rp.status, rp.review_note, rp.expires_at, rp.created_at,
            s.name AS school_name
     FROM roommate_posts rp LEFT JOIN schools s ON s.id = rp.school_id
     WHERE rp.manage_token_hash = $1 AND rp.status <> 'removed'`,
    [hashToken(token)]
  );
  if (result.rows.length === 0) throw httpError(404, 'This link is not valid or the post was removed');
  return result.rows[0];
};

/** Owner edits through their private link; the post goes back for review. */
const updateByToken = async (token, body) => {
  const existing = await findByToken(token);
  const input = validatePostInput(body);
  await ensureSchoolExists(input.school_id);
  await pool.query(
    `UPDATE roommate_posts
     SET display_name = $2, gender = $3, share_with = $4, school_id = $5, budget_max = $6, move_in = $7,
         about = $8, tags = $9, phone = $10, status = 'pending', review_note = NULL,
         approved_at = NULL, expires_at = NULL, updated_at = NOW()
     WHERE id = $1`,
    [existing.id, input.display_name, input.gender, input.share_with, input.school_id, input.budget_max,
      input.move_in, input.about, JSON.stringify(input.tags), input.phone]
  );
  return findByToken(token);
};

const removeByToken = async (token) => {
  const existing = await findByToken(token);
  await pool.query(`UPDATE roommate_posts SET status = 'removed', updated_at = NOW() WHERE id = $1`, [existing.id]);
};

/** Admin view: everything, including phone numbers and reports. */
const listForAdmin = async () => {
  const result = await pool.query(
    `SELECT rp.id, rp.display_name, rp.gender, rp.share_with, rp.school_id, rp.budget_max, rp.move_in, rp.about,
            rp.tags, rp.phone, rp.status, rp.review_note, rp.report_count, rp.contact_views, rp.approved_at,
            rp.expires_at, rp.created_at, rp.updated_at, s.name AS school_name,
            COALESCE((SELECT JSON_AGG(r.reason ORDER BY r.created_at DESC) FILTER (WHERE r.reason IS NOT NULL)
                      FROM roommate_reports r WHERE r.post_id = rp.id), '[]') AS report_reasons
     FROM roommate_posts rp LEFT JOIN schools s ON s.id = rp.school_id
     WHERE rp.status <> 'removed'
     ORDER BY (rp.status = 'pending') DESC, rp.created_at DESC
     LIMIT 500`
  );
  return result.rows;
};

/** Admin approves (visible for 30 days, reports cleared) or rejects a post. */
const moderatePost = async (postId, decision, note) => {
  if (!UUID_PATTERN.test(String(postId || ''))) throw httpError(404, 'Post not found');
  if (!['approved', 'rejected'].includes(decision)) throw httpError(400, 'Decision must be approved or rejected');
  const cleanNote = typeof note === 'string' && note.trim() ? note.trim().slice(0, 500) : null;
  const result = await pool.query(
    decision === 'approved'
      ? `UPDATE roommate_posts
         SET status = 'approved', review_note = $2, report_count = 0, approved_at = NOW(),
             expires_at = NOW() + make_interval(days => $3), updated_at = NOW()
         WHERE id = $1 AND status <> 'removed'
         RETURNING id, display_name, status, expires_at`
      : `UPDATE roommate_posts
         SET status = 'rejected', review_note = $2, expires_at = NULL, updated_at = NOW()
         WHERE id = $1 AND status <> 'removed'
         RETURNING id, display_name, status, expires_at`,
    decision === 'approved' ? [postId, cleanNote, POST_LIFETIME_DAYS] : [postId, cleanNote]
  );
  if (result.rows.length === 0) throw httpError(404, 'Post not found');
  return result.rows[0];
};

module.exports = {
  TAGS, GENDERS, SHARE_WITH, POST_LIFETIME_DAYS, REPORTS_BEFORE_AUTO_HIDE,
  validatePostInput, createPost, listVisiblePosts, revealContact, reportPost,
  findByToken, updateByToken, removeByToken, listForAdmin, moderatePost,
};

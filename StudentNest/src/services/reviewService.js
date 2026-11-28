const pool = require('../config/db');
const { normalizeZambianMobile } = require('../utils/phone');

// Reviews from students who stayed in a home. No student accounts: the reviewer
// gives a phone number that only admins see, so they can confirm the stay
// before approving. Landlords can reply publicly but cannot remove reviews.
const RATING_FIELDS = ['rating_overall', 'rating_landlord', 'rating_utilities', 'rating_security', 'rating_value'];
const MIN_COMMENT = 20;
const MAX_COMMENT = 1000;
const MAX_REPLY = 1000;
const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const MONTH_PATTERN = /^\d{4}-(0[1-9]|1[0-2])$/;

const httpError = (status, message) => Object.assign(new Error(message), { status });
const monthStart = (month) => `${month}-01`;
const currentMonth = () => new Date().toISOString().slice(0, 7);

// Public view: never the reviewer's phone or moderation notes.
const PUBLIC_COLUMNS = `id, property_id, reviewer_name, stay_from, stay_to, ${RATING_FIELDS.join(', ')},
  comment, landlord_reply, landlord_reply_at, approved_at`;

const validateReview = (body = {}) => {
  const ratings = {};
  for (const field of RATING_FIELDS) {
    const value = Number(body[field]);
    if (!Number.isInteger(value) || value < 1 || value > 5) throw httpError(400, 'Give every rating from 1 to 5 stars');
    ratings[field] = value;
  }
  const comment = typeof body.comment === 'string' ? body.comment.trim() : '';
  if (comment.length < MIN_COMMENT || comment.length > MAX_COMMENT) {
    throw httpError(400, `Write between ${MIN_COMMENT} and ${MAX_COMMENT} characters about your stay`);
  }
  if (!MONTH_PATTERN.test(String(body.stay_from || ''))) throw httpError(400, 'Choose when you moved in');
  if (body.stay_from > currentMonth()) throw httpError(400, 'Move-in month can’t be in the future');
  let stayTo = null;
  if (body.stay_to) {
    if (!MONTH_PATTERN.test(String(body.stay_to))) throw httpError(400, 'Choose when you moved out');
    if (body.stay_to < body.stay_from) throw httpError(400, 'Move-out month must be after move-in');
    if (body.stay_to > currentMonth()) throw httpError(400, 'Move-out month can’t be in the future');
    stayTo = monthStart(body.stay_to);
  }
  const phone = normalizeZambianMobile(body.phone);
  if (!phone) throw httpError(400, 'Enter your phone number so our team can confirm your stay');
  const name = typeof body.reviewer_name === 'string' ? body.reviewer_name.trim().slice(0, 60) : '';
  return { ...ratings, comment, stay_from: monthStart(body.stay_from), stay_to: stayTo, phone, reviewer_name: name || 'Student' };
};

/** A student submits a review; it waits for admin approval. */
const createReview = async (propertyId, body) => {
  if (!UUID_PATTERN.test(String(propertyId || ''))) throw httpError(404, 'Home not found');
  const input = validateReview(body);
  const property = await pool.query('SELECT id FROM properties WHERE id = $1 AND is_approved = true', [propertyId]);
  if (property.rows.length === 0) throw httpError(404, 'Home not found');
  try {
    const result = await pool.query(
      `INSERT INTO reviews (property_id, reviewer_name, phone, stay_from, stay_to,
         rating_overall, rating_landlord, rating_utilities, rating_security, rating_value, comment)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
       RETURNING id, status`,
      [propertyId, input.reviewer_name, input.phone, input.stay_from, input.stay_to,
        input.rating_overall, input.rating_landlord, input.rating_utilities, input.rating_security, input.rating_value, input.comment]
    );
    return result.rows[0];
  } catch (err) {
    if (err.code === '23505') throw httpError(409, 'You have already reviewed this home');
    throw err;
  }
};

/** Approved reviews and averages for a home. */
const listForProperty = async (propertyId) => {
  if (!UUID_PATTERN.test(String(propertyId || ''))) throw httpError(404, 'Home not found');
  const [reviews, summary] = await Promise.all([
    pool.query(
      `SELECT ${PUBLIC_COLUMNS} FROM reviews
       WHERE property_id = $1 AND status = 'approved'
       ORDER BY approved_at DESC
       LIMIT 100`,
      [propertyId]
    ),
    pool.query(
      `SELECT COUNT(*)::int AS count,
              ${RATING_FIELDS.map((f) => `ROUND(AVG(${f})::numeric, 1)::float AS ${f}`).join(', ')}
       FROM reviews WHERE property_id = $1 AND status = 'approved'`,
      [propertyId]
    ),
  ]);
  return { reviews: reviews.rows, summary: summary.rows[0] };
};

/** The landlord who owns the home replies to an approved review (replaces any earlier reply). */
const replyAsLandlord = async (reviewId, landlordId, reply) => {
  if (!UUID_PATTERN.test(String(reviewId || ''))) throw httpError(404, 'Review not found');
  const text = typeof reply === 'string' ? reply.trim() : '';
  if (text.length > MAX_REPLY) throw httpError(400, `Keep your reply under ${MAX_REPLY} characters`);
  const result = await pool.query(
    `UPDATE reviews r
     SET landlord_reply = $3, landlord_reply_at = CASE WHEN $3::text IS NULL THEN NULL ELSE NOW() END, updated_at = NOW()
     FROM properties p
     WHERE r.id = $1 AND r.property_id = p.id AND p.landlord_id = $2 AND r.status = 'approved'
     RETURNING r.id, r.landlord_reply, r.landlord_reply_at`,
    [reviewId, landlordId, text || null]
  );
  if (result.rows.length === 0) throw httpError(404, 'Review not found');
  return result.rows[0];
};

const listForAdmin = async () => {
  const result = await pool.query(
    `SELECT r.*, p.title AS property_title, u.full_name AS landlord_name, u.phone AS landlord_phone
     FROM reviews r
     JOIN properties p ON p.id = r.property_id
     LEFT JOIN users u ON u.id = p.landlord_id
     ORDER BY (r.status = 'pending') DESC, r.created_at DESC
     LIMIT 500`
  );
  return result.rows;
};

const moderateReview = async (reviewId, decision, note) => {
  if (!UUID_PATTERN.test(String(reviewId || ''))) throw httpError(404, 'Review not found');
  if (!['approved', 'rejected'].includes(decision)) throw httpError(400, 'Decision must be approved or rejected');
  const cleanNote = typeof note === 'string' && note.trim() ? note.trim().slice(0, 500) : null;
  let result;
  try {
    result = await pool.query(
      `UPDATE reviews
       SET status = $2::text, review_note = $3,
           approved_at = CASE WHEN $2::text = 'approved' THEN COALESCE(approved_at, NOW()) ELSE NULL END,
           updated_at = NOW()
       WHERE id = $1
       RETURNING id, property_id, status, reviewer_name`,
      [reviewId, decision, cleanNote]
    );
  } catch (err) {
    // Re-approving a rejected review when the same number has since posted another one.
    if (err.code === '23505') throw httpError(409, 'This number already has another review of this home');
    throw err;
  }
  if (result.rows.length === 0) throw httpError(404, 'Review not found');
  return result.rows[0];
};

module.exports = {
  RATING_FIELDS, validateReview, createReview, listForProperty, replyAsLandlord, listForAdmin, moderateReview,
};

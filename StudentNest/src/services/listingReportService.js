const pool = require('../config/db');
const { normalizeZambianMobile } = require('../utils/phone');

// Students can report a listing they think is a scam. Admins review reports in
// the portal. To protect students quickly without letting one person take down a
// competitor, a listing is hidden automatically only when enough *different*
// phone numbers report it within a short window.
const REASONS = ['fake_listing', 'upfront_payment', 'misleading', 'impersonation', 'other'];
const AUTO_HIDE_DISTINCT_REPORTERS = 3;
const AUTO_HIDE_WINDOW_DAYS = 30;
const MAX_DETAILS = 1000;
const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

const httpError = (status, message) => Object.assign(new Error(message), { status });

/** A student reports a listing. Returns whether the listing is now hidden pending review. */
const reportListing = async (propertyId, body = {}) => {
  if (!UUID_PATTERN.test(String(propertyId || ''))) throw httpError(404, 'Home not found');
  if (!REASONS.includes(body.reason)) throw httpError(400, 'Choose what is wrong with this listing');
  const details = typeof body.details === 'string' ? body.details.trim() : '';
  if (details.length > MAX_DETAILS) throw httpError(400, `Keep the details under ${MAX_DETAILS} characters`);
  if (body.reason === 'other' && details.length < 10) throw httpError(400, 'Tell us a little about what is wrong');
  let phone = null;
  if (body.phone) {
    phone = normalizeZambianMobile(body.phone);
    if (!phone) throw httpError(400, 'Enter a valid Zambian phone number, or leave it blank');
  }

  const property = await pool.query('SELECT id FROM properties WHERE id = $1', [propertyId]);
  if (property.rows.length === 0) throw httpError(404, 'Home not found');

  try {
    await pool.query(
      `INSERT INTO listing_reports (property_id, reason, details, reporter_phone) VALUES ($1, $2, $3, $4)`,
      [propertyId, body.reason, details || null, phone]
    );
  } catch (err) {
    if (err.code === '23505') throw httpError(409, 'You have already reported this listing. Our team is looking into it.');
    throw err;
  }

  // Hide the listing once enough different people have reported it recently.
  const flagged = await pool.query(
    `UPDATE properties p SET flagged_at = NOW()
     WHERE p.id = $1 AND p.flagged_at IS NULL
       AND (SELECT COUNT(DISTINCT r.reporter_phone) FROM listing_reports r
            WHERE r.property_id = p.id AND r.status = 'open' AND r.reporter_phone IS NOT NULL
              AND r.created_at > NOW() - make_interval(days => $3)) >= $2
     RETURNING p.id`,
    [propertyId, AUTO_HIDE_DISTINCT_REPORTERS, AUTO_HIDE_WINDOW_DAYS]
  );
  return { hidden: flagged.rows.length > 0 };
};

/** Admin view: listings with open reports first, each with its reports. */
const listForAdmin = async () => {
  const result = await pool.query(
    `SELECT p.id AS property_id, p.title, p.address, p.is_approved, p.is_active, p.flagged_at,
            u.full_name AS landlord_name, u.phone AS landlord_phone,
            COUNT(*) FILTER (WHERE r.status = 'open')::int AS open_count,
            COUNT(DISTINCT r.reporter_phone) FILTER (WHERE r.status = 'open')::int AS distinct_reporters,
            MAX(r.created_at) AS last_reported_at,
            JSON_AGG(JSON_BUILD_OBJECT(
              'id', r.id, 'reason', r.reason, 'details', r.details, 'reporter_phone', r.reporter_phone,
              'status', r.status, 'resolution_note', r.resolution_note, 'created_at', r.created_at
            ) ORDER BY r.created_at DESC) AS reports
     FROM listing_reports r
     JOIN properties p ON p.id = r.property_id
     LEFT JOIN users u ON u.id = p.landlord_id
     GROUP BY p.id, u.full_name, u.phone
     ORDER BY (COUNT(*) FILTER (WHERE r.status = 'open') > 0) DESC, (p.flagged_at IS NOT NULL) DESC, MAX(r.created_at) DESC
     LIMIT 300`
  );
  return result.rows;
};

/**
 * Admin decision on all open reports for a listing:
 *  - dismiss:   reports were unfounded; the listing becomes visible again
 *  - take_down: the listing is unpublished and must be re-approved (verified badge removed)
 */
const resolveReports = async (propertyId, action, note, adminId) => {
  if (!UUID_PATTERN.test(String(propertyId || ''))) throw httpError(404, 'Home not found');
  if (!['dismiss', 'take_down'].includes(action)) throw httpError(400, 'Action must be dismiss or take_down');
  const cleanNote = typeof note === 'string' && note.trim() ? note.trim().slice(0, 500) : null;

  const reports = await pool.query(
    `UPDATE listing_reports
     SET status = $2, resolution_note = $3, resolved_by = $4, resolved_at = NOW()
     WHERE property_id = $1 AND status = 'open'
     RETURNING id`,
    [propertyId, action === 'dismiss' ? 'dismissed' : 'resolved', cleanNote, adminId]
  );

  const property = await pool.query(
    action === 'dismiss'
      ? `UPDATE properties SET flagged_at = NULL, updated_at = NOW() WHERE id = $1 RETURNING id, title`
      : `UPDATE properties
         SET is_approved = false, is_active = false, verified_at = NULL, flagged_at = NULL, updated_at = NOW()
         WHERE id = $1 RETURNING id, title`,
    [propertyId]
  );
  if (property.rows.length === 0) throw httpError(404, 'Home not found');
  return { property: property.rows[0], reportsClosed: reports.rows.length };
};

module.exports = { REASONS, AUTO_HIDE_DISTINCT_REPORTERS, reportListing, listForAdmin, resolveReports };

const pool = require('../config/db');
const { normalizeZambianMobile, whatsappLink } = require('../utils/phone');
const { getWhatsAppProvider } = require('./notifications/whatsapp');

// Students ask to view a home; landlords confirm or decline from their dashboard.
// Every request also gives the student a pre-written WhatsApp message to the
// landlord (works with no setup), and the landlord gets an automatic WhatsApp
// alert when a provider is configured.
const TIMES = { morning: 'morning (8am–12pm)', afternoon: 'afternoon (12–4pm)', evening: 'evening (4–6pm)' };
const MAX_DAYS_AHEAD = 60;
const MAX_PENDING_PER_PHONE = 5;
const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const WEB_APP_URL = (process.env.WEB_APP_URL || 'https://student-home-iota.vercel.app').replace(/\/$/, '');

const httpError = (status, message) => Object.assign(new Error(message), { status });

/** Today's date in Zambia as YYYY-MM-DD. */
const lusakaToday = (now = new Date()) =>
  new Intl.DateTimeFormat('en-CA', { timeZone: 'Africa/Lusaka', year: 'numeric', month: '2-digit', day: '2-digit' }).format(now);
const addDays = (isoDate, days) => {
  const date = new Date(`${isoDate}T12:00:00Z`);
  date.setUTCDate(date.getUTCDate() + days);
  return date.toISOString().slice(0, 10);
};
const dayLabel = (isoDate) =>
  new Date(`${String(isoDate).slice(0, 10)}T12:00:00Z`).toLocaleDateString('en-GB', { weekday: 'short', day: 'numeric', month: 'short', timeZone: 'UTC' });
const whenLabel = (date, time) => `${dayLabel(date)}, ${TIMES[time] || time}`;
const withText = (phone, text) => `${whatsappLink(phone)}?text=${encodeURIComponent(text)}`;

const validateRequest = (body = {}, today = lusakaToday()) => {
  const name = typeof body.student_name === 'string' ? body.student_name.trim() : '';
  if (name.length < 2 || name.length > 60) throw httpError(400, 'Enter your name (2–60 characters)');
  const phone = normalizeZambianMobile(body.student_phone);
  if (!phone) throw httpError(400, 'Enter your WhatsApp number, e.g. 0971234567');
  const date = String(body.preferred_date || '');
  if (!/^\d{4}-\d{2}-\d{2}$/.test(date) || Number.isNaN(Date.parse(date))) throw httpError(400, 'Choose a day for the viewing');
  if (date < today) throw httpError(400, 'Choose today or a later day');
  if (date > addDays(today, MAX_DAYS_AHEAD)) throw httpError(400, `Choose a day within the next ${MAX_DAYS_AHEAD} days`);
  if (!Object.keys(TIMES).includes(body.preferred_time)) throw httpError(400, 'Choose morning, afternoon or evening');
  const message = typeof body.message === 'string' ? body.message.trim() : '';
  if (message.length > 500) throw httpError(400, 'Keep your message under 500 characters');
  return { student_name: name, student_phone: phone, preferred_date: date, preferred_time: body.preferred_time, message: message || null };
};

/** A student asks to view a home. Never fails because of the WhatsApp alert. */
const createRequest = async (propertyId, body) => {
  if (!UUID_PATTERN.test(String(propertyId || ''))) throw httpError(404, 'Home not found');
  const input = validateRequest(body);

  const property = await pool.query(
    `SELECT p.id, p.title, u.full_name AS landlord_name, u.phone AS landlord_phone
     FROM properties p JOIN users u ON u.id = p.landlord_id
     WHERE p.id = $1 AND p.is_approved = true AND p.is_active = true AND p.flagged_at IS NULL
       AND (p.listing_expires_at IS NULL OR p.listing_expires_at > NOW())`,
    [propertyId]
  );
  if (property.rows.length === 0) throw httpError(404, 'This home is not available for viewings');
  const home = property.rows[0];

  const pending = await pool.query(
    `SELECT COUNT(*)::int AS count FROM viewing_requests WHERE student_phone = $1 AND status = 'pending'`,
    [input.student_phone]
  );
  if (pending.rows[0].count >= MAX_PENDING_PER_PHONE) {
    throw httpError(409, 'You have several viewing requests waiting already. Wait for landlords to reply first.');
  }

  let request;
  try {
    request = (await pool.query(
      `INSERT INTO viewing_requests (property_id, student_name, student_phone, preferred_date, preferred_time, message)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING id, status, preferred_date, preferred_time, created_at`,
      [propertyId, input.student_name, input.student_phone, input.preferred_date, input.preferred_time, input.message]
    )).rows[0];
  } catch (err) {
    if (err.code === '23505') throw httpError(409, 'You already have a viewing request waiting for this home');
    throw err;
  }

  const when = whenLabel(input.preferred_date, input.preferred_time);
  await sendLandlordAlert(request.id, { to: home.landlord_phone, studentName: input.student_name, propertyTitle: home.title, when });

  const text = `Hi ${home.landlord_name || ''}, I'm ${input.student_name}. I found "${home.title}" on Student Nest and would like to view it on ${when}.`
    + (input.message ? ` ${input.message}` : '');
  return {
    request,
    landlord_name: home.landlord_name,
    whatsapp_link: home.landlord_phone ? withText(normalizeZambianMobile(home.landlord_phone) || home.landlord_phone, text) : null,
  };
};

/** Automatic alert; records the outcome but never throws. */
const sendLandlordAlert = async (requestId, alert) => {
  const provider = getWhatsAppProvider();
  const to = normalizeZambianMobile(alert.to);
  if (!provider || !to) return;
  let status = 'sent';
  let error = null;
  try {
    await provider.sendViewingAlert({ ...alert, to, link: `${WEB_APP_URL}/landlord` });
  } catch (err) {
    status = 'failed';
    error = String(err.message || err).slice(0, 300);
    console.error(`Viewing request ${requestId}: WhatsApp alert failed:`, error);
  }
  await pool.query('UPDATE viewing_requests SET notify_status = $2, notify_error = $3 WHERE id = $1', [requestId, status, error]);
};

const replyText = (row) => {
  const when = whenLabel(row.preferred_date, row.preferred_time);
  const note = row.landlord_note ? ` ${row.landlord_note}` : '';
  return row.status === 'confirmed'
    ? `Hi ${row.student_name}, your viewing of "${row.property_title}" is confirmed for ${when}.${note}`
    : `Hi ${row.student_name}, sorry, I can't do a viewing of "${row.property_title}" on ${when}.${note}`;
};
const withReplyLink = (row) => ({
  ...row,
  when: whenLabel(row.preferred_date, row.preferred_time),
  reply_link: row.status === 'pending' ? whatsappLink(row.student_phone) : withText(row.student_phone, replyText(row)),
});

/** Requests for the landlord's own homes, waiting ones first. */
const listForLandlord = async (landlordId) => {
  const result = await pool.query(
    `SELECT v.id, v.property_id, p.title AS property_title, v.student_name, v.student_phone, v.preferred_date,
            v.preferred_time, v.message, v.status, v.landlord_note, v.notify_status, v.responded_at, v.created_at
     FROM viewing_requests v JOIN properties p ON p.id = v.property_id
     WHERE p.landlord_id = $1
     ORDER BY (v.status = 'pending') DESC, v.preferred_date ASC, v.created_at DESC
     LIMIT 200`,
    [landlordId]
  );
  return result.rows.map(withReplyLink);
};

/** Landlord confirms or declines one of their requests. */
const respond = async (landlordId, requestId, status, note) => {
  if (!UUID_PATTERN.test(String(requestId || ''))) throw httpError(404, 'Request not found');
  if (!['confirmed', 'declined'].includes(status)) throw httpError(400, 'Choose confirm or decline');
  const cleanNote = typeof note === 'string' && note.trim() ? note.trim().slice(0, 300) : null;
  const result = await pool.query(
    `UPDATE viewing_requests v
     SET status = $3, landlord_note = $4, responded_at = NOW()
     FROM properties p
     WHERE v.id = $1 AND v.property_id = p.id AND p.landlord_id = $2
     RETURNING v.id, v.property_id, p.title AS property_title, v.student_name, v.student_phone, v.preferred_date,
               v.preferred_time, v.message, v.status, v.landlord_note, v.notify_status, v.responded_at, v.created_at`,
    [requestId, landlordId, status, cleanNote]
  );
  if (result.rows.length === 0) throw httpError(404, 'Request not found');
  return withReplyLink(result.rows[0]);
};

module.exports = { TIMES, lusakaToday, whenLabel, validateRequest, createRequest, listForLandlord, respond };

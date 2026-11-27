const crypto = require('crypto');
const pool = require('../config/db');
const { getPlan } = require('../config/listingPlans');
const { getPaymentProvider } = require('./payments');
const { OPERATORS, normalizePhone, detectOperator } = require('./payments/mobileMoney');

// A landlord can't start a second payment for the same listing while one is
// still waiting for phone approval inside this window.
const PENDING_LOCK_MINUTES = 10;
const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

const httpError = (status, message, extra = {}) =>
  Object.assign(new Error(message), { status, ...extra });

const PUBLIC_FIELDS = [
  'id', 'property_id', 'plan', 'amount', 'status', 'failure_reason', 'payment_reference',
  'mobile_money_provider', 'phone', 'duration_months', 'paid_at', 'expires_at', 'created_at',
];
const toPublic = (payment) =>
  Object.fromEntries(PUBLIC_FIELDS.map((field) => [field, payment[field] ?? null]));

const requireProvider = () => {
  const provider = getPaymentProvider();
  if (!provider) {
    throw httpError(503, 'In-app payments are not available yet. Please contact the Student Nest team to pay.');
  }
  return provider;
};

/**
 * Confirm a pending payment and extend the listing in one statement, so a
 * webhook and a status poll arriving together can never apply it twice.
 * Renewals extend from the current expiry when it is still in the future.
 */
const confirmPayment = async (paymentId, providerReference) => {
  const result = await pool.query(
    `WITH target AS (
       SELECT pm.id,
              GREATEST(COALESCE(p.listing_expires_at, NOW()), NOW())
                + make_interval(months => pm.duration_months) AS new_expiry
       FROM payments pm
       JOIN properties p ON p.id = pm.property_id
       WHERE pm.id = $1 AND pm.status = 'pending'
       FOR UPDATE OF pm
     ),
     paid AS (
       UPDATE payments pm
       SET status = 'confirmed',
           paid_at = NOW(),
           expires_at = target.new_expiry,
           provider_reference = COALESCE($2, pm.provider_reference),
           failure_reason = NULL
       FROM target
       WHERE pm.id = target.id
       RETURNING pm.*
     ),
     activated AS (
       UPDATE properties p
       SET is_active = true, listing_expires_at = paid.expires_at, updated_at = NOW()
       FROM paid
       WHERE p.id = paid.property_id
       RETURNING p.id
     )
     SELECT * FROM paid`,
    [paymentId, providerReference]
  );
  return result.rows[0] || null;
};

const failPayment = async (paymentId, reason, providerReference) => {
  const result = await pool.query(
    `UPDATE payments
     SET status = 'failed',
         failure_reason = $2,
         provider_reference = COALESCE($3, provider_reference)
     WHERE id = $1 AND status = 'pending'
     RETURNING *`,
    [paymentId, reason, providerReference]
  );
  return result.rows[0] || null;
};

const reloadPayment = async (paymentId) =>
  (await pool.query('SELECT * FROM payments WHERE id = $1', [paymentId])).rows[0];

/** Apply a provider status to a payment. Safe to call repeatedly. */
const applyProviderResult = async (payment, result) => {
  if (payment.status !== 'pending') return payment;
  const ref = result.providerReference || null;

  if (result.status === 'successful') {
    // Never trust a success for a different amount than we asked for.
    if (result.amount != null && Math.abs(result.amount - Number(payment.amount)) >= 0.01) {
      console.error(`Payment ${payment.id}: provider amount ${result.amount} != expected ${payment.amount}`);
      return (await failPayment(payment.id, 'Amount mismatch. Contact support.', ref)) || reloadPayment(payment.id);
    }
    return (await confirmPayment(payment.id, ref)) || reloadPayment(payment.id);
  }

  if (result.status === 'failed') {
    return (await failPayment(payment.id, result.failureReason || 'Payment was not completed', ref)) ||
      reloadPayment(payment.id);
  }

  if (ref || result.providerCollectionId) {
    const updated = await pool.query(
      `UPDATE payments
       SET provider_reference = COALESCE($2, provider_reference),
           provider_collection_id = COALESCE($3, provider_collection_id)
       WHERE id = $1
       RETURNING *`,
      [payment.id, ref, result.providerCollectionId || null]
    );
    return updated.rows[0] || payment;
  }
  return payment;
};

/** Landlord starts paying for an approved listing; their phone gets an approval prompt. */
const startListingPayment = async ({ landlordId, propertyId, planId, phone, operator }) => {
  const plan = getPlan(planId);
  if (!plan) throw httpError(400, 'Choose a listing plan');

  const normalizedPhone = normalizePhone(phone);
  if (!normalizedPhone) throw httpError(400, 'Enter a valid Zambian mobile money number, e.g. 0971234567');

  const resolvedOperator = operator || detectOperator(normalizedPhone);
  if (!OPERATORS.includes(resolvedOperator)) throw httpError(400, 'Choose MTN, Airtel or Zamtel');

  if (!UUID_PATTERN.test(String(propertyId || ''))) throw httpError(404, 'Property not found');

  const provider = requireProvider();

  const property = await pool.query(
    'SELECT id, is_approved FROM properties WHERE id = $1 AND landlord_id = $2',
    [propertyId, landlordId]
  );
  if (property.rows.length === 0) throw httpError(404, 'Property not found');
  if (!property.rows[0].is_approved) {
    throw httpError(400, 'Your listing must be approved by an admin before you can pay');
  }

  const inFlight = await pool.query(
    `SELECT id FROM payments
     WHERE property_id = $1 AND status = 'pending' AND provider IS NOT NULL
       AND created_at > NOW() - make_interval(mins => $2)
     LIMIT 1`,
    [propertyId, PENDING_LOCK_MINUTES]
  );
  if (inFlight.rows.length > 0) {
    throw httpError(409, 'A payment for this listing is already waiting for approval on your phone', {
      paymentId: inFlight.rows[0].id,
    });
  }

  const reference = `SN-${crypto.randomUUID()}`;
  const inserted = await pool.query(
    `INSERT INTO payments
       (landlord_id, property_id, amount, payment_method, mobile_money_provider,
        payment_reference, reference, transaction_reference, duration_months,
        status, plan, provider, phone)
     VALUES ($1, $2, $3, 'mobile_money', $4, $5, $5, $5, $6, 'pending', $7, $8, $9)
     RETURNING *`,
    [landlordId, propertyId, plan.amount, resolvedOperator, reference, plan.months, plan.id, provider.name, normalizedPhone]
  );
  const payment = inserted.rows[0];

  let result;
  try {
    result = await provider.startCollection({
      amount: plan.amount,
      reference,
      phone: normalizedPhone,
      operator: resolvedOperator,
    });
  } catch (err) {
    console.error(`Payment ${payment.id}: could not start collection:`, err.message);
    await failPayment(payment.id, 'Could not reach the mobile money network', null);
    throw httpError(502, 'We could not reach the mobile money network. Please try again.');
  }

  return toPublic(await applyProviderResult(payment, result));
};

/** Landlord checks a payment; pending payments are re-checked with the provider. */
const getLandlordPayment = async ({ landlordId, paymentId }) => {
  if (!UUID_PATTERN.test(String(paymentId || ''))) throw httpError(404, 'Payment not found');
  const found = await pool.query(
    'SELECT * FROM payments WHERE id = $1 AND landlord_id = $2',
    [paymentId, landlordId]
  );
  let payment = found.rows[0];
  if (!payment) throw httpError(404, 'Payment not found');

  const provider = getPaymentProvider();
  if (payment.status === 'pending' && provider && payment.provider === provider.name) {
    try {
      payment = await applyProviderResult(payment, await provider.getCollection(payment.payment_reference));
    } catch (err) {
      // Keep it pending; the webhook or the next poll will resolve it.
      console.error(`Payment ${payment.id}: status check failed:`, err.message);
    }
  }
  return toPublic(payment);
};

const listLandlordPayments = async ({ landlordId, propertyId }) => {
  if (propertyId && !UUID_PATTERN.test(String(propertyId))) return [];
  const result = await pool.query(
    `SELECT * FROM payments
     WHERE landlord_id = $1 AND ($2::uuid IS NULL OR property_id = $2::uuid)
     ORDER BY created_at DESC
     LIMIT 50`,
    [landlordId, propertyId || null]
  );
  return result.rows.map(toPublic);
};

/** Provider webhook. Returns false when the signature is invalid. */
const handleProviderWebhook = async (rawBody, signature) => {
  const provider = getPaymentProvider();
  const parsed = provider?.parseWebhook(rawBody, signature);
  if (!parsed) return false;

  const found = await pool.query('SELECT * FROM payments WHERE payment_reference = $1', [parsed.reference]);
  if (found.rows[0]) await applyProviderResult(found.rows[0], parsed.result);
  return true;
};

module.exports = {
  startListingPayment,
  getLandlordPayment,
  listLandlordPayments,
  handleProviderWebhook,
  applyProviderResult,
};

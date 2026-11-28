const crypto = require('crypto');

// Lenco Pay API v2: https://lenco-api.readme.io/v2.0/reference
// Production base URL is documented; for the sandbox set LENCO_API_BASE_URL to the
// host Lenco gives you with your sandbox credentials.
const DEFAULT_BASE_URL = 'https://api.lenco.co/access/v2';
const REQUEST_TIMEOUT_MS = 20000;

const STATUS_MAP = {
  successful: 'successful',
  failed: 'failed',
  pending: 'pending',
  'pay-offline': 'pending', // waiting for the customer to approve on their phone
};

const createLencoProvider = ({
  apiToken = process.env.LENCO_API_TOKEN,
  baseUrl = process.env.LENCO_API_BASE_URL || DEFAULT_BASE_URL,
  fetchImpl = globalThis.fetch,
} = {}) => {
  if (!apiToken) throw new Error('LENCO_API_TOKEN is not set');
  const root = baseUrl.replace(/\/$/, '');

  // Webhook signatures: HMAC-SHA512 of the raw body, keyed with SHA-256(API token) as hex.
  const webhookKey = crypto.createHash('sha256').update(apiToken).digest('hex');

  const request = async (method, path, body) => {
    const response = await fetchImpl(`${root}${path}`, {
      method,
      headers: {
        Authorization: `Bearer ${apiToken}`,
        Accept: 'application/json',
        ...(body ? { 'Content-Type': 'application/json' } : {}),
      },
      body: body ? JSON.stringify(body) : undefined,
      signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
    });
    const payload = await response.json().catch(() => ({}));
    if (!response.ok || payload.status === false || !payload.data) {
      const error = new Error(payload.message || `Lenco request failed (${response.status})`);
      error.status = response.status;
      error.providerCode = payload.errorCode;
      throw error;
    }
    return payload.data;
  };

  const toResult = (data) => ({
    status: STATUS_MAP[data.status] || 'pending',
    providerReference: data.lencoReference || null,
    providerCollectionId: data.id || null,
    amount: data.amount != null ? Number(data.amount) : null,
    failureReason: data.reasonForFailure || null,
    raw: data,
  });

  return {
    name: 'lenco',

    async startCollection({ amount, reference, phone, operator }) {
      const data = await request('POST', '/collections/mobile-money', {
        amount,
        reference,
        phone,
        operator,
        country: 'zm',
        bearer: 'merchant',
      });
      return toResult(data);
    },

    async getCollection(reference) {
      return toResult(await request('GET', `/collections/status/${encodeURIComponent(reference)}`));
    },

    /** Returns the parsed event when the signature matches, otherwise null. */
    parseWebhook(rawBody, signature) {
      if (!Buffer.isBuffer(rawBody) || typeof signature !== 'string') return null;
      const expected = crypto.createHmac('sha512', webhookKey).update(rawBody).digest('hex');
      const given = signature.trim().toLowerCase();
      if (given.length !== expected.length ||
          !crypto.timingSafeEqual(Buffer.from(given), Buffer.from(expected))) {
        return null;
      }
      try {
        const event = JSON.parse(rawBody.toString('utf8'));
        if (!event?.data?.reference) return null;
        return { event: event.event, reference: event.data.reference, result: toResult(event.data) };
      } catch {
        return null;
      }
    },
  };
};

module.exports = { createLencoProvider };

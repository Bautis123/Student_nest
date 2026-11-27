// Simulated mobile money provider for local development and demos.
// Enabled only with PAYMENT_PROVIDER=mock. It never moves real money.
//
// Behaviour mirrors Lenco's sandbox test numbers: a number ending in 1111111
// (e.g. 0961111111, 0971111111) succeeds; any other number fails. The result
// is "pending" for the first few seconds, like a real phone approval prompt.

const APPROVAL_DELAY_MS = 6000;

const createMockProvider = ({ now = () => Date.now(), delayMs = APPROVAL_DELAY_MS } = {}) => {
  const collections = new Map();

  const resultFor = (reference) => {
    const entry = collections.get(reference);
    if (!entry) {
      const error = new Error('Payment details was not found');
      error.status = 404;
      throw error;
    }
    const settled = now() - entry.startedAt >= delayMs;
    const succeeds = entry.phone.endsWith('1111111');
    return {
      status: !settled ? 'pending' : succeeds ? 'successful' : 'failed',
      providerReference: entry.providerReference,
      providerCollectionId: null,
      amount: entry.amount,
      failureReason: settled && !succeeds ? 'Not enough funds (simulated)' : null,
      raw: null,
    };
  };

  return {
    name: 'mock',

    async startCollection({ amount, reference, phone }) {
      collections.set(reference, {
        amount,
        phone,
        startedAt: now(),
        providerReference: `MOCK-${collections.size + 1}`,
      });
      return resultFor(reference);
    },

    async getCollection(reference) {
      return resultFor(reference);
    },

    parseWebhook() {
      return null; // the mock never sends webhooks; status is read by polling
    },
  };
};

module.exports = { createMockProvider };

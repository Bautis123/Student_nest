const { createLencoProvider } = require('./lencoProvider');
const { createMockProvider } = require('./mockProvider');

let provider;

/**
 * The configured mobile money provider, or null when in-app payments are off.
 * PAYMENT_PROVIDER: "lenco" (needs LENCO_API_TOKEN) | "mock" | unset (disabled).
 */
const getPaymentProvider = () => {
  if (provider !== undefined) return provider;
  const name = (process.env.PAYMENT_PROVIDER || '').toLowerCase();
  if (name === 'lenco') provider = createLencoProvider();
  else if (name === 'mock') provider = createMockProvider();
  else provider = null;
  return provider;
};

// Tests swap in a fake provider.
const setPaymentProvider = (value) => {
  provider = value;
};

module.exports = { getPaymentProvider, setPaymentProvider };

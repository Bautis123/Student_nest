// Listing fees landlords pay to publish an approved property.
// Change prices here; the web app reads them from GET /api/payments/plans.
const LISTING_PLANS = Object.freeze({
  basic: Object.freeze({
    id: 'basic',
    name: 'Basic',
    amount: 300,
    currency: 'ZMW',
    months: 12,
    description: 'Your listing is visible to students for 12 months.',
  }),
  premium: Object.freeze({
    id: 'premium',
    name: 'Premium',
    amount: 750,
    currency: 'ZMW',
    months: 12,
    description: 'Featured placement and a Featured label for 12 months.',
  }),
});

const getPlan = (id) => LISTING_PLANS[id] || null;

module.exports = { LISTING_PLANS, getPlan };

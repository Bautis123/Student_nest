const { LISTING_PLANS } = require('../config/listingPlans');
const { getPaymentProvider } = require('../services/payments');
const paymentService = require('../services/paymentService');

const sendError = (res, err) => {
  if (err.status && err.status < 500) {
    return res.status(err.status).json({ message: err.message, ...(err.paymentId ? { payment_id: err.paymentId } : {}) });
  }
  if (err.status) return res.status(err.status).json({ message: err.message });
  console.error(err);
  return res.status(500).json({ message: 'Server error' });
};

const getPlans = (req, res) => {
  res.json({ plans: Object.values(LISTING_PLANS), enabled: Boolean(getPaymentProvider()) });
};

const startListingPayment = async (req, res) => {
  const { property_id, plan, phone, operator } = req.body || {};
  try {
    const payment = await paymentService.startListingPayment({
      landlordId: req.user.id,
      propertyId: property_id,
      planId: plan,
      phone,
      operator,
    });
    res.status(201).json({ payment });
  } catch (err) {
    sendError(res, err);
  }
};

const getPayment = async (req, res) => {
  try {
    res.json({ payment: await paymentService.getLandlordPayment({ landlordId: req.user.id, paymentId: req.params.id }) });
  } catch (err) {
    sendError(res, err);
  }
};

const listMyPayments = async (req, res) => {
  try {
    res.json({ payments: await paymentService.listLandlordPayments({ landlordId: req.user.id, propertyId: req.query.property_id }) });
  } catch (err) {
    sendError(res, err);
  }
};

// Mounted with express.raw() so the signature is checked against the exact bytes received.
const providerWebhook = async (req, res) => {
  try {
    const accepted = await paymentService.handleProviderWebhook(req.body, req.get('x-lenco-signature'));
    if (!accepted) return res.status(401).json({ message: 'Invalid signature' });
    res.status(200).json({ received: true });
  } catch (err) {
    // A non-2xx makes the provider retry later, which is what we want on a transient error.
    sendError(res, err);
  }
};

module.exports = { getPlans, startListingPayment, getPayment, listMyPayments, providerWebhook };

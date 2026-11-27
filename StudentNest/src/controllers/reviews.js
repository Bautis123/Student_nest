const reviews = require('../services/reviewService');
const { recordAdminLog } = require('../services/adminLogService');

const handle = (fn) => async (req, res) => {
  try {
    await fn(req, res);
  } catch (err) {
    if (err.status) return res.status(err.status).json({ message: err.message });
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// Public
const listForProperty = handle(async (req, res) => {
  res.json(await reviews.listForProperty(req.query.property_id));
});
const createReview = handle(async (req, res) => {
  const review = await reviews.createReview(req.body?.property_id, req.body);
  res.status(201).json({ review, message: 'Thank you! Our team will confirm your stay before your review appears.' });
});

// Landlord
const reply = handle(async (req, res) => {
  res.json({ review: await reviews.replyAsLandlord(req.params.id, req.user.id, req.body?.reply) });
});

// Admin
const adminList = handle(async (req, res) => {
  res.json({ reviews: await reviews.listForAdmin() });
});
const adminModerate = handle(async (req, res) => {
  const { status, note } = req.body || {};
  const review = await reviews.moderateReview(req.params.id, status, note);
  res.json({ review });
  await recordAdminLog(req, {
    action: status === 'approved' ? 'review_approved' : 'review_rejected',
    entityType: 'review',
    entityId: review.id,
    message: `${status === 'approved' ? 'Approved' : 'Rejected'} review by ${review.reviewer_name}`,
    metadata: { property_id: review.property_id, note: typeof note === 'string' && note.trim() ? note.trim().slice(0, 500) : undefined },
  });
});

module.exports = { listForProperty, createReview, reply, adminList, adminModerate };

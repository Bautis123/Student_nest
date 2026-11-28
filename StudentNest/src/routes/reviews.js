const express = require('express');
const router = express.Router();
const reviews = require('../controllers/reviews');
const { verifyToken, isLandlord } = require('../middleware/auth');

// GET /api/reviews?property_id=...   approved reviews and averages for a home
// POST /api/reviews                  a student submits a review (admin approves it)
// PUT /api/reviews/:id/reply         the home's landlord replies publicly
router.get('/', reviews.listForProperty);
router.post('/', reviews.createReview);
router.put('/:id/reply', verifyToken, isLandlord, reviews.reply);

module.exports = router;

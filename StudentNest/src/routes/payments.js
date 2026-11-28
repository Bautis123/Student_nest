const express = require('express');
const router = express.Router();
const payments = require('../controllers/payments');
const { verifyToken, isLandlord } = require('../middleware/auth');

// The provider webhook is mounted separately in app.js (it needs the raw body).

router.get('/plans', payments.getPlans);
router.post('/listing', verifyToken, isLandlord, payments.startListingPayment);
router.get('/mine', verifyToken, isLandlord, payments.listMyPayments);
router.get('/:id', verifyToken, isLandlord, payments.getPayment);

module.exports = router;

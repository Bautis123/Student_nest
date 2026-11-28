const express = require('express');
const router = express.Router();
const viewings = require('../controllers/viewings');
const { verifyToken, isLandlord } = require('../middleware/auth');

router.post('/', viewings.createRequest);
router.get('/mine', verifyToken, isLandlord, viewings.listMine);
router.patch('/:id', verifyToken, isLandlord, viewings.respond);

module.exports = router;

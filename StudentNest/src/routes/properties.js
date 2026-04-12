const express = require('express');
const router = express.Router();
const {
  createProperty,
  getProperties,
  getPropertyById,
  addRooms,
  trackContactClick,
  getMyProperties,
  getSchools,
  updateProperty,
  deletePropertyLandlord,
  updateRoomAvailability
} = require('../controllers/properties');
const { verifyToken, isLandlord } = require('../middleware/auth');

// Static routes first - before any :id routes
router.get('/schools', getSchools);
router.get('/landlord/my-properties', verifyToken, isLandlord, getMyProperties);

// Public routes
router.get('/', getProperties);
router.get('/:id', getPropertyById);
router.post('/:id/contact', trackContactClick);

// Landlord protected routes
router.post('/', verifyToken, isLandlord, createProperty);
router.post('/:property_id/rooms', verifyToken, isLandlord, addRooms);

//Available for landlords to update property details and room availability
router.patch('/rooms/:room_id', verifyToken, isLandlord, updateRoomAvailability);

module.exports = router;
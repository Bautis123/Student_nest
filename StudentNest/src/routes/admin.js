const express = require('express');
const router = express.Router();
const admin = require('../controllers/admin');
const { verifyToken, isAdmin } = require('../middleware/auth');
const roommates = require('../controllers/roommates');
const reviews = require('../controllers/reviews');
const listingReports = require('../controllers/listingReports');

// Every admin route requires an authenticated admin; owner-only checks live in the controller.
router.use(verifyToken, isAdmin);

// Own profile
router.get('/profile', admin.getAdminProfile);
router.patch('/profile', admin.updateAdminProfile);

// Admin accounts
router.get('/admins', admin.getAdmins);
router.get('/admins/:id/details', admin.getAdminDetails);
router.patch('/admins/:id/access', admin.updateAdminAccess);
router.delete('/admins/:id', admin.deleteAdmin);
router.post('/create-admin', admin.createAdmin);

// Dashboard
router.get('/stats', admin.getStats);
router.get('/logs', admin.getLogs);

// Landlords
router.get('/landlords', admin.getLandlords);
router.patch('/landlords/:id', admin.updateLandlordStatus);
router.patch('/landlords/:id/reset-password', admin.resetLandlordPassword);
router.delete('/landlords/:id', admin.deleteLandlord);

// Properties
router.get('/properties', admin.getProperties);
router.patch('/properties/:id', admin.updatePropertyStatus);
router.patch('/properties/:id/verification', admin.updatePropertyVerification);
router.patch('/properties/:id/listing-period', admin.extendListingPeriod);
router.delete('/properties/:id', admin.deleteProperty);

// Roommate posts (students)
router.get('/roommates', roommates.adminList);
router.patch('/roommates/:id', roommates.adminModerate);

// Tenant reviews
router.get('/reviews', reviews.adminList);
router.patch('/reviews/:id', reviews.adminModerate);

// Student reports about listings
router.get('/reports', listingReports.adminList);
router.patch('/reports/:propertyId', listingReports.adminResolve);

// Payments
router.get('/payments', admin.getPayments);
router.post('/payments', admin.recordPayment);

module.exports = router;

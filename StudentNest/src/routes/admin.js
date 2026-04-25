const express = require('express');
const router = express.Router();
const {
  getLandlords,
  updateLandlordStatus,
  getProperties,
  updatePropertyStatus,
  deleteProperty,
  getStats,
  createAdmin,
  updateLandlord,
  resetLandlordPassword,
  deleteLandlord,
  getPayments,
  recordPayment,
  getLogs,
  getAdminProfile,
  updateAdminProfile,
  getAdmins,
  getAdminDetails,
  updateAdminAccess,
  deleteAdmin
} = require('../controllers/admin');
const { verifyToken, isAdmin } = require('../middleware/auth');

// All admin routes are protected
router.use(verifyToken, isAdmin);

router.get('/profile', getAdminProfile);
router.patch('/profile', updateAdminProfile);
router.get('/admins', getAdmins);
router.get('/admins/:id/details', getAdminDetails);
router.patch('/admins/:id/access', updateAdminAccess);
router.delete('/admins/:id', deleteAdmin);
router.get('/stats', getStats);
router.get('/landlords', getLandlords);
router.patch('/landlords/:id', updateLandlordStatus);
router.get('/properties', getProperties);
router.patch('/properties/:id', updatePropertyStatus);
router.delete('/properties/:id', deleteProperty);
router.post('/create-admin', createAdmin);
router.patch('/landlords/:id', updateLandlord);
router.patch('/landlords/:id/reset-password', verifyToken, isAdmin, resetLandlordPassword);
router.delete('/landlords/:id', verifyToken, isAdmin, deleteLandlord);
router.get('/payments', verifyToken, isAdmin, getPayments);
router.post('/payments', verifyToken, isAdmin, recordPayment);
router.get('/logs', getLogs);

module.exports = router;

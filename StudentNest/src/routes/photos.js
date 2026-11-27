const express = require('express');
const multer = require('multer');
const router = express.Router();
const { uploadPhotos, deletePhoto, setCoverPhoto } = require('../controllers/photos');
const { verifyToken, isLandlord } = require('../middleware/auth');
const upload = require('../middleware/upload');

const MAX_PHOTOS_PER_UPLOAD = 10;

const handleUpload = (req, res, next) => {
  upload.array('photos', MAX_PHOTOS_PER_UPLOAD)(req, res, (err) => {
    if (!err) return next();

    console.error('Photo upload failed:', err.message);
    // Multer errors (too large, too many files) are the client's to fix; anything else is ours.
    if (err instanceof multer.MulterError) {
      return res.status(400).json({ message: err.message });
    }
    return res.status(500).json({ message: 'Photo upload failed. Please try again.' });
  });
};

router.post('/:property_id', verifyToken, isLandlord, handleUpload, uploadPhotos);
router.delete('/:photo_id', verifyToken, isLandlord, deletePhoto);
router.patch('/:photo_id/cover', verifyToken, isLandlord, setCoverPhoto);

module.exports = router;
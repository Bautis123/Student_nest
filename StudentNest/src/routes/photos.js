const express = require('express');
const router = express.Router();
const { uploadPhotos, deletePhoto, setCoverPhoto } = require('../controllers/photos');
const { verifyToken, isLandlord } = require('../middleware/auth');
const upload = require('../middleware/upload');

const handleUpload = (req, res, next) => {
  upload.array('photos', 10)(req, res, (err) => {
    if (err) {
      console.error('Multer/Cloudinary error:', err.message, JSON.stringify(err));
      return res.status(500).json({ message: err.message, details: err });
    }
    next();
  });
};

router.post('/:property_id', verifyToken, isLandlord, handleUpload, uploadPhotos);
router.delete('/:photo_id', verifyToken, isLandlord, deletePhoto);
router.patch('/:photo_id/cover', verifyToken, isLandlord, setCoverPhoto);

module.exports = router;
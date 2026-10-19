const pool = require('../config/db');
const cloudinary = require('../config/cloudinary');

// Upload photos for a property
const uploadPhotos = async (req, res) => {
  const { property_id } = req.params;
  const { is_cover } = req.body;
  const landlord_id = req.user.id;

  try {
    // Verify property belongs to this landlord
    const check = await pool.query(
      'SELECT id FROM properties WHERE id = $1 AND landlord_id = $2',
      [property_id, landlord_id]
    );

    if (check.rows.length === 0) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ message: 'No photos uploaded' });
    }

    // If this upload is marked as cover, unset any existing cover
    if (is_cover === 'true') {
      await pool.query(
        'UPDATE photos SET is_cover = false WHERE property_id = $1',
        [property_id]
      );
    }

    // Insert all uploaded photos
    const uploadedPhotos = [];
    for (let i = 0; i < req.files.length; i++) {
      const file = req.files[i];
      const isCover = is_cover === 'true' && i === 0;

      const result = await pool.query(
        `INSERT INTO photos (property_id, url, is_cover)
         VALUES ($1, $2, $3)
         RETURNING *`,
        [property_id, file.path, isCover]
      );

      uploadedPhotos.push(result.rows[0]);
    }

    res.status(201).json({
      message: 'Photos uploaded successfully',
      photos: uploadedPhotos
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// Delete a photo
const deletePhoto = async (req, res) => {
  const { photo_id } = req.params;
  const landlord_id = req.user.id;

  try {
    // Make sure this photo belongs to this landlord's property
    const result = await pool.query(
      `SELECT ph.* FROM photos ph
       JOIN properties p ON ph.property_id = p.id
       WHERE ph.id = $1 AND p.landlord_id = $2`,
      [photo_id, landlord_id]
    );

    if (result.rows.length === 0) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    const photo = result.rows[0];

    // Extract public_id from Cloudinary URL and delete from Cloudinary
    const urlParts = photo.url.split('/');
    const publicId = 'student_nest/' + urlParts[urlParts.length - 1].split('.')[0];
    await cloudinary.uploader.destroy(publicId);

    // Delete from database
    await pool.query('DELETE FROM photos WHERE id = $1', [photo_id]);

    res.json({ message: 'Photo deleted successfully' });

  } catch (err) {
    console.error('Full error:', err.message, err.http_code, err.name);
    res.status(500).json({ message: err.message || 'Server error' });
  }
};

const setCoverPhoto = async (req, res) => {
  const { photo_id } = req.params;
  const landlord_id = req.user.id;

  try {
    const check = await pool.query(
      `SELECT ph.* FROM photos ph
       JOIN properties p ON ph.property_id = p.id
       WHERE ph.id = $1 AND p.landlord_id = $2`,
      [photo_id, landlord_id]
    );

    if (check.rows.length === 0) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    // Unset all covers for this property
    await pool.query(
      'UPDATE photos SET is_cover = false WHERE property_id = $1',
      [check.rows[0].property_id]
    );

    // Set new cover
    await pool.query(
      'UPDATE photos SET is_cover = true WHERE id = $1',
      [photo_id]
    );

    res.json({ message: 'Cover photo updated' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = { uploadPhotos, deletePhoto, setCoverPhoto };

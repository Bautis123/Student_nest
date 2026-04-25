const pool = require('../config/db');

const suspendExpiredListings = async () => {
  const result = await pool.query(
    `UPDATE properties
     SET is_active = false, updated_at = NOW()
     WHERE is_active = true
       AND listing_expires_at IS NOT NULL
       AND listing_expires_at <= NOW()
     RETURNING id, title, listing_expires_at`
  );

  if (result.rows.length > 0) {
    console.log(`Suspended ${result.rows.length} expired listing(s)`);
  }

  return result.rows;
};

const startListingExpiryJob = () => {
  suspendExpiredListings().catch((err) => {
    console.error('Failed to suspend expired listings:', err);
  });

  const sixHours = 6 * 60 * 60 * 1000;
  setInterval(() => {
    suspendExpiredListings().catch((err) => {
      console.error('Failed to suspend expired listings:', err);
    });
  }, sixHours);
};

module.exports = {
  suspendExpiredListings,
  startListingExpiryJob,
};

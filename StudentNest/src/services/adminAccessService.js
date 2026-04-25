const pool = require('../config/db');

const ensureAdminAccessLevels = async () => {
  await pool.query(
    `ALTER TABLE users
     ADD COLUMN IF NOT EXISTS access_level VARCHAR(40)`
  );

  await pool.query(
    `UPDATE users
     SET access_level = 'manager'
     WHERE role = 'admin' AND access_level IS NULL`
  );

  const ownerResult = await pool.query(
    `SELECT id FROM users WHERE role = 'admin' AND access_level = 'owner' LIMIT 1`
  );

  if (ownerResult.rows.length > 0) return;

  const firstAdmin = await pool.query(
    `SELECT id FROM users
     WHERE role = 'admin'
     ORDER BY created_at ASC
     LIMIT 1`
  );

  if (firstAdmin.rows.length === 0) return;

  await pool.query(
    `UPDATE users SET access_level = 'owner' WHERE id = $1`,
    [firstAdmin.rows[0].id]
  );

  console.log('Assigned owner access to the first admin account');
};

module.exports = {
  ensureAdminAccessLevels,
};

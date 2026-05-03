const bcrypt = require('bcryptjs');
const pool = require('../src/config/db');

const required = ['ADMIN_FULL_NAME', 'ADMIN_PHONE', 'ADMIN_PASSWORD'];

const main = async () => {
  const missing = required.filter((key) => !process.env[key]);
  if (missing.length > 0) {
    throw new Error(`Missing required env vars: ${missing.join(', ')}`);
  }

  const fullName = process.env.ADMIN_FULL_NAME;
  const phone = process.env.ADMIN_PHONE;
  const email = process.env.ADMIN_EMAIL || null;
  const passwordHash = await bcrypt.hash(process.env.ADMIN_PASSWORD, 10);

  const existing = await pool.query(
    'SELECT id, phone FROM users WHERE phone = $1',
    [phone]
  );

  if (existing.rows.length > 0) {
    console.log(`Admin/user with phone ${phone} already exists.`);
    return;
  }

  const ownerCheck = await pool.query(
    "SELECT id FROM users WHERE role = 'admin' AND access_level = 'owner' LIMIT 1"
  );

  const accessLevel = ownerCheck.rows.length === 0 ? 'owner' : 'manager';

  const result = await pool.query(
    `INSERT INTO users
      (full_name, phone, email, password_hash, role, is_approved, access_level)
     VALUES ($1, $2, $3, $4, 'admin', true, $5)
     RETURNING id, full_name, phone, email, access_level`,
    [fullName, phone, email, passwordHash, accessLevel]
  );

  console.log('Created admin:', result.rows[0]);
};

main()
  .catch((err) => {
    console.error(err.message);
    process.exitCode = 1;
  })
  .finally(async () => {
    await pool.end();
  });

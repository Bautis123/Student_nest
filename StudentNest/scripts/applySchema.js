const fs = require('fs');
const path = require('path');
const pool = require('../src/config/db');

const main = async () => {
  const schemaPath = path.join(__dirname, '../database/schema.sql');
  const schema = fs.readFileSync(schemaPath, 'utf8');

  await pool.query(schema);
  console.log('Database schema applied successfully.');
};

main()
  .catch((err) => {
    console.error('Failed to apply database schema:', err.message);
    process.exitCode = 1;
  })
  .finally(async () => {
    await pool.end();
  });

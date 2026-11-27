const { Pool, types } = require('pg');
require('dotenv').config();

// Return DATE columns (move-in days, viewing days, stay months) as plain
// "YYYY-MM-DD" strings. By default pg turns them into a Date at the server's
// local midnight, which serialises to the previous day in UTC whenever the
// server runs ahead of UTC (Zambia is UTC+2). TIMESTAMP columns are unaffected.
const DATE_OID = 1082;
types.setTypeParser(DATE_OID, (value) => value);

const poolConfig = process.env.DATABASE_URL
  ? {
      connectionString: process.env.DATABASE_URL,
      ssl:
        process.env.DB_SSL === 'false'
          ? false
          : { rejectUnauthorized: false },
    }
  : {
      host: process.env.DB_HOST,
      port: process.env.DB_PORT,
      database: process.env.DB_NAME,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
    };

const pool = new Pool(poolConfig);

pool.connect()
  .then((client) => {
    client.release();
    console.log('PostgreSQL connected successfully');
  })
  .catch((err) => console.error('Database connection error:', err));

module.exports = pool;

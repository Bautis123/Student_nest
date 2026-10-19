// Read-only launch diagnostic. Never prints connection strings or credentials.
require('dotenv').config({ quiet: true });
const { Pool } = require('pg');
const connection = process.env.DATABASE_URL
  ? { connectionString: process.env.DATABASE_URL, ssl: process.env.DB_SSL === 'false' ? false : { rejectUnauthorized: false } }
  : { host: process.env.DB_HOST, port: process.env.DB_PORT, database: process.env.DB_NAME, user: process.env.DB_USER, password: process.env.DB_PASSWORD };
const pool = new Pool({ ...connection, connectionTimeoutMillis: 8000, query_timeout: 8000 });
pool.query("SELECT to_regclass('public.schools') IS NOT NULL AS schools_exists, to_regclass('public.properties') IS NOT NULL AS properties_exists")
  .then(result => console.log(JSON.stringify(result.rows[0])))
  .catch(error => {
    console.error(`Read-only database check failed; code: ${error.code || 'connection timeout'}`);
    process.exitCode = 1;
  })
  .finally(() => pool.end());

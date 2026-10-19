// One-time setup for a fresh Supabase database; leaves existing app tables alone.
const fs = require('fs');
const path = require('path');
const { Pool } = require('pg');
require('dotenv').config({ quiet: true });

const tables = ['users', 'schools', 'properties', 'rooms', 'photos', 'payments', 'admin_logs'];
async function main() {
  const url = new URL(process.env.DATABASE_URL);
  if (!url.hostname.endsWith('.supabase.com') && !url.hostname.endsWith('.supabase.co')) {
    throw new Error('Expected a Supabase database target');
  }
  const pool = new Pool({ connectionString: url.href, ssl: { rejectUnauthorized: false }, connectionTimeoutMillis: 10000, query_timeout: 30000 });
  let client;
  try {
    client = await pool.connect();
    await client.query('BEGIN');
    const existing = await client.query('SELECT tablename FROM pg_tables WHERE schemaname = $1 AND tablename = ANY($2::text[])', ['public', tables]);
    if (existing.rows.length) throw new Error('App tables already exist; setup stopped to preserve existing data');
    await client.query("SET LOCAL search_path TO public, extensions");
    await client.query(fs.readFileSync(path.join(__dirname, '../database/schema.sql'), 'utf8'));
    // Access is through Express and its own JWT roles, not the Supabase Data API.
    for (const table of tables) {
      await client.query(`ALTER TABLE public.${table} ENABLE ROW LEVEL SECURITY`);
      await client.query(`REVOKE ALL ON TABLE public.${table} FROM PUBLIC, anon, authenticated`);
    }
    await client.query('REVOKE ALL ON SEQUENCE public.admin_logs_id_seq FROM PUBLIC, anon, authenticated');
    await client.query('COMMIT');
    console.log('Created 7 Student Nest tables and 4 campuses; browser API roles have no table access.');
  } catch (error) {
    if (client) await client.query('ROLLBACK').catch(() => {});
    throw error;
  } finally {
    client?.release();
    await pool.end();
  }
}
main().catch(error => { console.error('Supabase setup failed:', error.code || error.message); process.exitCode = 1; });

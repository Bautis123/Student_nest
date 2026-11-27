// Explicit demo records for launch testing.
// Re-running is safe: it never duplicates, and it refreshes the demo listings so
// they are approved, active and visible again for the chosen number of days.
//   node scripts/seedTestListings.js            -> visible for 7 days
//   node scripts/seedTestListings.js --days=30  -> visible for 30 days (max 90)
require('dotenv').config({ quiet: true });
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
const { randomBytes } = require('crypto');
const ownerId = 'ea7b7b35-7379-427c-a4bf-54a52b947100';
const DEFAULT_DAYS = 7;
const MAX_DAYS = 90;
const daysArg = process.argv.find(arg => arg.startsWith('--days='))?.split('=')[1] ?? process.env.DEMO_LISTING_DAYS;
const days = daysArg === undefined ? DEFAULT_DAYS : Number(daysArg);
if (!Number.isInteger(days) || days < 1 || days > MAX_DAYS) {
  console.error(`--days must be a whole number from 1 to ${MAX_DAYS}`);
  process.exit(1);
}
const listings = [
  { id: 'ea7b7b35-7379-427c-a4bf-54a52b947101', title: 'TEST — Campus Twin Room', school: 'UNZA', rent: 950, occupants: 2, rooms: 4, available: 3, amenities: { furnished: true, water: true, electricity: true, security: true } },
  { id: 'ea7b7b35-7379-427c-a4bf-54a52b947102', title: 'TEST — Modern Study Residence', school: 'Copperbelt University', rent: 1500, occupants: 2, rooms: 3, available: 2, amenities: { furnished: true, wifi: true, water: true, electricity: true, kitchen: true } },
  { id: 'ea7b7b35-7379-427c-a4bf-54a52b947103', title: 'TEST — Budget Single Room', school: 'Mulungushi University', rent: 600, occupants: 1, rooms: 2, available: 1, amenities: { furnished: true, water: true, electricity: true } },
];
async function main() {
  const url = new URL(process.env.DATABASE_URL);
  if (url.username !== 'postgres.jmlrrdfrgrjhqdxzlebq') throw new Error('Unexpected database target');
  const pool = new Pool({ connectionString: url.href, ssl: { rejectUnauthorized: false }, connectionTimeoutMillis: 10000 });
  let client;
  try {
    client = await pool.connect();
    await client.query('BEGIN');
    const hash = await bcrypt.hash(randomBytes(32).toString('hex'), 10);
    await client.query(`INSERT INTO users (id, full_name, phone, password_hash, role, is_approved)
      VALUES ($1, 'Student Nest Test Fixtures', '', $2, 'landlord', false) ON CONFLICT (id) DO NOTHING`, [ownerId, hash]);
    for (const item of listings) {
      const result = await client.query('SELECT * FROM schools WHERE name=$1 ORDER BY created_at LIMIT 1', [item.school]);
      const school = result.rows[0];
      if (!school) throw new Error('Missing campus: ' + item.school);
      const inserted = await client.query(`INSERT INTO properties
        (id, landlord_id, title, description, address, latitude, longitude, nearest_school_id, distance_from_school, amenities, is_approved, is_active, listing_expires_at)
        VALUES ($1,$2,$3,$4,$5,$6,$7,$8,0,$9,true,true,NOW() + make_interval(days => $10))
        ON CONFLICT (id) DO UPDATE SET
          description = EXCLUDED.description,
          is_approved = true,
          is_active = true,
          listing_expires_at = EXCLUDED.listing_expires_at,
          updated_at = NOW()
        RETURNING (xmax = 0) AS inserted, listing_expires_at`, [item.id, ownerId, item.title,
        `DEMO ONLY — fictional test accommodation, not available to rent. Prices, availability, amenities and the campus-based map pin are sample data. Do not travel to this location or make a payment. Automatically expires after ${days} day${days === 1 ? '' : 's'}.`,
        `Demo location only — ${school.name} campus area`, school.latitude, school.longitude, school.id, JSON.stringify(item.amenities), days]);
      const { inserted: isNew, listing_expires_at: expiresAt } = inserted.rows[0];
      console.log(`${isNew ? 'Created' : 'Refreshed'}: ${item.title} (visible until ${new Date(expiresAt).toISOString().slice(0, 10)})`);
      if (isNew) await client.query(`INSERT INTO rooms (property_id,room_type,price_per_month,students_per_room,total_rooms,available_rooms)
        VALUES ($1,$2,$3,$4,$5,$6)`, [item.id, item.occupants === 1 ? 'Single room (test)' : 'Twin sharing (test)', item.rent, item.occupants, item.rooms, item.available]);
    }
    await client.query('COMMIT');
    console.log(`Three demo listings are visible to students for ${days} day${days === 1 ? '' : 's'}. No payments or real contact details created.`);
  } catch (error) {
    if (client) await client.query('ROLLBACK').catch(() => {});
    throw error;
  } finally { client?.release(); await pool.end(); }
}
main().catch(error => { console.error('Test seed failed:', error.code || error.message); process.exitCode = 1; });

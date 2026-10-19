// Explicit demo records for launch testing. Re-running does not create duplicates.
require('dotenv').config({ quiet: true });
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
const { randomBytes } = require('crypto');
const ownerId = 'ea7b7b35-7379-427c-a4bf-54a52b947100';
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
        VALUES ($1,$2,$3,$4,$5,$6,$7,$8,0,$9,true,true,NOW()+INTERVAL '7 days')
        ON CONFLICT (id) DO NOTHING RETURNING id`, [item.id, ownerId, item.title,
        'DEMO ONLY — fictional test accommodation, not available to rent. Prices, availability, amenities and the campus-based map pin are sample data. Do not travel to this location or make a payment. Automatically expires after seven days.',
        `Demo location only — ${school.name} campus area`, school.latitude, school.longitude, school.id, JSON.stringify(item.amenities)]);
      if (inserted.rows.length) await client.query(`INSERT INTO rooms (property_id,room_type,price_per_month,students_per_room,total_rooms,available_rooms)
        VALUES ($1,$2,$3,$4,$5,$6)`, [item.id, item.occupants === 1 ? 'Single room (test)' : 'Twin sharing (test)', item.rent, item.occupants, item.rooms, item.available]);
    }
    await client.query('COMMIT');
    console.log('Three test listings are present. No payments or real contact details created.');
    for (const item of listings) console.log(item.title + ': ' + item.id);
  } catch (error) {
    if (client) await client.query('ROLLBACK').catch(() => {});
    throw error;
  } finally { client?.release(); await pool.end(); }
}
main().catch(error => { console.error('Test seed failed:', error.code || error.message); process.exitCode = 1; });

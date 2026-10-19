require('dotenv').config({ quiet: true });
const fs = require('fs');
const path = require('path');
const { Pool } = require('pg');
const cloudinary = require('cloudinary').v2;

const owner = 'ea7b7b35-7379-427c-a4bf-54a52b947100';
const photos = [
  ['twin', 'ea7b7b35-7379-427c-a4bf-54a52b947101'],
  ['modern', 'ea7b7b35-7379-427c-a4bf-54a52b947102'],
  ['single', 'ea7b7b35-7379-427c-a4bf-54a52b947103'],
];
async function main() {
  const url = new URL(process.env.DATABASE_URL);
  if (url.username !== 'postgres.jmlrrdfrgrjhqdxzlebq') throw new Error('Unexpected database target');
  for (const key of ['CLOUDINARY_CLOUD_NAME', 'CLOUDINARY_API_KEY', 'CLOUDINARY_API_SECRET']) {
    if (!process.env[key]) throw new Error('Missing ' + key);
  }
  for (const [name] of photos) fs.accessSync(path.join(__dirname, '../../test-listing-photos', name + '.png'));
  cloudinary.config({ cloud_name: process.env.CLOUDINARY_CLOUD_NAME, api_key: process.env.CLOUDINARY_API_KEY, api_secret: process.env.CLOUDINARY_API_SECRET });
  const pool = new Pool({ connectionString: url.href, ssl: { rejectUnauthorized: false }, connectionTimeoutMillis: 10000, query_timeout: 20000 });
  let client;
  try {
    client = await pool.connect();
    const targets = await client.query('SELECT id FROM properties WHERE id=ANY($1::uuid[]) AND landlord_id=$2 AND title LIKE $3', [photos.map(p => p[1]), owner, 'TEST%']);
    if (targets.rows.length !== photos.length) throw new Error('Expected test listings are missing');
    const uploaded = [];
    for (const [name, propertyId] of photos) {
      // Stable IDs make retries reuse the same assets without duplicate uploads.
      const image = await cloudinary.uploader.upload(path.join(__dirname, '../../test-listing-photos', name + '.png'), {
        public_id: 'student_nest/test-listing-' + name,
        overwrite: false,
        resource_type: 'image',
        timeout: 60000,
      });
      uploaded.push({ name, propertyId, url: image.secure_url });
      console.log('Uploaded ' + name + ' photo');
    }
    await client.query('BEGIN');
    for (const photo of uploaded) {
      await client.query('UPDATE photos SET is_cover=false WHERE property_id=$1', [photo.propertyId]);
      const existing = await client.query('SELECT id FROM photos WHERE property_id=$1 AND url=$2 ORDER BY id LIMIT 1', [photo.propertyId, photo.url]);
      if (existing.rows.length) await client.query('UPDATE photos SET is_cover=true WHERE id=$1', [existing.rows[0].id]);
      else await client.query('INSERT INTO photos (property_id,url,is_cover) VALUES ($1,$2,true)', [photo.propertyId, photo.url]);
    }
    await client.query('COMMIT');
    const check = await client.query('SELECT p.title, count(ph.id)::int AS covers FROM properties p JOIN photos ph ON ph.property_id=p.id AND ph.is_cover WHERE p.id=ANY($1::uuid[]) GROUP BY p.id', [photos.map(p => p[1])]);
    if (check.rows.length !== 3 || check.rows.some(row => row.covers !== 1)) throw new Error('Cover verification failed');
    console.log(JSON.stringify(check.rows));
  } catch (error) {
    if (client) await client.query('ROLLBACK').catch(() => {});
    throw error;
  } finally { client?.release(); await pool.end(); }
}
main().catch(error => { console.error('Photo attachment failed:', error.code || error.http_code || error.message); process.exitCode = 1; });

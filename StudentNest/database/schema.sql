-- Student Nest PostgreSQL bootstrap schema
-- Run from psql after creating the database:
--   psql -U postgres -d student_nest -f StudentNest/database/schema.sql

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name VARCHAR(160) NOT NULL,
  phone VARCHAR(40) NOT NULL UNIQUE,
  email VARCHAR(160),
  password_hash TEXT NOT NULL,
  role VARCHAR(30) NOT NULL DEFAULT 'landlord'
    CHECK (role IN ('landlord', 'admin')),
  is_approved BOOLEAN NOT NULL DEFAULT false,
  access_level VARCHAR(40)
    CHECK (access_level IS NULL OR access_level IN ('owner', 'manager')),
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS schools (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(180) NOT NULL,
  area VARCHAR(180),
  latitude NUMERIC(10, 7) NOT NULL,
  longitude NUMERIC(10, 7) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS properties (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  landlord_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(220) NOT NULL,
  description TEXT,
  address TEXT NOT NULL,
  latitude NUMERIC(10, 7) NOT NULL,
  longitude NUMERIC(10, 7) NOT NULL,
  nearest_school_id UUID REFERENCES schools(id) ON DELETE SET NULL,
  distance_from_school NUMERIC(8, 2),
  amenities JSONB NOT NULL DEFAULT '{}'::jsonb,
  is_approved BOOLEAN NOT NULL DEFAULT false,
  is_active BOOLEAN NOT NULL DEFAULT false,
  listing_expires_at TIMESTAMP,
  -- Set when an admin has inspected the property or checked proof of ownership.
  -- Who verified it, and any note, is kept in admin_logs.
  verified_at TIMESTAMP,
  view_count INTEGER NOT NULL DEFAULT 0,
  contact_click_count INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS rooms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  room_type VARCHAR(120) NOT NULL,
  price_per_month NUMERIC(12, 2) NOT NULL,
  students_per_room INTEGER NOT NULL DEFAULT 1,
  total_rooms INTEGER NOT NULL DEFAULT 1,
  available_rooms INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  url TEXT NOT NULL,
  is_cover BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  landlord_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  amount NUMERIC(12, 2) NOT NULL,
  payment_method VARCHAR(60),
  mobile_money_provider VARCHAR(40),
  bank_name VARCHAR(120),
  payment_reference TEXT,
  reference TEXT,
  transaction_reference TEXT,
  duration_months INTEGER NOT NULL DEFAULT 12,
  status VARCHAR(40) NOT NULL DEFAULT 'confirmed'
    CHECK (status IN ('pending', 'confirmed', 'failed')),
  paid_at TIMESTAMP,
  expires_at TIMESTAMP,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS admin_logs (
  id BIGSERIAL PRIMARY KEY,
  admin_id UUID REFERENCES users(id) ON DELETE SET NULL,
  admin_access_level VARCHAR(40),
  action VARCHAR(80) NOT NULL,
  entity_type VARCHAR(80) NOT NULL,
  entity_id TEXT,
  status VARCHAR(40) DEFAULT 'success',
  message TEXT,
  metadata JSONB DEFAULT '{}'::jsonb,
  ip_address TEXT,
  user_agent TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_properties_landlord ON properties(landlord_id);
CREATE INDEX IF NOT EXISTS idx_properties_school ON properties(nearest_school_id);
CREATE INDEX IF NOT EXISTS idx_properties_visible
  ON properties(is_approved, is_active, listing_expires_at);
CREATE INDEX IF NOT EXISTS idx_rooms_property ON rooms(property_id);
CREATE INDEX IF NOT EXISTS idx_photos_property ON photos(property_id);
CREATE INDEX IF NOT EXISTS idx_payments_property ON payments(property_id);
CREATE INDEX IF NOT EXISTS idx_payments_landlord ON payments(landlord_id);
CREATE INDEX IF NOT EXISTS idx_admin_logs_admin ON admin_logs(admin_id);
CREATE INDEX IF NOT EXISTS idx_admin_logs_created_at ON admin_logs(created_at);

INSERT INTO schools (name, area, latitude, longitude)
VALUES
  ('UNZA', 'Great East Road, Lusaka', -15.3947220, 28.3322220),
  ('Copperbelt University', 'Riverside, Kitwe', -12.8058000, 28.2406000),
  ('Mulungushi University', 'Kabwe', -14.4458000, 28.4469000),
  ('Levy Mwanawasa Medical University', 'Chainama, Lusaka', -15.3906000, 28.3807000)
ON CONFLICT DO NOTHING;

-- Create the first admin through a short Node script or insert a bcrypt hash here.
-- The backend automatically promotes the first admin to owner if no owner exists.

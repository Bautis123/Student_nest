// Viewing requests from students to landlords. Shared by database/schema.sql and
// the startup migration.
const VIEWING_TABLES_SQL = `
CREATE TABLE IF NOT EXISTS viewing_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  student_name VARCHAR(60) NOT NULL,
  student_phone VARCHAR(20) NOT NULL,
  preferred_date DATE NOT NULL,
  preferred_time VARCHAR(20) NOT NULL CHECK (preferred_time IN ('morning', 'afternoon', 'evening')),
  message TEXT,
  status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'declined')),
  landlord_note TEXT,
  notify_status VARCHAR(20) NOT NULL DEFAULT 'skipped' CHECK (notify_status IN ('sent', 'failed', 'skipped')),
  notify_error TEXT,
  responded_at TIMESTAMP,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_viewing_requests_property ON viewing_requests(property_id, status);
CREATE UNIQUE INDEX IF NOT EXISTS idx_viewing_requests_one_pending
  ON viewing_requests(property_id, student_phone) WHERE status = 'pending';
`;

module.exports = { VIEWING_TABLES_SQL };

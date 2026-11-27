// Roommate matching tables. Kept in one place so database/schema.sql and the
// startup migration (schemaService) create exactly the same structure.
const ROOMMATE_TABLES_SQL = `
CREATE TABLE IF NOT EXISTS roommate_posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  display_name VARCHAR(60) NOT NULL,
  gender VARCHAR(20) NOT NULL CHECK (gender IN ('female', 'male', 'unspecified')),
  share_with VARCHAR(20) NOT NULL DEFAULT 'any' CHECK (share_with IN ('female', 'male', 'any')),
  school_id UUID REFERENCES schools(id) ON DELETE SET NULL,
  budget_max NUMERIC(12, 2) NOT NULL CHECK (budget_max > 0),
  move_in DATE,
  about TEXT,
  tags JSONB NOT NULL DEFAULT '[]'::jsonb,
  phone VARCHAR(20) NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'approved', 'rejected', 'removed')),
  review_note TEXT,
  manage_token_hash CHAR(64) NOT NULL UNIQUE,
  report_count INTEGER NOT NULL DEFAULT 0,
  contact_views INTEGER NOT NULL DEFAULT 0,
  approved_at TIMESTAMP,
  expires_at TIMESTAMP,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_roommate_posts_visible ON roommate_posts(status, expires_at);
CREATE INDEX IF NOT EXISTS idx_roommate_posts_phone ON roommate_posts(phone);

CREATE TABLE IF NOT EXISTS roommate_reports (
  id BIGSERIAL PRIMARY KEY,
  post_id UUID NOT NULL REFERENCES roommate_posts(id) ON DELETE CASCADE,
  reason TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_roommate_reports_post ON roommate_reports(post_id);
`;

module.exports = { ROOMMATE_TABLES_SQL };

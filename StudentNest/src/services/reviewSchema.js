// Tenant reviews. Shared by database/schema.sql and the startup migration.
const REVIEW_TABLES_SQL = `
CREATE TABLE IF NOT EXISTS reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  reviewer_name VARCHAR(60) NOT NULL DEFAULT 'Student',
  phone VARCHAR(20) NOT NULL,
  stay_from DATE NOT NULL,
  stay_to DATE,
  rating_overall SMALLINT NOT NULL CHECK (rating_overall BETWEEN 1 AND 5),
  rating_landlord SMALLINT NOT NULL CHECK (rating_landlord BETWEEN 1 AND 5),
  rating_utilities SMALLINT NOT NULL CHECK (rating_utilities BETWEEN 1 AND 5),
  rating_security SMALLINT NOT NULL CHECK (rating_security BETWEEN 1 AND 5),
  rating_value SMALLINT NOT NULL CHECK (rating_value BETWEEN 1 AND 5),
  comment TEXT NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  review_note TEXT,
  landlord_reply TEXT,
  landlord_reply_at TIMESTAMP,
  approved_at TIMESTAMP,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_reviews_property_status ON reviews(property_id, status);
CREATE UNIQUE INDEX IF NOT EXISTS idx_reviews_one_per_phone
  ON reviews(property_id, phone) WHERE status <> 'rejected';
`;

module.exports = { REVIEW_TABLES_SQL };

// Student reports about listings (possible scams). Shared by database/schema.sql
// and the startup migration.
const LISTING_REPORT_TABLES_SQL = `
ALTER TABLE properties ADD COLUMN IF NOT EXISTS flagged_at TIMESTAMP;

CREATE TABLE IF NOT EXISTS listing_reports (
  id BIGSERIAL PRIMARY KEY,
  property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  reason VARCHAR(40) NOT NULL
    CHECK (reason IN ('fake_listing', 'upfront_payment', 'misleading', 'impersonation', 'other')),
  details TEXT,
  reporter_phone VARCHAR(20),
  status VARCHAR(20) NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'resolved', 'dismissed')),
  resolution_note TEXT,
  resolved_by UUID REFERENCES users(id) ON DELETE SET NULL,
  resolved_at TIMESTAMP,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_listing_reports_property_status ON listing_reports(property_id, status);
CREATE UNIQUE INDEX IF NOT EXISTS idx_listing_reports_one_open_per_phone
  ON listing_reports(property_id, reporter_phone) WHERE status = 'open' AND reporter_phone IS NOT NULL;
`;

module.exports = { LISTING_REPORT_TABLES_SQL };

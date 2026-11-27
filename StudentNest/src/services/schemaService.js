const pool = require('../config/db');
const { ensureAdminLogsTable } = require('./adminLogService');
const { ensureAdminAccessLevels } = require('./adminAccessService');

// Columns added to `payments` after the first production deploy. New databases
// get them from database/schema.sql; this keeps older databases in step.
const ensurePaymentColumns = () =>
  pool.query(
    `ALTER TABLE payments
     ADD COLUMN IF NOT EXISTS payment_reference TEXT,
     ADD COLUMN IF NOT EXISTS reference TEXT,
     ADD COLUMN IF NOT EXISTS transaction_reference TEXT,
     ADD COLUMN IF NOT EXISTS mobile_money_provider VARCHAR(40),
     ADD COLUMN IF NOT EXISTS bank_name VARCHAR(120),
     ADD COLUMN IF NOT EXISTS duration_months INTEGER,
     ADD COLUMN IF NOT EXISTS paid_at TIMESTAMP,
     ADD COLUMN IF NOT EXISTS expires_at TIMESTAMP`
  );

const ensurePropertyVerificationColumn = () =>
  pool.query(
    `ALTER TABLE properties
     ADD COLUMN IF NOT EXISTS verified_at TIMESTAMP`
  );

/**
 * Idempotent runtime migrations. Run once at startup, before the server
 * accepts requests, so request handlers never need to issue DDL.
 */
const prepareDatabase = async () => {
  await ensureAdminLogsTable();
  await ensureAdminAccessLevels();
  await ensurePaymentColumns();
  await ensurePropertyVerificationColumn();
};

module.exports = { prepareDatabase };

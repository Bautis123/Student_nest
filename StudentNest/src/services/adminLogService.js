const pool = require('../config/db');

const ensureAdminLogsTable = async () => {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS admin_logs (
      id BIGSERIAL PRIMARY KEY,
      admin_id UUID,
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
    )
  `);
};

const recordAdminLog = async (req, log) => {
  try {
    await ensureAdminLogsTable();
    await pool.query(
      `ALTER TABLE admin_logs
       ADD COLUMN IF NOT EXISTS admin_access_level VARCHAR(40)`
    );

    await pool.query(
      `INSERT INTO admin_logs
        (admin_id, admin_access_level, action, entity_type, entity_id, status, message, metadata, ip_address, user_agent)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
      [
        req.user?.id || null,
        req.user?.access_level || null,
        log.action,
        log.entityType,
        log.entityId ? String(log.entityId) : null,
        log.status || 'success',
        log.message || null,
        JSON.stringify(log.metadata || {}),
        req.ip || null,
        req.get('user-agent') || null,
      ]
    );
  } catch (err) {
    console.error('Failed to write admin log:', err.message);
  }
};

const getAdminLogs = async ({
  search,
  action,
  entityType,
  status,
  dateFrom,
  dateTo,
  limit = 100,
}) => {
  await ensureAdminLogsTable();

  const conditions = [];
  const params = [];

  const addParam = (value) => {
    params.push(value);
    return `$${params.length}`;
  };

  if (search) {
    const ref = addParam(`%${search}%`);
    conditions.push(
      `(message ILIKE ${ref}
        OR action ILIKE ${ref}
        OR entity_type ILIKE ${ref}
        OR entity_id ILIKE ${ref}
        OR metadata::text ILIKE ${ref})`
    );
  }

  if (action && action !== 'all') {
    conditions.push(`action = ${addParam(action)}`);
  }

  if (entityType && entityType !== 'all') {
    conditions.push(`entity_type = ${addParam(entityType)}`);
  }

  if (status && status !== 'all') {
    conditions.push(`status = ${addParam(status)}`);
  }

  if (dateFrom) {
    conditions.push(`created_at >= ${addParam(dateFrom)}`);
  }

  if (dateTo) {
    conditions.push(`created_at < (${addParam(dateTo)}::date + INTERVAL '1 day')`);
  }

  const whereClause = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
  const safeLimit = Math.min(Math.max(Number(limit) || 100, 1), 500);

  const result = await pool.query(
    `SELECT l.*, u.full_name AS admin_name, u.phone AS admin_phone
     FROM admin_logs l
     LEFT JOIN users u ON l.admin_id = u.id
     ${whereClause}
     ORDER BY l.created_at DESC
     LIMIT ${safeLimit}`,
    params
  );

  return result.rows;
};

module.exports = {
  ensureAdminLogsTable,
  recordAdminLog,
  getAdminLogs,
};

const bcrypt = require('bcryptjs');
const pool = require('../config/db');
const { getAdminLogs, recordAdminLog } = require('../services/adminLogService');

const MIN_PASSWORD_LENGTH = 6;
const DEFAULT_LISTING_MONTHS = 12;

const isValidPassword = (password) =>
  typeof password === 'string' && password.length >= MIN_PASSWORD_LENGTH;

const normalizeAccessLevel = (level) => (level === 'owner' ? 'owner' : 'manager');

const isOwner = (user) =>
  user?.role === 'admin' && user?.access_level === 'owner';

// Get all landlords (pending and approved)
const getLandlords = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT id, full_name, phone, email, is_approved, created_at
       FROM users
       WHERE role = 'landlord'
       ORDER BY created_at DESC`
    );

    res.json({
      count: result.rows.length,
      landlords: result.rows
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// Approve or reject a landlord
const updateLandlordStatus = async (req, res) => {
  const { id } = req.params;
  const { is_approved } = req.body;

  try {
    const result = await pool.query(
      `UPDATE users SET is_approved = $1
       WHERE id = $2 AND role = 'landlord'
       RETURNING id, full_name, phone, is_approved`,
      [is_approved, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Landlord not found' });
    }

    res.json({
      message: is_approved ? 'Landlord approved' : 'Landlord rejected',
      landlord: result.rows[0]
    });

    await recordAdminLog(req, {
      action: is_approved ? 'landlord_approved' : 'landlord_suspended',
      entityType: 'landlord',
      entityId: id,
      message: is_approved ? 'Approved landlord account' : 'Suspended landlord account',
      metadata: { landlord: result.rows[0] },
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get all properties (pending and approved)
const getProperties = async (req, res) => {
  const { status } = req.query; // 'pending' or 'approved'

  try {
    let query = `
      SELECT 
        p.*,
        u.full_name AS landlord_name,
        u.phone AS landlord_phone,
        s.name AS school_name,
        COALESCE(room_counts.room_types, 0) AS room_types,
        COALESCE(photo_counts.photo_count, 0) AS photo_count,
        COALESCE(photo_lists.photos, '[]') AS photos
      FROM properties p
      LEFT JOIN users u ON p.landlord_id = u.id
      LEFT JOIN schools s ON p.nearest_school_id = s.id
      LEFT JOIN (
        SELECT property_id, COUNT(*) AS room_types
        FROM rooms
        GROUP BY property_id
      ) room_counts ON p.id = room_counts.property_id
      LEFT JOIN (
        SELECT property_id, COUNT(*) AS photo_count
        FROM photos
        GROUP BY property_id
      ) photo_counts ON p.id = photo_counts.property_id
      LEFT JOIN (
        SELECT
          property_id,
          JSON_AGG(
            JSON_BUILD_OBJECT(
              'id', id,
              'url', url,
              'is_cover', is_cover
            )
            ORDER BY is_cover DESC, id ASC
          ) AS photos
        FROM photos
        GROUP BY property_id
      ) photo_lists ON p.id = photo_lists.property_id
    `;

    if (status === 'pending') {
      query += ` WHERE p.is_approved = false`;
    } else if (status === 'approved') {
      query += ` WHERE p.is_approved = true`;
    }

    query += ` ORDER BY p.created_at DESC`;

    const result = await pool.query(query);

    res.json({
      count: result.rows.length,
      properties: result.rows
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// Approve or reject a property
const updatePropertyStatus = async (req, res) => {
  const { id } = req.params;
  const { is_approved } = req.body;

  try {
    const result = await pool.query(
      `UPDATE properties SET
         is_approved = $1,
         -- A rejected listing loses its verified badge; it must be re-checked.
         verified_at = CASE WHEN $1 THEN verified_at ELSE NULL END,
         updated_at = NOW()
       WHERE id = $2
       RETURNING id, title, is_approved`,
      [is_approved, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Property not found' });
    }

    res.json({
      message: is_approved ? 'Property approved' : 'Property rejected',
      property: result.rows[0]
    });

    await recordAdminLog(req, {
      action: is_approved ? 'property_approved' : 'property_rejected',
      entityType: 'property',
      entityId: id,
      message: is_approved ? 'Approved property listing' : 'Rejected property listing',
      metadata: { property: result.rows[0] },
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// Mark a property as verified (inspected / ownership checked) or remove the badge.
const updatePropertyVerification = async (req, res) => {
  const { id } = req.params;
  const { verified, note } = req.body || {};

  if (typeof verified !== 'boolean') {
    return res.status(400).json({ message: 'verified must be true or false' });
  }

  const cleanNote = typeof note === 'string' ? note.trim().slice(0, 500) : '';

  try {
    const current = await pool.query(
      'SELECT id, title, is_approved FROM properties WHERE id = $1',
      [id]
    );

    if (current.rows.length === 0) {
      return res.status(404).json({ message: 'Property not found' });
    }

    if (verified && !current.rows[0].is_approved) {
      return res.status(400).json({ message: 'Approve the property before verifying it' });
    }

    const result = await pool.query(
      `UPDATE properties
       SET verified_at = ${verified ? 'NOW()' : 'NULL'}, updated_at = NOW()
       WHERE id = $1
       RETURNING id, title, is_approved, verified_at`,
      [id]
    );

    res.json({
      message: verified ? 'Property verified' : 'Verification removed',
      property: result.rows[0]
    });

    await recordAdminLog(req, {
      action: verified ? 'property_verified' : 'property_unverified',
      entityType: 'property',
      entityId: id,
      message: verified ? 'Verified property listing' : 'Removed property verification',
      metadata: { property: result.rows[0], note: cleanNote || undefined },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// Delete a property
const deleteProperty = async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query(
      'DELETE FROM properties WHERE id = $1 RETURNING id, title',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Property not found' });
    }

    res.json({ message: 'Property deleted successfully' });

    await recordAdminLog(req, {
      action: 'property_deleted',
      entityType: 'property',
      entityId: id,
      message: 'Deleted property listing',
      metadata: { property: result.rows[0] },
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// Dashboard stats
const getStats = async (req, res) => {
  try {
    const [
      totalLandlords,
      approvedLandlords,
      pendingLandlords,
      totalProperties,
      approvedProperties,
      pendingProperties,
      activeProperties,
      totalPayments,
      successfulPayments,
      pendingPayments,
      failedPayments,
      totalRevenue
    ] = await Promise.all([
      pool.query(`SELECT COUNT(*) FROM users WHERE role = 'landlord'`),
      pool.query(`SELECT COUNT(*) FROM users WHERE role = 'landlord' AND is_approved = true`),
      pool.query(`SELECT COUNT(*) FROM users WHERE role = 'landlord' AND is_approved = false`),
      pool.query(`SELECT COUNT(*) FROM properties`),
      pool.query(`SELECT COUNT(*) FROM properties WHERE is_approved = true`),
      pool.query(`SELECT COUNT(*) FROM properties WHERE is_approved = false`),
      pool.query(`SELECT COUNT(*) FROM properties WHERE is_approved = true AND is_active = true`),
      pool.query(`SELECT COUNT(*) FROM payments`),
      pool.query(`SELECT COUNT(*) FROM payments WHERE status = 'confirmed'`),
      pool.query(`SELECT COUNT(*) FROM payments WHERE status = 'pending'`),
      pool.query(`SELECT COUNT(*) FROM payments WHERE status = 'failed'`),
      pool.query(`SELECT COALESCE(SUM(amount), 0) as total FROM payments WHERE status = 'confirmed'`),
    ]);

    res.json({
      stats: {
        total_landlords: parseInt(totalLandlords.rows[0].count),
        approved_landlords: parseInt(approvedLandlords.rows[0].count),
        pending_landlords: parseInt(pendingLandlords.rows[0].count),
        total_properties: parseInt(totalProperties.rows[0].count),
        approved_properties: parseInt(approvedProperties.rows[0].count),
        pending_properties: parseInt(pendingProperties.rows[0].count),
        rejected_properties: 0,
        active_properties: parseInt(activeProperties.rows[0].count),
        total_payments: parseInt(totalPayments.rows[0].count),
        successful_payments: parseInt(successfulPayments.rows[0].count),
        pending_payments: parseInt(pendingPayments.rows[0].count),
        failed_payments: parseInt(failedPayments.rows[0].count),
        total_revenue: parseFloat(totalRevenue.rows[0].total),
      }
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// Create admin account
const createAdmin = async (req, res) => {
  const { full_name, phone, email, password, access_level } = req.body;

  try {
    if (!isOwner(req.user)) {
      return res.status(403).json({
        message: 'Only owner admins can create admin accounts'
      });
    }

    if (!full_name || !phone || !isValidPassword(password)) {
      return res.status(400).json({
        message: `Full name, phone and a password of at least ${MIN_PASSWORD_LENGTH} characters are required`
      });
    }

    const existing = await pool.query(
      'SELECT id FROM users WHERE phone = $1', [phone]
    );

    if (existing.rows.length > 0) {
      return res.status(400).json({ message: 'Phone already registered' });
    }

    const password_hash = await bcrypt.hash(password, 10);
    const normalizedAccessLevel = normalizeAccessLevel(access_level);

    const result = await pool.query(
      `INSERT INTO users (full_name, phone, email, password_hash, role, is_approved, access_level)
       VALUES ($1, $2, $3, $4, 'admin', true, $5)
       RETURNING id, full_name, phone, email, role, access_level`,
      [full_name, phone, email, password_hash, normalizedAccessLevel]
    );

    res.status(201).json({
      message: 'Admin created successfully',
      admin: result.rows[0]
    });

    await recordAdminLog(req, {
      action: 'admin_created',
      entityType: 'admin',
      entityId: result.rows[0].id,
      message: 'Created admin account',
      metadata: { admin: result.rows[0] },
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};


// Reset landlord password
const resetLandlordPassword = async (req, res) => {
  const { id } = req.params;
  const { password } = req.body;

  if (!isValidPassword(password)) {
    return res.status(400).json({
      message: `Password must be at least ${MIN_PASSWORD_LENGTH} characters`
    });
  }

  try {
    const password_hash = await bcrypt.hash(password, 10);
    // Scoped to landlords so this endpoint can never reset an admin's password.
    const result = await pool.query(
      `UPDATE users SET password_hash = $1
       WHERE id = $2 AND role = 'landlord'
       RETURNING id`,
      [password_hash, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Landlord not found' });
    }

    res.json({ message: 'Password reset successfully' });

    await recordAdminLog(req, {
      action: 'landlord_password_reset',
      entityType: 'landlord',
      entityId: id,
      message: 'Reset landlord password',
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// Delete landlord account
const deleteLandlord = async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query(
      `DELETE FROM users WHERE id = $1 AND role = 'landlord' RETURNING id`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Landlord not found' });
    }

    res.json({ message: 'Landlord deleted successfully' });

    await recordAdminLog(req, {
      action: 'landlord_deleted',
      entityType: 'landlord',
      entityId: id,
      message: 'Deleted landlord account',
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

const getPayments = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT p.*, u.full_name as landlord_name, pr.title as property_title
       FROM payments p
       LEFT JOIN users u ON p.landlord_id = u.id
       LEFT JOIN properties pr ON p.property_id = pr.id
       ORDER BY p.created_at DESC`
    );
    res.json({ payments: result.rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

const recordPayment = async (req, res) => {
  const {
    landlord_id,
    property_id,
    amount,
    payment_method,
    mobile_money_provider,
    bank_name,
    payment_reference,
    duration_months,
    status
  } = req.body;

  try {
    if (!property_id || !amount) {
      return res.status(400).json({
        message: 'Property and amount are required'
      });
    }

    const propertyCheck = await pool.query(
      `SELECT id, landlord_id FROM properties WHERE id = $1`,
      [property_id]
    );

    if (propertyCheck.rows.length === 0) {
      return res.status(400).json({
        message: 'Selected property was not found'
      });
    }

    const resolvedLandlordId = propertyCheck.rows[0].landlord_id;

    if (landlord_id && landlord_id !== resolvedLandlordId) {
      return res.status(400).json({
        message: 'Selected property does not belong to the selected landlord'
      });
    }

    const months = Number(duration_months) || DEFAULT_LISTING_MONTHS;
    const paid_at = new Date();
    const expires_at = new Date(paid_at);
    expires_at.setMonth(expires_at.getMonth() + months);

    // `reference` / `transaction_reference` are legacy column names kept in sync for older reports.
    const valuesByColumn = {
      landlord_id: resolvedLandlordId,
      property_id,
      amount,
      payment_method,
      mobile_money_provider: payment_method === 'mobile_money' ? mobile_money_provider : null,
      bank_name: payment_method === 'bank_transfer' ? bank_name : null,
      payment_reference,
      reference: payment_reference,
      transaction_reference: payment_reference,
      duration_months: months,
      status: status || 'confirmed',
      paid_at,
      expires_at,
    };

    const insertColumns = Object.keys(valuesByColumn);
    const insertValues = Object.values(valuesByColumn);
    const placeholders = insertColumns.map((_, index) => `$${index + 1}`);

    const result = await pool.query(
      `INSERT INTO payments (${insertColumns.join(', ')})
       VALUES (${placeholders.join(', ')})
       RETURNING *`,
      insertValues
    );

    await pool.query(
      `UPDATE properties SET is_active = true, listing_expires_at = $1 WHERE id = $2`,
      [expires_at, property_id]
    );

    res.status(201).json({ payment: result.rows[0] });

    await recordAdminLog(req, {
      action: 'payment_recorded',
      entityType: 'payment',
      entityId: result.rows[0].id,
      message: 'Recorded manual payment',
      metadata: {
        payment: result.rows[0],
        property_id,
        landlord_id: resolvedLandlordId,
      },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

const getAdminProfile = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT id, full_name, phone, email, role, access_level, created_at
       FROM users
       WHERE id = $1 AND role = 'admin'`,
      [req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Admin profile not found' });
    }

    res.json({ admin: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

const updateAdminProfile = async (req, res) => {
  const { full_name, email } = req.body;

  try {
    const result = await pool.query(
      `UPDATE users
       SET full_name = COALESCE($1, full_name),
           email = COALESCE($2, email)
       WHERE id = $3 AND role = 'admin'
       RETURNING id, full_name, phone, email, role, access_level, created_at`,
      [full_name, email, req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Admin profile not found' });
    }

    res.json({ admin: result.rows[0] });

    await recordAdminLog(req, {
      action: 'admin_profile_updated',
      entityType: 'admin',
      entityId: req.user.id,
      message: 'Updated own admin profile',
      metadata: { admin: result.rows[0] },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

const getAdmins = async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT id, full_name, phone, email, role, access_level, is_approved, created_at
       FROM users
       WHERE role = 'admin'
       ORDER BY created_at DESC`
    );

    res.json({
      count: result.rows.length,
      admins: result.rows,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

const getAdminDetails = async (req, res) => {
  const { id } = req.params;

  try {
    const canViewStats = isOwner(req.user) || String(req.user.id) === String(id);
    if (!canViewStats) {
      return res.status(403).json({
        message: 'Only owner admins can view other admins stats'
      });
    }

    const adminResult = await pool.query(
      `SELECT id, full_name, phone, email, role, access_level, is_approved, created_at
       FROM users
       WHERE id = $1 AND role = 'admin'`,
      [id]
    );

    if (adminResult.rows.length === 0) {
      return res.status(404).json({ message: 'Admin not found' });
    }

    const [
      totalActions,
      actionBreakdown,
      entityBreakdown,
      dailyActivity,
      recentActions
    ] = await Promise.all([
      pool.query(
        `SELECT COUNT(*)::int AS count
         FROM admin_logs
         WHERE admin_id = $1`,
        [id]
      ),
      pool.query(
        `SELECT action, COUNT(*)::int AS count
         FROM admin_logs
         WHERE admin_id = $1
         GROUP BY action
         ORDER BY count DESC, action ASC`,
        [id]
      ),
      pool.query(
        `SELECT entity_type, COUNT(*)::int AS count
         FROM admin_logs
         WHERE admin_id = $1
         GROUP BY entity_type
         ORDER BY count DESC, entity_type ASC`,
        [id]
      ),
      pool.query(
        `SELECT DATE(created_at) AS day, COUNT(*)::int AS count
         FROM admin_logs
         WHERE admin_id = $1
           AND created_at >= NOW() - INTERVAL '30 days'
         GROUP BY DATE(created_at)
         ORDER BY day DESC
         LIMIT 30`,
        [id]
      ),
      pool.query(
        `SELECT action, entity_type, entity_id, message, status, created_at
         FROM admin_logs
         WHERE admin_id = $1
         ORDER BY created_at DESC
         LIMIT 8`,
        [id]
      ),
    ]);

    const countFor = (action) =>
      actionBreakdown.rows.find((row) => row.action === action)?.count || 0;

    res.json({
      admin: adminResult.rows[0],
      stats: {
        total_actions: totalActions.rows[0].count,
        action_breakdown: actionBreakdown.rows,
        entity_breakdown: entityBreakdown.rows,
        daily_activity: dailyActivity.rows,
        payments_recorded: countFor('payment_recorded'),
        properties_approved: countFor('property_approved'),
        properties_rejected: countFor('property_rejected'),
        landlords_approved: countFor('landlord_approved'),
        landlords_suspended: countFor('landlord_suspended'),
        destructive_actions: actionBreakdown.rows
          .filter((row) => row.action.includes('deleted') || row.action.includes('suspended') || row.action.includes('rejected'))
          .reduce((sum, row) => sum + Number(row.count || 0), 0),
        recent_actions: recentActions.rows,
      },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

const updateAdminAccess = async (req, res) => {
  const { id } = req.params;
  const { access_level } = req.body;

  try {
    if (!isOwner(req.user)) {
      return res.status(403).json({
        message: 'Only owner admins can update admin access'
      });
    }

    const normalizedAccessLevel = normalizeAccessLevel(access_level);
    const result = await pool.query(
      `UPDATE users
       SET access_level = $1
       WHERE id = $2 AND role = 'admin'
       RETURNING id, full_name, phone, email, role, access_level, created_at`,
      [normalizedAccessLevel, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Admin not found' });
    }

    res.json({ admin: result.rows[0] });

    await recordAdminLog(req, {
      action: 'admin_access_updated',
      entityType: 'admin',
      entityId: id,
      message: `Updated admin access to ${normalizedAccessLevel}`,
      metadata: { admin: result.rows[0] },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

const deleteAdmin = async (req, res) => {
  const { id } = req.params;

  try {
    if (!isOwner(req.user)) {
      return res.status(403).json({
        message: 'Only owner admins can delete admin accounts'
      });
    }

    const target = await pool.query(
      `SELECT id, full_name, access_level
       FROM users
       WHERE id = $1 AND role = 'admin'`,
      [id]
    );

    if (target.rows.length === 0) {
      return res.status(404).json({ message: 'Admin not found' });
    }

    if (target.rows[0].access_level === 'owner') {
      return res.status(403).json({ message: 'Owner admin cannot be deleted' });
    }

    await pool.query(
      `DELETE FROM users WHERE id = $1 AND role = 'admin'`,
      [id]
    );

    res.json({ message: 'Admin deleted successfully' });

    await recordAdminLog(req, {
      action: 'admin_deleted',
      entityType: 'admin',
      entityId: id,
      message: 'Deleted admin account',
      metadata: { admin: target.rows[0] },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

const getLogs = async (req, res) => {
  try {
    const logs = await getAdminLogs(req.query);
    res.json({
      count: logs.length,
      logs,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = {
  getLandlords,
  updateLandlordStatus,
  getProperties,
  updatePropertyStatus,
  updatePropertyVerification,
  deleteProperty,
  getStats,
  createAdmin,
  resetLandlordPassword,
  deleteLandlord,
  getPayments,
  recordPayment,
  getLogs,
  getAdminProfile,
  updateAdminProfile,
  getAdmins,
  getAdminDetails,
  updateAdminAccess,
  deleteAdmin
};

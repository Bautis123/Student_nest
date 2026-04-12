const { acceptsLanguages } = require('express/lib/request');
const pool = require('../config/db');

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
        COUNT(r.id) AS room_types
      FROM properties p
      LEFT JOIN users u ON p.landlord_id = u.id
      LEFT JOIN schools s ON p.nearest_school_id = s.id
      LEFT JOIN rooms r ON p.id = r.property_id
    `;

    if (status === 'pending') {
      query += ` WHERE p.is_approved = false`;
    } else if (status === 'approved') {
      query += ` WHERE p.is_approved = true`;
    }

    query += ` GROUP BY p.id, u.full_name, u.phone, s.name ORDER BY p.created_at DESC`;

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
      `UPDATE properties SET is_approved = $1, updated_at = NOW()
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
      pendingLandlords,
      totalProperties,
      pendingProperties,
      activeProperties,
      totalRevenue
    ] = await Promise.all([
      pool.query(`SELECT COUNT(*) FROM users WHERE role = 'landlord'`),
      pool.query(`SELECT COUNT(*) FROM users WHERE role = 'landlord' AND is_approved = false`),
      pool.query(`SELECT COUNT(*) FROM properties WHERE is_approved = true`),
      pool.query(`SELECT COUNT(*) FROM properties WHERE is_approved = false`),
      pool.query(`SELECT COUNT(*) FROM properties WHERE is_approved = true AND is_active = true`),
      pool.query(`SELECT COALESCE(SUM(amount), 0) as total FROM payments WHERE status = 'confirmed'`),
    ]);

    res.json({
      stats: {
        total_landlords: parseInt(totalLandlords.rows[0].count),
        pending_landlords: parseInt(pendingLandlords.rows[0].count),
        total_properties: parseInt(totalProperties.rows[0].count),
        pending_properties: parseInt(pendingProperties.rows[0].count),
        active_properties: parseInt(activeProperties.rows[0].count),
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
  const { full_name, phone, email, password } = req.body;
  const bcrypt = require('bcryptjs');

  try {
    const existing = await pool.query(
      'SELECT id FROM users WHERE phone = $1', [phone]
    );

    if (existing.rows.length > 0) {
      return res.status(400).json({ message: 'Phone already registered' });
    }

    const password_hash = await bcrypt.hash(password, 10);

    const result = await pool.query(
      `INSERT INTO users (full_name, phone, email, password_hash, role, is_approved)
       VALUES ($1, $2, $3, $4, 'admin', true)
       RETURNING id, full_name, phone, email, role`,
      [full_name, phone, email, password_hash]
    );

    res.status(201).json({
      message: 'Admin created successfully',
      admin: result.rows[0]
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};


// Update landlord details (admin)
const updateLandlord = async (req, res) => {
  const { id } = req.params;
  const { full_name, phone, email, is_approved } = req.body;

  try {
    const result = await pool.query(
      `UPDATE users SET
        full_name = COALESCE($1, full_name),
        phone = COALESCE($2, phone),
        email = COALESCE($3, email),
        is_approved = COALESCE($4, is_approved)
       WHERE id = $5 AND role = 'landlord'
       RETURNING id, full_name, phone, email, is_approved`,
      [full_name, phone, email, is_approved, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Landlord not found' });
    }

    res.json({ landlord: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};
 // Reset landlord password
const resetLandlordPassword = async (req, res) => {
  const { id } = req.params;
  const { password } = req.body;
  const bcrypt = require('bcryptjs');

  try {
    const password_hash = await bcrypt.hash(password, 10);
    await pool.query(
      'UPDATE users SET password_hash = $1 WHERE id = $2',
      [password_hash, id]
    );
    res.json({ message: 'Password reset successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

 // Delete landlord account
const deleteLandlord = async (req, res) => {
  const { id } = req.params;

  try {
    await pool.query(
      'DELETE FROM users WHERE id = $1 AND role = $2',
      [id, 'landlord']
    );
    res.json({ message: 'Landlord deleted successfully' });
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
    payment_reference,
    duration_months,
    status
  } = req.body;

  try {
    const paid_at = new Date();
    const expires_at = new Date();
    expires_at.setMonth(expires_at.getMonth() + (duration_months || 12));

    const result = await pool.query(
      `INSERT INTO payments
        (landlord_id, property_id, amount, payment_method, payment_reference, status, paid_at, expires_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       RETURNING *`,
      [landlord_id, property_id, amount, payment_method,
       payment_reference, status || 'confirmed', paid_at, expires_at]
    );

    await pool.query(
      `UPDATE properties SET is_active = true, listing_expires_at = $1 WHERE id = $2`,
      [expires_at, property_id]
    );

    res.status(201).json({ payment: result.rows[0] });
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
  deleteProperty,
  getStats,
  createAdmin,
  updateLandlord,
  resetLandlordPassword,
  deleteLandlord,
  getPayments,
  recordPayment
};
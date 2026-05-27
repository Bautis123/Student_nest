const pool = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// Register landlord
const register = async (req, res) => {
  try {
    const { full_name, phone, email, password } = req.body || {};

    if (!full_name || !phone || !password) {
      return res.status(400).json({ message: 'Full name, phone, and password are required' });
    }

    // Check if phone already exists
    const existing = await pool.query(
      'SELECT id FROM users WHERE phone = $1', [phone]
    );

    if (existing.rows.length > 0) {
      return res.status(400).json({ message: 'Phone number already registered' });
    }

    // Hash password
    const password_hash = await bcrypt.hash(password, 10);

    // Insert user
    const result = await pool.query(
      `INSERT INTO users (full_name, phone, email, password_hash, role)
       VALUES ($1, $2, $3, $4, 'landlord')
       RETURNING id, full_name, phone, email, role, is_approved`,
      [full_name, phone, email, password_hash]
    );

    const user = result.rows[0];

    res.status(201).json({
      message: 'Registration successful. Await admin approval.',
      user
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// Login
const login = async (req, res) => {
  try {
    const { phone, password } = req.body || {};

    if (!phone || !password) {
      return res.status(400).json({ message: 'Phone and password are required' });
    }

    const result = await pool.query(
      'SELECT * FROM users WHERE phone = $1', [phone]
    );

    if (result.rows.length === 0) {
      return res.status(400).json({ message: 'Invalid phone or password' });
    }

    const user = result.rows[0];

    // Check password
    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid phone or password' });
    }

    // Check approval
    if (!user.is_approved) {
      return res.status(403).json({ message: 'Account pending admin approval' });
    }

    const accessLevel = user.role === 'admin'
      ? (user.access_level || 'manager')
      : null;

    // Generate token
    const token = jwt.sign(
      { id: user.id, role: user.role, access_level: accessLevel },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.json({
      message: 'Login successful',
      token,
      user: {
        id: user.id,
        full_name: user.full_name,
        phone: user.phone,
        email: user.email,
        role: user.role,
        access_level: accessLevel
      }
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

module.exports = { register, login };

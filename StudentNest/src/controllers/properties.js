const pool = require('../config/db');

// Create a new property listing
const createProperty = async (req, res) => {
  const {
    title,
    description,
    address,
    latitude,
    longitude,
    nearest_school_id,
    amenities
  } = req.body;

  const landlord_id = req.user.id;

  try {
    // Calculate distance from school in km using Haversine formula
    let distance_from_school = null;

    if (nearest_school_id) {
      const schoolResult = await pool.query(
        'SELECT latitude, longitude FROM schools WHERE id = $1',
        [nearest_school_id]
      );

      if (schoolResult.rows.length > 0) {
        const school = schoolResult.rows[0];
        distance_from_school = calculateDistance(
          latitude,
          longitude,
          school.latitude,
          school.longitude
        );
      }
    }

    const result = await pool.query(
      `INSERT INTO properties 
        (landlord_id, title, description, address, latitude, longitude, 
         nearest_school_id, distance_from_school, amenities)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
       RETURNING *`,
      [
        landlord_id, title, description, address,
        latitude, longitude, nearest_school_id,
        distance_from_school, JSON.stringify(amenities || {})
      ]
    );

    res.status(201).json({
      message: 'Property created successfully. Awaiting admin approval.',
      property: result.rows[0]
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get all approved properties (student browsing)
const getProperties = async (req, res) => {
  const { school_id, min_price, max_price, room_type } = req.query;

  try {
    let query = `
      SELECT 
        p.*,
        s.name AS school_name,
        s.latitude AS school_lat,
        s.longitude AS school_lng,
        u.full_name AS landlord_name,
        u.phone AS landlord_phone,
        CASE
          WHEN lp.amount >= 750 THEN 'premium'
          ELSE 'basic'
        END AS listing_plan,
        CASE
          WHEN lp.amount >= 750 THEN true
          ELSE false
        END AS is_premium,
        COALESCE(cover.cover_photo, '[]'::jsonb) AS cover_photo,
        (
          SELECT COALESCE(SUM(rooms.available_rooms * rooms.students_per_room), 0)::int
          FROM rooms
          WHERE rooms.property_id = p.id
        ) AS available_spaces_count,
        MIN(r.price_per_month) AS min_price,
        MAX(r.price_per_month) AS max_price
      FROM properties p
      LEFT JOIN schools s ON p.nearest_school_id = s.id
      LEFT JOIN users u ON p.landlord_id = u.id
      LEFT JOIN LATERAL (
        SELECT amount
        FROM payments pm
        WHERE pm.property_id = p.id
          AND pm.status = 'confirmed'
        ORDER BY pm.paid_at DESC NULLS LAST
        LIMIT 1
      ) lp ON true
      LEFT JOIN LATERAL (
        SELECT COALESCE(jsonb_agg(to_jsonb(photo_row)), '[]'::jsonb) AS cover_photo
        FROM (
          SELECT *
          FROM photos
          WHERE property_id = p.id
          ORDER BY is_cover DESC, id ASC
          LIMIT 1
        ) photo_row
      ) cover ON true
      LEFT JOIN rooms r ON p.id = r.property_id
      WHERE p.is_approved = true
        AND p.is_active = true
        AND (p.listing_expires_at IS NULL OR p.listing_expires_at > NOW())
    `;

    const params = [];
    let paramCount = 1;

    if (school_id) {
      query += ` AND p.nearest_school_id = $${paramCount}`;
      params.push(school_id);
      paramCount++;
    }

    if (min_price) {
      query += ` AND r.price_per_month >= $${paramCount}`;
      params.push(min_price);
      paramCount++;
    }

    if (max_price) {
      query += ` AND r.price_per_month <= $${paramCount}`;
      params.push(max_price);
      paramCount++;
    }

    query += ` GROUP BY p.id, s.name, s.latitude, s.longitude, u.full_name, u.phone, lp.amount, cover.cover_photo`;
    query += ` ORDER BY p.created_at DESC`;

    const result = await pool.query(query, params);

    res.json({
      count: result.rows.length,
      properties: result.rows
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get single property details
const getPropertyById = async (req, res) => {
  const { id } = req.params;

  try {
    // Increment view count
    await pool.query(
      'UPDATE properties SET view_count = view_count + 1 WHERE id = $1',
      [id]
    );

    const result = await pool.query(
      `SELECT 
        p.*,
        s.name AS school_name,
        s.latitude AS school_lat,
        s.longitude AS school_lng,
        u.full_name AS landlord_name,
        u.phone AS landlord_phone,
        u.email AS landlord_email,
        CASE
          WHEN lp.amount >= 750 THEN 'premium'
          ELSE 'basic'
        END AS listing_plan,
        CASE
          WHEN lp.amount >= 750 THEN true
          ELSE false
        END AS is_premium
       FROM properties p
       LEFT JOIN schools s ON p.nearest_school_id = s.id
       LEFT JOIN users u ON p.landlord_id = u.id
       LEFT JOIN LATERAL (
         SELECT amount
         FROM payments pm
         WHERE pm.property_id = p.id
           AND pm.status = 'confirmed'
         ORDER BY pm.paid_at DESC NULLS LAST
         LIMIT 1
       ) lp ON true
       WHERE p.id = $1
         AND p.is_approved = true
         AND p.is_active = true
         AND (p.listing_expires_at IS NULL OR p.listing_expires_at > NOW())`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Property not found' });
    }

    // Get rooms
    const rooms = await pool.query(
      'SELECT * FROM rooms WHERE property_id = $1',
      [id]
    );

    // Get photos
    const photos = await pool.query(
      'SELECT * FROM photos WHERE property_id = $1 ORDER BY is_cover DESC',
      [id]
    );

    const property = result.rows[0];
    property.rooms = rooms.rows;
    property.photos = photos.rows;

    res.json({ property });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// Add rooms to a property
const addRooms = async (req, res) => {
  const { property_id } = req.params;
  const { rooms } = req.body;
  const landlord_id = req.user.id;

  try {
    // Make sure this property belongs to this landlord
    const check = await pool.query(
      'SELECT id FROM properties WHERE id = $1 AND landlord_id = $2',
      [property_id, landlord_id]
    );

    if (check.rows.length === 0) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    // Insert all rooms
    const insertedRooms = [];
    for (const room of rooms) {
      const result = await pool.query(
        `INSERT INTO rooms 
          (property_id, room_type, price_per_month, students_per_room, total_rooms, available_rooms)
         VALUES ($1, $2, $3, $4, $5, $6)
         RETURNING *`,
        [
          property_id,
          room.room_type,
          room.price_per_month,
          room.students_per_room,
          room.total_rooms,
          room.available_rooms
        ]
      );
      insertedRooms.push(result.rows[0]);
    }

    res.status(201).json({
      message: 'Rooms added successfully',
      rooms: insertedRooms
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// Track contact click
const trackContactClick = async (req, res) => {
  const { id } = req.params;

  try {
    await pool.query(
      'UPDATE properties SET contact_click_count = contact_click_count + 1 WHERE id = $1',
      [id]
    );

    res.json({ message: 'Tracked' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get landlord's own properties
const getMyProperties = async (req, res) => {
  const landlord_id = req.user.id;

  try {
    const result = await pool.query(
      `SELECT 
        p.*,
        s.name AS school_name,
        s.latitude AS school_lat,
        s.longitude AS school_lng,
        CASE
          WHEN lp.amount >= 750 THEN 'premium'
          ELSE 'basic'
        END AS listing_plan,
        CASE
          WHEN lp.amount >= 750 THEN true
          ELSE false
        END AS is_premium,
        COUNT(r.id) AS room_types_count,
        COALESCE(SUM(r.total_rooms), 0)::int AS total_rooms_count,
        COALESCE(SUM(r.available_rooms), 0)::int AS available_rooms_count,
        GREATEST(
          COALESCE(SUM(r.total_rooms), 0) - COALESCE(SUM(r.available_rooms), 0),
          0
        )::int AS occupied_rooms_count
       FROM properties p
       LEFT JOIN schools s ON p.nearest_school_id = s.id
       LEFT JOIN LATERAL (
         SELECT amount
         FROM payments pm
         WHERE pm.property_id = p.id
           AND pm.status = 'confirmed'
         ORDER BY pm.paid_at DESC NULLS LAST
         LIMIT 1
       ) lp ON true
       LEFT JOIN rooms r ON p.id = r.property_id
       WHERE p.landlord_id = $1
       GROUP BY p.id, s.name, s.latitude, s.longitude, lp.amount
       ORDER BY p.created_at DESC`,
      [landlord_id]
    );

    res.json({
      count: result.rows.length,
      properties: result.rows
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// Haversine formula - calculates distance between two coordinates in km
const calculateDistance = (lat1, lon1, lat2, lon2) => {
  const R = 6371;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return Math.round(R * c * 100) / 100;
};

const toRad = (value) => (value * Math.PI) / 180;

const getSchools = async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, name, area, latitude, longitude FROM schools ORDER BY name'
    );
    res.json({ schools: result.rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// Update property details
const updateProperty = async (req, res) => {
  const { id } = req.params;
  const landlord_id = req.user.id;
  const { title, description, address, amenities, is_active } = req.body;

  try {
    const check = await pool.query(
      'SELECT id FROM properties WHERE id = $1 AND landlord_id = $2',
      [id, landlord_id]
    );

    if (check.rows.length === 0) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    const result = await pool.query(
      `UPDATE properties SET
        title = COALESCE($1, title),
        description = COALESCE($2, description),
        address = COALESCE($3, address),
        amenities = COALESCE($4, amenities),
        is_active = COALESCE($5, is_active),
        updated_at = NOW()
       WHERE id = $6
       RETURNING *`,
      [title, description, address,
       amenities ? JSON.stringify(amenities) : null,
       is_active, id]
    );

    res.json({ property: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// Delete a property (soft delete by setting is_active to false)
const deletePropertyLandlord = async (req, res) => {
  const { id } = req.params;
  const landlord_id = req.user.id;

  try {
    const check = await pool.query(
      'SELECT id FROM properties WHERE id = $1 AND landlord_id = $2',
      [id, landlord_id]
    );

    if (check.rows.length === 0) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    await pool.query('DELETE FROM properties WHERE id = $1', [id]);
    res.json({ message: 'Property deleted successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

const updateRoomAvailability = async (req, res) => {
  const { room_id } = req.params;
  const { available_rooms } = req.body;
  const landlord_id = req.user.id;

  try {
    const check = await pool.query(
      `SELECT r.id FROM rooms r
       JOIN properties p ON r.property_id = p.id
       WHERE r.id = $1 AND p.landlord_id = $2`,
      [room_id, landlord_id]
    );

    if (check.rows.length === 0) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    const result = await pool.query(
      'UPDATE rooms SET available_rooms = $1 WHERE id = $2 RETURNING *',
      [available_rooms, room_id]
    );

    res.json({ room: result.rows[0] });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};


 module.exports = {
  createProperty,
  getProperties,
  getPropertyById,
  addRooms,
  trackContactClick,
  getMyProperties,
  getSchools,
  updateProperty,
  deletePropertyLandlord,
  updateRoomAvailability
};

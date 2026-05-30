const express = require('express');
const router = express.Router();
const db = require('../db');
const authMiddleware = require('../middleware/authMiddleware');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const uploadsDir = path.join(__dirname, '../uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadsDir),
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  },
});

const upload = multer({ storage });

function sanitizeUser(user) {
  if (!user) return user;
  const { password, ...safeUser } = user;
  return safeUser;
}

function parseEqId(id) {
  if (!id || typeof id !== 'string' || !id.startsWith('eq.')) return null;
  return id.replace('eq.', '');
}

function parseInIds(id) {
  if (!id || typeof id !== 'string' || !id.startsWith('in.')) return null;
  const matches = id.match(/\((.*?)\)/);
  if (!matches || !matches[1]) return null;
  return matches[1].split(',').map((item) => item.replace(/"/g, '').trim()).filter(Boolean);
}

// Get user by ID (handles both standard REST /api/users/:id and PostgREST /api/users?id=eq.123)
router.get('/', async (req, res) => {
  try {
    const { id } = req.query;
    const eqId = parseEqId(id);
    if (eqId) {
      const userId = eqId;
      const result = await db.query('SELECT * FROM users WHERE id = $1', [userId]);
      return res.json(result.rows.map(sanitizeUser));
    }

    const inIds = parseInIds(id);
    if (inIds) {
      const result = await db.query('SELECT * FROM users WHERE id = ANY($1)', [inIds]);
      return res.json(result.rows.map(sanitizeUser));
    }

    const result = await db.query('SELECT * FROM users WHERE COALESCE(is_active, true) = true LIMIT 50');
    res.json(result.rows.map(sanitizeUser));
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

router.post('/', async (req, res) => {
  try {
    const users = Array.isArray(req.body) ? req.body : [req.body];
    const inserted = [];

    for (const user of users) {
      if (!user.id || !user.email || !user.name) continue;
      const result = await db.query(
        `INSERT INTO users (id, name, email, password, bio, gender, age, profile_photo)
         VALUES ($1, $2, $3, COALESCE($4, ''), $5, $6, $7, $8)
         ON CONFLICT (id) DO UPDATE SET
           name = EXCLUDED.name,
           email = EXCLUDED.email,
           bio = COALESCE(EXCLUDED.bio, users.bio),
           gender = COALESCE(EXCLUDED.gender, users.gender),
           age = COALESCE(EXCLUDED.age, users.age),
           profile_photo = COALESCE(EXCLUDED.profile_photo, users.profile_photo),
           updated_at = CURRENT_TIMESTAMP
         RETURNING *`,
        [
          user.id,
          user.name,
          user.email,
          user.password,
          user.bio,
          user.gender,
          user.age,
          user.profile_photo || user.profilePhoto,
        ]
      );
      inserted.push(sanitizeUser(result.rows[0]));
    }

    res.status(201).json(Array.isArray(req.body) ? inserted : inserted[0]);
  } catch (err) {
    console.error('User upsert error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

router.get('/nearby', authMiddleware, async (req, res) => {
  try {
    const latitude = Number(req.query.latitude);
    const longitude = Number(req.query.longitude);
    const radius = Number(req.query.radius || 50);

    if (!Number.isFinite(latitude) || !Number.isFinite(longitude)) {
      return res.status(400).json({ message: 'Valid latitude and longitude are required' });
    }

    const result = await db.query(
      `
      SELECT *,
        (
          6371 * acos(
            LEAST(1, GREATEST(-1,
              cos(radians($1)) * cos(radians(latitude)) *
              cos(radians(longitude) - radians($2)) +
              sin(radians($1)) * sin(radians(latitude))
            ))
          )
        ) AS distance
      FROM users
      WHERE latitude IS NOT NULL
        AND longitude IS NOT NULL
        AND id <> $4
        AND COALESCE(is_active, true) = true
        AND (
          6371 * acos(
            LEAST(1, GREATEST(-1,
              cos(radians($1)) * cos(radians(latitude)) *
              cos(radians(longitude) - radians($2)) +
              sin(radians($1)) * sin(radians(latitude))
            ))
          )
        ) <= $3
      ORDER BY distance ASC
      LIMIT 100
      `,
      [latitude, longitude, radius, req.user.id]
    );

    res.json({ users: result.rows.map(sanitizeUser) });
  } catch (err) {
    console.error('Nearby users error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

router.put('/', async (req, res) => {
  try {
    const { id } = req.query; // ?id=eq.123
    const { name, bio, gender, age, profile_photo, profilePhoto, phone } = req.body;
    const userId = parseEqId(id);

    if (!userId) {
      return res.status(400).json({ message: 'Missing user ID' });
    }

    const result = await db.query(
      `UPDATE users SET
        name = COALESCE($1, name),
        bio = COALESCE($2, bio),
        gender = COALESCE($3, gender),
        age = COALESCE($4, age),
        profile_photo = COALESCE($5, profile_photo),
        phone = COALESCE($6, phone),
        updated_at = CURRENT_TIMESTAMP
      WHERE id = $7 RETURNING *`,
      [name, bio, gender, age, profile_photo || profilePhoto, phone, userId]
    );
    res.json(sanitizeUser(result.rows[0]));
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

router.put('/location', authMiddleware, async (req, res) => {
  try {
    const { latitude, longitude } = req.body;
    const userId = req.body.userId || req.user.id;

    if (!userId || latitude == null || longitude == null) {
      return res.status(400).json({ message: 'User ID, latitude, and longitude are required' });
    }

    const result = await db.query(
      'UPDATE users SET latitude = $1, longitude = $2, updated_at = CURRENT_TIMESTAMP WHERE id = $3 RETURNING *',
      [latitude, longitude, userId]
    );
    res.json(sanitizeUser(result.rows[0]));
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

router.post('/upload-photo', authMiddleware, upload.single('photo'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'No photo uploaded' });
    }

    const photoUrl = '/uploads/' + req.file.filename;
    const result = await db.query(
      'UPDATE users SET profile_photo = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 RETURNING *',
      [photoUrl, req.user.id]
    );

    res.json({
      success: true,
      message: 'Photo uploaded successfully',
      photoUrl,
      user: sanitizeUser(result.rows[0]),
    });
  } catch (err) {
    console.error('Photo upload error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

router.put('/change-email', authMiddleware, async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) return res.status(400).json({ message: 'Email is required' });

    const result = await db.query(
      'UPDATE users SET email = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 RETURNING *',
      [email, req.user.id]
    );

    res.json({ success: true, user: sanitizeUser(result.rows[0]) });
  } catch (err) {
    if (err.code === '23505') {
      return res.status(400).json({ message: 'Email already exists' });
    }
    console.error('Change email error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

router.put('/change-phone', authMiddleware, async (req, res) => {
  try {
    const { phone } = req.body;
    const result = await db.query(
      'UPDATE users SET phone = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 RETURNING *',
      [phone || null, req.user.id]
    );

    res.json({ success: true, user: sanitizeUser(result.rows[0]) });
  } catch (err) {
    console.error('Change phone error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

router.post('/deactivate', authMiddleware, async (req, res) => {
  try {
    await db.query('UPDATE users SET is_active = false, updated_at = CURRENT_TIMESTAMP WHERE id = $1', [
      req.user.id,
    ]);
    res.json({ success: true, message: 'Account deactivated' });
  } catch (err) {
    console.error('Deactivate account error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

router.delete('/delete', authMiddleware, async (req, res) => {
  try {
    await db.query('DELETE FROM users WHERE id = $1', [req.user.id]);
    res.json({ success: true, message: 'Account deleted' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;

const express = require('express');
const router = express.Router();
const db = require('../db');

// Get user by ID (handles both standard REST /api/users/:id and PostgREST /api/users?id=eq.123)
router.get('/', async (req, res) => {
  try {
    const { id } = req.query;
    if (id && id.startsWith('eq.')) {
      const userId = id.replace('eq.', '');
      const result = await db.query('SELECT * FROM users WHERE id = $1', [userId]);
      return res.json(result.rows);
    }
    if (id && id.startsWith('in.')) {
      // e.g. in.(1,2,3)
      const matches = id.match(/\((.*?)\)/);
      if (matches && matches[1]) {
        const ids = matches[1].split(',');
        const result = await db.query('SELECT * FROM users WHERE id = ANY($1)', [ids]);
        return res.json(result.rows);
      }
    }
    const result = await db.query('SELECT * FROM users LIMIT 50');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

router.put('/', async (req, res) => {
  try {
    const { id } = req.query; // ?id=eq.123
    const { name, bio, gender, age, profile_photo } = req.body;
    let userId;
    
    if (id && id.startsWith('eq.')) {
      userId = id.replace('eq.', '');
    } else {
      return res.status(400).json({ message: 'Missing user ID' });
    }

    const result = await db.query(
      'UPDATE users SET name = COALESCE($1, name), bio = COALESCE($2, bio), gender = COALESCE($3, gender), age = COALESCE($4, age), profile_photo = COALESCE($5, profile_photo) WHERE id = $6 RETURNING *',
      [name, bio, gender, age, profile_photo, userId]
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

router.put('/location', async (req, res) => {
  try {
    const { userId, latitude, longitude } = req.body;
    const result = await db.query(
      'UPDATE users SET latitude = $1, longitude = $2 WHERE id = $3 RETURNING *',
      [latitude, longitude, userId]
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;

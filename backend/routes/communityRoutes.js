const express = require('express');
const router = express.Router();
const db = require('../db');
const authMiddleware = require('../middleware/authMiddleware');
const multer = require('multer');
const path = require('path');

// Multer storage config
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.join(__dirname, '../uploads/'));
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({ storage });

router.get('/list', authMiddleware, async (req, res) => {
  try {
    // We should also return whether the current user has joined
    const userId = req.user.id;
    const result = await db.query(`
      SELECT c.*, 
        EXISTS(SELECT 1 FROM community_members cm WHERE cm.community_id = c.id AND cm.user_id = $1) as "isJoined"
      FROM communities c 
      ORDER BY c.created_at DESC
    `, [userId]);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

router.post('/join', authMiddleware, async (req, res) => {
  try {
    const { communityId } = req.body;
    const userId = req.user.id;
    const result = await db.query(
      'INSERT INTO community_members (community_id, user_id) VALUES ($1, $2) ON CONFLICT (community_id, user_id) DO NOTHING RETURNING *',
      [communityId, userId]
    );
    res.json(result.rows[0] || { status: 'already_joined' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

router.post('/create', authMiddleware, upload.fields([{ name: 'logo', maxCount: 1 }, { name: 'cover', maxCount: 1 }]), async (req, res) => {
  try {
    const { name, description, category, type, radius, latitude, longitude } = req.body;
    const userId = req.user.id;

    if (!name || !description || !category) {
      return res.status(400).json({ message: 'Name, description, and category are required' });
    }

    let logoPath = null;
    let coverPath = null;

    if (req.files) {
      if (req.files['logo']) {
        logoPath = '/uploads/' + req.files['logo'][0].filename;
      }
      if (req.files['cover']) {
        coverPath = '/uploads/' + req.files['cover'][0].filename;
      }
    }

    // Insert community
    const insertCommunityQuery = `
      INSERT INTO communities (name, description, category, type, radius, latitude, longitude, logo, cover, created_by)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
      RETURNING *;
    `;
    const communityResult = await db.query(insertCommunityQuery, [
      name, description, category, type || 'public', radius || 2.0, 
      latitude || null, longitude || null, logoPath, coverPath, userId
    ]);

    const newCommunity = communityResult.rows[0];

    // Automatically add the creator as a member
    await db.query(
      'INSERT INTO community_members (community_id, user_id, status) VALUES ($1, $2, $3)',
      [newCommunity.id, userId, 'joined']
    );

    res.status(201).json(newCommunity);
  } catch (err) {
    console.error('Community create error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

router.get('/search', authMiddleware, async (req, res) => {
  try {
    const { query } = req.query;
    const userId = req.user.id;
    const result = await db.query(`
      SELECT c.*, 
        EXISTS(SELECT 1 FROM community_members cm WHERE cm.community_id = c.id AND cm.user_id = $2) as "isJoined"
      FROM communities c 
      WHERE c.name ILIKE $1 OR c.description ILIKE $1 OR c.category ILIKE $1
      ORDER BY c.created_at DESC
    `, [`%${query}%`, userId]);
    res.json(result.rows);
  } catch (err) {
    console.error('Search error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;

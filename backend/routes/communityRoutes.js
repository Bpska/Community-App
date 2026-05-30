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
        EXISTS(SELECT 1 FROM community_members cm WHERE cm.community_id = c.id AND cm.user_id = $1) as "isJoined",
        COUNT(cm_all.id)::int as "membersCount",
        u.name as "creatorName"
      FROM communities c 
      LEFT JOIN community_members cm_all ON cm_all.community_id = c.id
      LEFT JOIN users u ON u.id = c.created_by
      GROUP BY c.id, u.name
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
        EXISTS(SELECT 1 FROM community_members cm WHERE cm.community_id = c.id AND cm.user_id = $2) as "isJoined",
        COUNT(cm_all.id)::int as "membersCount",
        u.name as "creatorName"
      FROM communities c 
      LEFT JOIN community_members cm_all ON cm_all.community_id = c.id
      LEFT JOIN users u ON u.id = c.created_by
      WHERE c.name ILIKE $1 OR c.description ILIKE $1 OR c.category ILIKE $1
      GROUP BY c.id, u.name
      ORDER BY c.created_at DESC
    `, [`%${query}%`, userId]);
    res.json(result.rows);
  } catch (err) {
    console.error('Search error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

router.get('/:id/members', authMiddleware, async (req, res) => {
  try {
    const communityId = req.params.id;
    const result = await db.query(`
      SELECT u.id, u.name, u.email, u.bio, u.profile_photo as "profilePhoto", u.is_online as "isOnline", cm.status
      FROM community_members cm
      JOIN users u ON u.id = cm.user_id
      WHERE cm.community_id = $1
      ORDER BY cm.joined_at ASC
    `, [communityId]);
    res.json(result.rows);
  } catch (err) {
    console.error('Fetch members error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    const communityId = req.params.id;
    const userId = req.user.id;

    const result = await db.query(
      'DELETE FROM communities WHERE id = $1 AND created_by = $2 RETURNING *',
      [communityId, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Community not found or not owned by current user' });
    }

    res.json({ success: true, community: result.rows[0] });
  } catch (err) {
    console.error('Delete community error:', err);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;

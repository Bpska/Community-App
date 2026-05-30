const express = require('express');
const router = express.Router();
const db = require('../db');
const authMiddleware = require('../middleware/authMiddleware');

function parseEqId(value) {
  if (!value || typeof value !== 'string' || !value.startsWith('eq.')) return null;
  return value.replace('eq.', '');
}

function extractUuids(value) {
  if (!value || typeof value !== 'string') return [];
  const matches = value.match(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/gi);
  return [...new Set(matches || [])];
}

function parseOrder(order, fallback = 'ASC') {
  if (!order || typeof order !== 'string') return fallback;
  return order.toLowerCase().includes('desc') ? 'DESC' : 'ASC';
}

// Get messages
router.get('/', authMiddleware, async (req, res) => {
  try {
    const { or, community_id, order, limit } = req.query;
    const sortDirection = parseOrder(order);
    const safeLimit = Math.min(Number(limit) || 250, 500);

    const commId = parseEqId(community_id);
    if (commId) {
      const result = await db.query(
        `SELECT * FROM messages WHERE community_id = $1 ORDER BY created_at ${sortDirection} LIMIT $2`,
        [commId, safeLimit]
      );
      return res.json(result.rows);
    }

    const ids = extractUuids(or);
    const currentUserId = req.user.id;

    if (ids.length >= 2) {
      const otherUserId = ids.find((id) => id !== currentUserId) || ids[1];
      const result = await db.query(
        `SELECT * FROM messages
         WHERE community_id IS NULL
           AND (
             (sender_id = $1 AND receiver_id = $2)
             OR (sender_id = $2 AND receiver_id = $1)
           )
         ORDER BY created_at ${sortDirection}
         LIMIT $3`,
        [currentUserId, otherUserId, safeLimit]
      );
      return res.json(result.rows);
    }

    const result = await db.query(
      `SELECT * FROM messages
       WHERE community_id IS NULL
         AND (sender_id = $1 OR receiver_id = $1)
       ORDER BY created_at ${sortDirection}
       LIMIT $2`,
      [currentUserId, safeLimit]
    );
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

router.post('/', authMiddleware, async (req, res) => {
  try {
    const { sender_id, receiver_id, community_id, message } = req.body;
    const senderId = sender_id || req.user.id;

    if (senderId !== req.user.id) {
      return res.status(403).json({ message: 'Cannot send a message as another user' });
    }

    if (!message || (!receiver_id && !community_id)) {
      return res.status(400).json({ message: 'Message and receiver or community are required' });
    }

    const result = await db.query(
      'INSERT INTO messages (sender_id, receiver_id, community_id, message, status) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [senderId, receiver_id || null, community_id || null, message, req.body.status || 'sent']
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

router.put('/', authMiddleware, async (req, res) => {
  try {
    const messageId = parseEqId(req.query.id);
    const { status } = req.body;

    if (!messageId || !status) {
      return res.status(400).json({ message: 'Message ID and status are required' });
    }

    const result = await db.query(
      `UPDATE messages
       SET status = $1
       WHERE id = $2 AND (sender_id = $3 OR receiver_id = $3)
       RETURNING *`,
      [status, messageId, req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Message not found' });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;

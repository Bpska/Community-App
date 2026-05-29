const express = require('express');
const router = express.Router();
const db = require('../db');

// Get messages
router.get('/', async (req, res) => {
  try {
    const { or, community_id } = req.query;
    if (community_id && community_id.startsWith('eq.')) {
      const commId = community_id.replace('eq.', '');
      const result = await db.query('SELECT * FROM messages WHERE community_id = $1 ORDER BY created_at ASC', [commId]);
      return res.json(result.rows);
    }
    
    // Very basic parsing for ?or=(and(sender_id.eq.$userId,receiver_id.eq.$peerId)...)
    // To implement properly, a real PostgREST parser or rewriting flutter API is best.
    // For now, return all or mock logic.
    const result = await db.query('SELECT * FROM messages LIMIT 100');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

router.post('/', async (req, res) => {
  try {
    const { sender_id, receiver_id, community_id, message } = req.body;
    const result = await db.query(
      'INSERT INTO messages (sender_id, receiver_id, community_id, message) VALUES ($1, $2, $3, $4) RETURNING *',
      [sender_id, receiver_id || null, community_id || null, message]
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;

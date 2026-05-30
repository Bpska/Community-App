const express = require('express');
const router = express.Router();
const db = require('../db');

// Get admin stats
router.get('/stats', async (req, res) => {
  try {
    const usersCount = await db.query('SELECT COUNT(*)::int as count FROM users');
    const activeUsersCount = await db.query('SELECT COUNT(*)::int as count FROM users WHERE COALESCE(is_active, true) = true');
    const communitiesCount = await db.query('SELECT COUNT(*)::int as count FROM communities');
    const messagesCount = await db.query('SELECT COUNT(*)::int as count FROM messages');

    res.json({
      totalUsers: usersCount.rows[0].count,
      activeUsers: activeUsersCount.rows[0].count,
      totalCommunities: communitiesCount.rows[0].count,
      totalMessages: messagesCount.rows[0].count,
    });
  } catch (err) {
    console.error('Admin stats error:', err);
    res.status(500).json({ message: 'Server error fetching admin stats' });
  }
});

// List all users
router.get('/users', async (req, res) => {
  try {
    const result = await db.query(
      `SELECT id, name, email, bio, gender, age, profile_photo as "profilePhoto", is_active as "isActive", created_at as "createdAt" 
       FROM users 
       ORDER BY created_at DESC`
    );
    res.json(result.rows);
  } catch (err) {
    console.error('Admin list users error:', err);
    res.status(500).json({ message: 'Server error listing users' });
  }
});

// Toggle user active status
router.put('/users/:id/status', async (req, res) => {
  try {
    const { id } = req.params;
    const { isActive } = req.body;

    const result = await db.query(
      'UPDATE users SET is_active = $1, updated_at = CURRENT_TIMESTAMP WHERE id = $2 RETURNING id, name, is_active as "isActive"',
      [isActive, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error('Admin toggle user status error:', err);
    res.status(500).json({ message: 'Server error updating user status' });
  }
});

// Delete user
router.delete('/users/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await db.query('DELETE FROM users WHERE id = $1 RETURNING id, name', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json({ message: 'User deleted successfully', user: result.rows[0] });
  } catch (err) {
    console.error('Admin delete user error:', err);
    res.status(500).json({ message: 'Server error deleting user' });
  }
});

// List all communities
router.get('/communities', async (req, res) => {
  try {
    const result = await db.query(
      `SELECT c.id, c.name, c.description, c.category, c.type, c.radius, c.created_at as "createdAt",
              u.name as "creatorName", 
              COUNT(cm.id)::int as "membersCount"
       FROM communities c
       LEFT JOIN users u ON u.id = c.created_by
       LEFT JOIN community_members cm ON cm.community_id = c.id
       GROUP BY c.id, u.name
       ORDER BY c.created_at DESC`
    );
    res.json(result.rows);
  } catch (err) {
    console.error('Admin list communities error:', err);
    res.status(500).json({ message: 'Server error listing communities' });
  }
});

// Delete community
router.delete('/communities/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await db.query('DELETE FROM communities WHERE id = $1 RETURNING id, name', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Community not found' });
    }

    res.json({ message: 'Community deleted successfully', community: result.rows[0] });
  } catch (err) {
    console.error('Admin delete community error:', err);
    res.status(500).json({ message: 'Server error deleting community' });
  }
});

// List recent messages for moderation
router.get('/messages', async (req, res) => {
  try {
    const result = await db.query(
      `SELECT m.id, m.message, m.status, m.created_at as "createdAt",
              u_send.name as "senderName", 
              u_recv.name as "receiverName",
              c.name as "communityName"
       FROM messages m
       LEFT JOIN users u_send ON u_send.id = m.sender_id
       LEFT JOIN users u_recv ON u_recv.id = m.receiver_id
       LEFT JOIN communities c ON c.id = m.community_id
       ORDER BY m.created_at DESC
       LIMIT 150`
    );
    res.json(result.rows);
  } catch (err) {
    console.error('Admin list messages error:', err);
    res.status(500).json({ message: 'Server error listing messages' });
  }
});

// Delete message
router.delete('/messages/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await db.query('DELETE FROM messages WHERE id = $1 RETURNING id', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Message not found' });
    }

    res.json({ message: 'Message deleted successfully' });
  } catch (err) {
    console.error('Admin delete message error:', err);
    res.status(500).json({ message: 'Server error deleting message' });
  }
});

module.exports = router;

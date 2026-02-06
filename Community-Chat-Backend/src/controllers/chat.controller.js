const pool = require('../config/database');

// Get chat history
exports.getChatHistory = async (req, res) => {
    try {
        const userId = req.user.id;
        const { userId: otherUserId } = req.params;
        const { page = 1, limit = 50 } = req.query;

        const offset = (page - 1) * limit;

        const result = await pool.query(
            `SELECT 
        m.id, m.sender_id, m.receiver_id, m.message, m.status, m.created_at,
        u.name as sender_name, u.profile_photo as sender_photo
       FROM messages m
       JOIN users u ON m.sender_id = u.id
       WHERE ((m.sender_id = $1 AND m.receiver_id = $2) OR (m.sender_id = $2 AND m.receiver_id = $1))
         AND m.community_id IS NULL
       ORDER BY m.created_at DESC
       LIMIT $3 OFFSET $4`,
            [userId, otherUserId, limit, offset]
        );

        const messages = result.rows.map(msg => ({
            id: msg.id,
            senderId: msg.sender_id,
            receiverId: msg.receiver_id,
            senderName: msg.sender_name,
            senderPhoto: msg.sender_photo,
            message: msg.message,
            status: msg.status,
            createdAt: msg.created_at
        }));

        res.json({
            success: true,
            messages: messages.reverse() // Return oldest first
        });
    } catch (error) {
        console.error('Get chat history error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error'
        });
    }
};

// Send message
exports.sendMessage = async (req, res) => {
    try {
        const senderId = req.user.id;
        const { receiverId, communityId, message } = req.body;

        if (!message) {
            return res.status(400).json({
                success: false,
                message: 'Message content is required'
            });
        }

        if (!receiverId && !communityId) {
            return res.status(400).json({
                success: false,
                message: 'Either receiverId or communityId is required'
            });
        }

        const result = await pool.query(
            'INSERT INTO messages (sender_id, receiver_id, community_id, message) VALUES ($1, $2, $3, $4) RETURNING *',
            [senderId, receiverId || null, communityId || null, message]
        );

        const newMessage = result.rows[0];

        res.json({
            success: true,
            message: 'Message sent successfully',
            data: {
                id: newMessage.id,
                senderId: newMessage.sender_id,
                receiverId: newMessage.receiver_id,
                communityId: newMessage.community_id,
                message: newMessage.message,
                status: newMessage.status,
                createdAt: newMessage.created_at
            }
        });
    } catch (error) {
        console.error('Send message error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error'
        });
    }
};

// Get community chat history
exports.getCommunityChatHistory = async (req, res) => {
    try {
        const { communityId } = req.params;
        const { page = 1, limit = 50 } = req.query;

        const offset = (page - 1) * limit;

        const result = await pool.query(
            `SELECT 
        m.id, m.sender_id, m.community_id, m.message, m.status, m.created_at,
        u.name as sender_name, u.profile_photo as sender_photo
       FROM messages m
       JOIN users u ON m.sender_id = u.id
       WHERE m.community_id = $1
       ORDER BY m.created_at DESC
       LIMIT $2 OFFSET $3`,
            [communityId, limit, offset]
        );

        const messages = result.rows.map(msg => ({
            id: msg.id,
            senderId: msg.sender_id,
            communityId: msg.community_id,
            senderName: msg.sender_name,
            senderPhoto: msg.sender_photo,
            message: msg.message,
            status: msg.status,
            createdAt: msg.created_at
        }));

        res.json({
            success: true,
            messages: messages.reverse()
        });
    } catch (error) {
        console.error('Get community chat history error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error'
        });
    }
};

// Get list of conversations
exports.getConversations = async (req, res) => {
    try {
        const userId = req.user.id;

        // Complex query to get latest message for each distinct conversation partner
        const result = await pool.query(
            `WITH LastMessages AS (
                SELECT DISTINCT ON (
                    LEAST(sender_id, receiver_id), 
                    GREATEST(sender_id, receiver_id)
                )
                id, sender_id, receiver_id, message, status, created_at
                FROM messages
                WHERE (sender_id = $1 OR receiver_id = $1)
                AND community_id IS NULL
                ORDER BY 
                    LEAST(sender_id, receiver_id), 
                    GREATEST(sender_id, receiver_id), 
                    created_at DESC
            )
            SELECT 
                lm.*,
                u.id as other_user_id,
                u.name as other_user_name,
                u.profile_photo as other_user_photo,
                u.is_online
            FROM LastMessages lm
            JOIN users u ON u.id = CASE 
                WHEN lm.sender_id = $1 THEN lm.receiver_id 
                ELSE lm.sender_id 
            END
            ORDER BY lm.created_at DESC`,
            [userId]
        );

        const conversations = result.rows.map(row => ({
            id: row.id,
            otherUser: {
                id: row.other_user_id,
                name: row.other_user_name,
                profilePhoto: row.other_user_photo,
                isOnline: row.is_online
            },
            lastMessage: {
                message: row.message,
                senderId: row.sender_id,
                createdAt: row.created_at,
                status: row.status
            }
        }));

        res.json({
            success: true,
            conversations
        });
    } catch (error) {
        console.error('Get conversations error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error'
        });
    }
};

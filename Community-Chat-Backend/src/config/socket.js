const pool = require('./database');

const setupSocketIO = (io) => {
    // Store connected users
    const connectedUsers = new Map();

    io.on('connection', (socket) => {
        console.log(`✅ User connected: ${socket.id}`);

        // User authentication and join
        socket.on('authenticate', async (data) => {
            try {
                const { userId } = data;

                if (userId) {
                    connectedUsers.set(userId, socket.id);
                    socket.userId = userId;

                    // Update user online status
                    await pool.query(
                        'UPDATE users SET is_online = true WHERE id = $1',
                        [userId]
                    );

                    // Broadcast user online event
                    io.emit('user_online', { userId, isOnline: true });

                    console.log(`User ${userId} authenticated`);
                }
            } catch (error) {
                console.error('Authentication error:', error);
            }
        });

        // Private message
        socket.on('private_message', async (data) => {
            try {
                const { senderId, receiverId, message } = data;

                // Save message to database
                const result = await pool.query(
                    'INSERT INTO messages (sender_id, receiver_id, message) VALUES ($1, $2, $3) RETURNING *',
                    [senderId, receiverId, message]
                );

                const newMessage = result.rows[0];

                // Send to receiver if online
                const receiverSocketId = connectedUsers.get(receiverId);
                if (receiverSocketId) {
                    io.to(receiverSocketId).emit('private_message', {
                        id: newMessage.id,
                        senderId: newMessage.sender_id,
                        receiverId: newMessage.receiver_id,
                        message: newMessage.message,
                        status: newMessage.status,
                        createdAt: newMessage.created_at
                    });

                    // Send delivered status back to sender
                    io.to(socket.id).emit('message_delivered', {
                        messageId: newMessage.id,
                        status: 'delivered'
                    });

                    // Update message status
                    await pool.query(
                        'UPDATE messages SET status = $1 WHERE id = $2',
                        ['delivered', newMessage.id]
                    );
                }

                // Send confirmation to sender
                io.to(socket.id).emit('message_sent', {
                    id: newMessage.id,
                    tempId: data.tempId, // Client-side temporary ID for matching
                    status: newMessage.status
                });

            } catch (error) {
                console.error('Private message error:', error);
                socket.emit('message_error', { error: 'Failed to send message' });
            }
        });

        // Community message
        socket.on('community_message', async (data) => {
            try {
                const { senderId, communityId, message } = data;

                // Save message to database
                const result = await pool.query(
                    'INSERT INTO messages (sender_id, community_id, message) VALUES ($1, $2, $3) RETURNING *',
                    [senderId, communityId, message]
                );

                const newMessage = result.rows[0];

                // Get sender info
                const userResult = await pool.query(
                    'SELECT name, profile_photo FROM users WHERE id = $1',
                    [senderId]
                );

                const sender = userResult.rows[0];

                // Broadcast to all members in the community room
                io.to(`community_${communityId}`).emit('community_message', {
                    id: newMessage.id,
                    senderId: newMessage.sender_id,
                    communityId: newMessage.community_id,
                    senderName: sender.name,
                    senderPhoto: sender.profile_photo,
                    message: newMessage.message,
                    createdAt: newMessage.created_at
                });

            } catch (error) {
                console.error('Community message error:', error);
                socket.emit('message_error', { error: 'Failed to send community message' });
            }
        });

        // Join community room
        socket.on('join_community', (data) => {
            const { communityId } = data;
            socket.join(`community_${communityId}`);
            console.log(`User ${socket.userId} joined community ${communityId}`);
        });

        // Leave community room
        socket.on('leave_community', (data) => {
            const { communityId } = data;
            socket.leave(`community_${communityId}`);
            console.log(`User ${socket.userId} left community ${communityId}`);
        });

        // Message seen
        socket.on('message_seen', async (data) => {
            try {
                const { messageId, userId } = data;

                await pool.query(
                    'UPDATE messages SET status = $1 WHERE id = $2',
                    ['seen', messageId]
                );

                // Notify sender
                const messageResult = await pool.query(
                    'SELECT sender_id FROM messages WHERE id = $1',
                    [messageId]
                );

                if (messageResult.rows.length > 0) {
                    const senderId = messageResult.rows[0].sender_id;
                    const senderSocketId = connectedUsers.get(senderId);

                    if (senderSocketId) {
                        io.to(senderSocketId).emit('message_seen', {
                            messageId,
                            status: 'seen'
                        });
                    }
                }
            } catch (error) {
                console.error('Message seen error:', error);
            }
        });

        // Typing indicator
        socket.on('typing', (data) => {
            const { receiverId, isTyping } = data;
            const receiverSocketId = connectedUsers.get(receiverId);

            if (receiverSocketId) {
                io.to(receiverSocketId).emit('typing', {
                    userId: socket.userId,
                    isTyping
                });
            }
        });

        // Disconnect
        socket.on('disconnect', async () => {
            try {
                if (socket.userId) {
                    connectedUsers.delete(socket.userId);

                    // Update user offline status
                    await pool.query(
                        'UPDATE users SET is_online = false WHERE id = $1',
                        [socket.userId]
                    );

                    // Broadcast user offline event
                    io.emit('user_offline', { userId: socket.userId, isOnline: false });

                    console.log(`User ${socket.userId} disconnected`);
                }
            } catch (error) {
                console.error('Disconnect error:', error);
            }
        });
    });
};

module.exports = setupSocketIO;

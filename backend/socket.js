const { Server } = require('socket.io');

let io;
const userSockets = new Map();

function initSocket(server) {
  io = new Server(server, {
    cors: { origin: '*' }
  });

  io.on('connection', (socket) => {
    console.log('New client connected', socket.id);

    socket.on('register', (userId) => {
      userSockets.set(userId, socket.id);
      socket.broadcast.emit('user_online', { userId });
      console.log('User registered for sockets:', userId);
    });

    socket.on('disconnect', () => {
      let disconnectedUserId = null;
      for (const [userId, socketId] of userSockets.entries()) {
        if (socketId === socket.id) {
          disconnectedUserId = userId;
          userSockets.delete(userId);
          break;
        }
      }
      if (disconnectedUserId) {
        socket.broadcast.emit('user_offline', { userId: disconnectedUserId });
      }
      console.log('Client disconnected', socket.id);
    });

    socket.on('private_message', (data) => {
      const { senderId, receiverId, message, tempId } = data;
      const receiverSocketId = userSockets.get(receiverId);
      if (receiverSocketId) {
        io.to(receiverSocketId).emit('private_message', data);
      }
    });

    socket.on('community_message', (data) => {
      socket.broadcast.emit('community_message', data);
    });

    socket.on('mark_seen', (data) => {
      socket.broadcast.emit('message_seen', data);
    });
  });
}

function getIo() {
  if (!io) throw new Error('Socket.io not initialized!');
  return io;
}

module.exports = { initSocket, getIo, userSockets };

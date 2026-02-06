const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

const pool = require('./config/database');
const setupSocketIO = require('./config/socket');

// Import routes
const authRoutes = require('./routes/auth.routes');
const userRoutes = require('./routes/user.routes');
const chatRoutes = require('./routes/chat.routes');
const communityRoutes = require('./routes/community.routes');

// Initialize Express app
const app = express();
const server = http.createServer(app);

// Initialize Socket.IO
const io = new Server(server, {
    cors: {
        origin: '*', // Configure this properly in production
        methods: ['GET', 'POST']
    }
});

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging middleware
app.use((req, res, next) => {
    console.log(`📨 ${new Date().toISOString()} - ${req.method} ${req.url} from ${req.ip}`);
    next();
});

// Serve uploaded files statically
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// Health check route
app.get('/health', (req, res) => {
    res.json({
        success: true,
        message: 'Server is running',
        timestamp: new Date().toISOString()
    });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/user', userRoutes);
app.use('/api/users', userRoutes);
app.use('/api/chat', chatRoutes);
app.use('/api/communities', communityRoutes);

// 404 handler
app.use((req, res) => {
    res.status(404).json({
        success: false,
        message: 'Route not found'
    });
});

// Error handler
app.use((err, req, res, next) => {
    console.error('Error:', err);
    res.status(err.status || 500).json({
        success: false,
        message: err.message || 'Internal server error'
    });
});

// Setup Socket.IO
setupSocketIO(io);

// Server configuration
const PORT = process.env.PORT || 3000;
const HOST = '0.0.0.0'; // Listen on all network interfaces

// Start server
server.listen(PORT, HOST, () => {
    console.log(`
╔═══════════════════════════════════════════════════╗
║                                                   ║
║   🚀 Community Chat Backend Server Running       ║
║                                                   ║
║   📡 Port: ${PORT}                                  ║
║   🗄️  Database: propoly (PostgreSQL)             ║
║   ⚡ Socket.IO: Enabled                          ║
║   🌐 API: http://localhost:${PORT}/api            ║
║   📱 Emulator: http://10.0.2.2:${PORT}/api        ║
║   🏠 LAN: http://10.40.23.107:${PORT}/api         ║
║                                                   ║
╚═══════════════════════════════════════════════════╝
  `);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
    console.log('SIGTERM signal received: closing HTTP server');
    server.close(async () => {
        console.log('HTTP server closed');
        await pool.end();
        process.exit(0);
    });
});

module.exports = { app, server, io };

const express = require('express');
const cors = require('cors');
const http = require('http');
const dotenv = require('dotenv');
const path = require('path');
const { initSocket } = require('./socket');

dotenv.config();

const app = express();
const server = http.createServer(app);
initSocket(server);

app.use(cors());
app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Routes
app.use('/api/auth', require('./routes/authRoutes'));
app.use('/api/users', require('./routes/userRoutes'));
app.use('/api/communities', require('./routes/communityRoutes'));
app.use('/api/messages', require('./routes/messageRoutes'));

// Global error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Internal Server Error' });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT} (accessible on LAN at http://10.77.166.107:${PORT})`);
});

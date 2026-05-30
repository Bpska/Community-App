const express = require('express');
const cors = require('cors');
const http = require('http');
const dotenv = require('dotenv');
const path = require('path');
const fs = require('fs');
const { initSocket } = require('./socket');
const db = require('./db');

dotenv.config();

const app = express();
const server = http.createServer(app);
initSocket(server);

const uploadsDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

app.use(cors());
app.use(express.json());
app.use('/uploads', express.static(uploadsDir));

// Routes
app.use('/api/auth', require('./routes/authRoutes'));
app.use('/api/users', require('./routes/userRoutes'));
app.use('/api/user', require('./routes/userRoutes'));
app.use('/api/communities', require('./routes/communityRoutes'));
app.use('/api/messages', require('./routes/messageRoutes'));

// Global error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Internal Server Error' });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});

async function ensureDatabaseCompatibility() {
  try {
    // 1. Core compatibility alter statements
    await db.query('ALTER TABLE users ADD COLUMN IF NOT EXISTS phone VARCHAR(50)');
    await db.query('ALTER TABLE users ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE');

    // 2. Ensure all other tables are created if not initialized (dynamic migration check)
    const tablesCheck = await db.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' AND table_name IN ('users', 'communities', 'messages', 'community_members')
    `);
    
    if (tablesCheck.rows.length < 4) {
      console.log('Database tables missing. Automatically initializing tables from schema.sql...');
      const fs = require('fs');
      const path = require('path');
      
      // Check parent folder for schema.sql (for docker setups), or backend folder
      let schemaPath = path.join(__dirname, '../schema.sql');
      if (!fs.existsSync(schemaPath)) {
        schemaPath = path.join(__dirname, 'schema.sql');
      }

      if (fs.existsSync(schemaPath)) {
        const schemaSql = fs.readFileSync(schemaPath).toString();
        await db.query(schemaSql);
        console.log('schema.sql successfully initialized on startup!');
      } else {
        console.warn('Could not find schema.sql to execute auto-migrations!');
      }
    }
  } catch (err) {
    console.warn('Database compatibility check skipped:', err.message);
  }
}

ensureDatabaseCompatibility();

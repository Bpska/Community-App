# Community Chat Backend

Express.js backend API for Flutter Community Chat Application

## Features
- ✅ User authentication (JWT)
- ✅ User profile management
- ✅ GPS-based nearby users
- ✅ Real-time private chat (Socket.IO)
- ✅ Community management
- ✅ Real-time community chat
- ✅ File upload (profile photos, community logos/covers)
- ✅ PostgreSQL database (propoly)

## Setup Instructions

### 1. Install Dependencies
```bash
npm install
```

### 2. Configure Environment Variables
Edit `.env` file with your PostgreSQL credentials:
```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=propoly
DB_USER=postgres
DB_PASSWORD=your_password
JWT_SECRET=your_secret_key
```

### 3. Create Database Tables
Run the SQL schema in PostgreSQL:
```bash
psql -U postgres -d propoly -f src/models/db.sql
```

Or connect to your database and run the SQL manually.

### 4. Start the Server

**Development mode (with auto-reload):**
```bash
npm run dev
```

**Production mode:**
```bash
npm start
```

Server will run on `http://localhost:3000`

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user  
- `POST /api/auth/logout` - Logout user (protected)

### User Profile
- `GET /api/user/profile` - Get user profile (protected)
- `PUT /api/user/profile` - Update profile (protected)
- `POST /api/user/upload-photo` - Upload profile photo (protected)
- `GET /api/users/nearby` - Get nearby users (protected)

### Chat
- `GET /api/chat/history/:userId` - Get private chat history (protected)
- `POST /api/chat/send` - Send message (protected)
- `GET /api/chat/community/:communityId` - Get community chat (protected)

### Communities
- `GET /api/communities/list` - Get all communities (protected)
- `GET /api/communities/search` - Search communities (protected)
- `POST /api/communities/create` - Create community (protected)
- `POST /api/communities/join` - Join community (protected)
- `GET /api/communities/details/:id` - Get community details (protected)

## Socket.IO Events

### Client → Server
- `authenticate` - Authenticate user with userId
- `private_message` - Send private message
- `community_message` - Send community message
- `join_community` - Join community room
- `leave_community` - Leave community room
- `message_seen` - Mark message as seen
- `typing` - Send typing indicator

### Server → Client
- `private_message` - Receive private message
- `community_message` - Receive community message
- `message_sent` - Confirmation of sent message
- `message_delivered` - Message delivered to recipient
- `message_seen` - Message seen by recipient
- `user_online` - User came online
- `user_offline` - User went offline
- `typing` - Typing indicator
- `message_error` - Error sending message

## Testing the API

### Register a user:
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"bps kar","email":"bpskar9@gmail.com","password":"1234567"}'
```

### Login:
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"bpskar9@gmail.com","password":"1234567"}'
```

## Connecting Flutter App

Update the Flutter app configuration in `lib/core/config/app_config.dart`:
```dart
static const String apiBaseUrl = 'http://YOUR_IP:3000/api';
static const String socketUrl = 'http://YOUR_IP:3000';
```

**Note:** Replace `YOUR_IP` with your computer's local IP address (not localhost) to test on a physical device.

## Project Structure
```
Community-Chat-Backend/
├── src/
│   ├── config/
│   │   ├── database.js      # PostgreSQL connection
│   │   └── socket.js        # Socket.IO setup
│   ├── middleware/
│   │   ├── auth.js          # JWT authentication
│   │   └── upload.js        # File upload
│   ├── routes/
│   │   ├── auth.routes.js
│   │   ├── user.routes.js
│   │   ├── chat.routes.js
│   │   └── community.routes.js
│   ├── controllers/
│   │   ├── auth.controller.js
│   │   ├── user.controller.js
│   │   ├── chat.controller.js
│   │   └── community.controller.js
│   ├── models/
│   │   └── db.sql           # Database schema
│   └── server.js            # Main entry point
├── uploads/                 # Uploaded files
├── package.json
└── .env                     # Environment variables
```

## License
MIT

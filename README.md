# Community Chat App

A location-based community chat application built with Flutter.

## Features

- 🔐 **Authentication**: Email/Password login and registration with session persistence
- 👤 **User Profiles**: Profile management with photo upload and customizable details
- 📍 **Nearby Users**: GPS-based discovery of users within 2km radius
- 💬 **Private Chat**: Real-time 1-to-1 messaging with Socket.IO
- 🌐 **Communities**: Create and join location-based community groups
- 🔔 **Notifications**: Stay updated with community and chat notifications
- 🎨 **Modern UI**: Material 3 design with dark/light mode support

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. **Clone the repository** (or navigate to the project directory)

```bash
cd Community-App
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Configure Backend**

Edit `lib/core/config/app_config.dart` and update the API and Socket URLs:

```dart
static const String apiBaseUrl = 'YOUR_BACKEND_URL/api';
static const String socketUrl = 'YOUR_SOCKET_URL';
```

4. **Run the app**

```bash
flutter run
```

## Project Structure

```
lib/
├── core/              # Core functionality
│   ├── config/        # App configuration
│   ├── models/        # Data models
│   ├── services/      # Services (API, Storage, Location, Socket, etc.)
│   └── utils/         # Utilities (Validators, Formatters)
├── features/          # Feature modules
│   ├── auth/          # Authentication
│   ├── profile/       # User profiles
│   ├── nearby/        # Nearby users
│   ├── chat/          # Private messaging
│   ├── community/     # Communities
│   └── notifications/ # Notifications
├── shared/            # Shared components
│   ├── widgets/       # Reusable widgets
│   └── layouts/       # Layout components
├── app.dart           # App widget with routing
└── main.dart          # App entry point
```

## Backend Requirements

This app requires a backend server with the following endpoints:

### Authentication
- `POST /auth/login` - User login
- `POST /auth/register` - User registration
- `POST /auth/logout` - User logout

### User Profile
- `GET /user/profile` - Get user profile
- `PUT /user/profile` - Update user profile
- `POST /user/upload-photo` - Upload profile photo

### Nearby Users
- `GET /users/nearby` - Get nearby users (params: latitude, longitude, radius)

### Chat
- `GET /chat/history/:userId` - Get chat history
- `POST /chat/send` - Send message

### Communities
- `GET /communities/list` - Get all communities
- `GET /communities/search` - Search communities
- `POST /communities/create` - Create community
- `POST /communities/join` - Join community
- `GET /communities/details/:id` - Get community details

### Socket.IO Events
- `private_message` - Real-time private messages
- `community_message` - Real-time community messages
- `user_online` / `user_offline` - User online status
- `message_delivered` / `message_seen` - Message status updates

## Packages Used

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `dio` | HTTP client for API calls |
| `socket_io_client` | Real-time messaging |
| `shared_preferences` | Local storage |
| `geolocator` | GPS location services |
| `permission_handler` | Permissions management |
| `image_picker` | Image selection |
| `google_fonts` | Custom fonts |
| `intl` | Date/time formatting |

## Permissions Required

### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

### iOS (`ios/Runner/Info.plist`)

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to find nearby users</string>
<key>NSCameraUsageDescription</key>
<string>We need camera access to take photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to select images</string>
```

## Building for Production

### Android

```bash
flutter build apk --release
```

### iOS

```bash
flutter build ios --release
```

## Contributing

Contributions are welcome! Please feel free to submit pull requests.

## License

This project is open source and available under the MIT License.

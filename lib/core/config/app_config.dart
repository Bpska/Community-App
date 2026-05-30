import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  // API Configuration
  // Android emulator uses 10.0.2.2 to reach host machine's localhost
  // Physical devices use the machine's LAN IP address
  static String get _baseUrl {
    // VPS IP Address: 'http://72.61.169.195:3002'
    // Local IP Address:
    if (kIsWeb) {
      return 'http://72.61.169.195:3002';
    } else if (Platform.isAndroid) {
      return 'http://72.61.169.195:3002';
    } else {
      return 'http://72.61.169.195:3002';
    }
  }

  static String get baseUrl => _baseUrl;
  static String get apiBaseUrl => '$_baseUrl/api';
  static String get authBaseUrl => '$_baseUrl/api/auth';
  static String get socketUrl => _baseUrl;

  static String? resolveMediaUrl(String? value) {
    if (value == null || value.isEmpty) return value;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    if (value.startsWith('/')) {
      return '$_baseUrl$value';
    }
    return value;
  }

  // App Configuration
  static const String appName = 'NearMe';
  static const String appTagline = 'Your City, Filtered to the Five Kilometres That Are Actually Yours.';
  static const String apiKey = 'DEV_API_KEY';
  static const double defaultRadius = 2.0;     // 2km default radius for nearby search
  static const double minRadius = 0.5;          // 500m minimum (pitch deck spec)
  static const double maxRadius = 50.0;         // 50km maximum (pitch deck spec)
  static const int messagePageSize = 50;
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userDataKey = 'user_data';
  
  // Socket Events
  static const String socketPrivateMessage = 'private_message';
  static const String socketCommunityMessage = 'community_message';
  static const String socketUserOnline = 'user_online';
  static const String socketUserOffline = 'user_offline';
  static const String socketMessageDelivered = 'message_delivered';
  static const String socketMessageSeen = 'message_seen';
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 60);
  static const Duration socketTimeout = Duration(seconds: 20);
}

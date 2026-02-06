class AppConfig {
  // API Configuration
  // API Configuration
  // Using ADB Reverse Tunnel (adb reverse tcp:3000 tcp:3000)
  static const String apiBaseUrl = 'http://127.0.0.1:3000/api'; // Tunneled to host
  static const String socketUrl = 'http://127.0.0.1:3000'; // Tunneled to host
  
  // App Configuration
  static const String appName = 'Community Chat';
  static const double defaultRadius = 2.0; // 2km default radius for nearby search
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

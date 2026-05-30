import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/services/api_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/socket_service.dart';
import 'core/services/location_service.dart';
import 'core/services/theme_service.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/nearby/providers/nearby_provider.dart';
import 'features/chat/providers/chat_provider.dart';
import 'features/community/providers/community_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final storageService = await StorageService.getInstance();
  final apiService = await ApiService.getInstance();
  final socketService = await SocketService.getInstance();
  final locationService = LocationService.getInstance();
  
  // Check if user is logged in
  final isLoggedIn = storageService.isLoggedIn();
  
  runApp(
    MultiProvider(
      providers: [
        // Auth Provider
        ChangeNotifierProvider(
          create: (_) => AuthProvider(apiService, storageService)..init(),
        ),
        
        // Profile Provider
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(apiService, storageService),
        ),
        
        // Nearby Provider
        ChangeNotifierProvider(
          create: (_) => NearbyProvider(apiService, locationService),
        ),
        
        // Chat Provider
        ChangeNotifierProvider(
          create: (_) => ChatProvider(apiService, socketService, storageService),
        ),
        
        // Community Provider
        ChangeNotifierProvider(
          create: (_) => CommunityProvider(apiService),
        ),

        ChangeNotifierProvider(
          create: (_) => ThemeService(storageService),
        ),
      ],
      child: App(isLoggedIn: isLoggedIn),
    ),
  );
}

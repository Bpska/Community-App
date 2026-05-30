import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/config/theme_config.dart';
import 'core/services/notification_overlay.dart';
import 'core/services/theme_service.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/profile/screens/edit_profile_screen.dart';
import 'features/profile/screens/security_screen.dart';
import 'features/profile/screens/help_screen.dart';
import 'features/profile/screens/about_screen.dart';
import 'features/profile/screens/blocked_users_screen.dart';
import 'features/profile/screens/theme_settings_screen.dart';
import 'features/profile/screens/notification_settings_screen.dart';
import 'features/profile/screens/account_settings_screen.dart';
import 'features/chat/screens/chat_screen.dart';
import 'features/community/screens/create_community_screen.dart';
import 'features/community/screens/community_detail_screen.dart';
import 'features/community/screens/edit_community_screen.dart';
import 'shared/layouts/main_layout.dart';
import 'core/models/user_model.dart';
import 'core/models/community_model.dart';

import 'package:geolocator/geolocator.dart';
import 'features/home/screens/location_permission_screen.dart';

class App extends StatefulWidget {
  final bool isLoggedIn;

  const App({super.key, required this.isLoggedIn});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // Global key for notifications
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  bool _hasLocationPermission = false;
  bool _isLoadingPermission = true;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    setState(() {
      _hasLocationPermission = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
      _isLoadingPermission = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Set the navigator key for the notification overlay
    NotificationOverlay.setNavigatorKey(navigatorKey);

    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        if (_isLoadingPermission) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (!_hasLocationPermission) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeConfig.lightTheme,
            darkTheme: ThemeConfig.darkTheme,
            themeMode: themeService.themeMode,
            home: LocationPermissionScreen(
              onPermissionGranted: () {
                setState(() {
                  _hasLocationPermission = true;
                });
              },
            ),
          );
        }

        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'NearMe',
          debugShowCheckedModeBanner: false,
          theme: ThemeConfig.lightTheme,
          darkTheme: ThemeConfig.darkTheme,
          themeMode: themeService.themeMode,
          initialRoute: widget.isLoggedIn ? '/main' : '/login',
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/main': (context) => const MainLayout(),
            '/edit-profile': (context) => const EditProfileScreen(),
            '/security': (context) => const SecurityScreen(),
            '/help': (context) => const HelpScreen(),
            '/about': (context) => const AboutScreen(),
            '/blocked-users': (context) => const BlockedUsersScreen(),
            '/theme-settings': (context) => const ThemeSettingsScreen(),
            '/notification-settings': (context) =>
                const NotificationSettingsScreen(),
            '/account-settings': (context) => const AccountSettingsScreen(),
            '/create-community': (context) => const CreateCommunityScreen(),
          },
          onGenerateRoute: (settings) {
            // Handle routes with arguments
            if (settings.name == '/chat') {
              final user = settings.arguments as UserModel;
              return MaterialPageRoute(
                builder: (context) => ChatScreen(otherUser: user),
              );
            }
            // Community detail route
            if (settings.name == '/community-details') {
              final community = settings.arguments as CommunityModel;
              return MaterialPageRoute(
                builder: (context) =>
                    CommunityDetailScreen(community: community),
              );
            }
            // Edit community route
            if (settings.name == '/edit-community') {
              final community = settings.arguments as CommunityModel;
              return MaterialPageRoute(
                builder: (context) =>
                    EditCommunityScreen(community: community),
              );
            }
            return null;
          },
        );
      },
    );
  }
}

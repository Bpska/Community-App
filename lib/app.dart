import 'package:flutter/material.dart';
import 'core/config/theme_config.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/profile/screens/edit_profile_screen.dart';
import 'features/chat/screens/chat_screen.dart';
import 'features/community/screens/create_community_screen.dart';
import 'shared/layouts/main_layout.dart';
import 'core/models/user_model.dart';
import 'core/models/community_model.dart';

class App extends StatelessWidget {
  final bool isLoggedIn;

  const App({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Community Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeConfig.lightTheme,
      darkTheme: ThemeConfig.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: isLoggedIn ? '/main' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const MainLayout(),
        '/edit-profile': (context) => const EditProfileScreen(),
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
        // Handle community details route (to be implemented)
        if (settings.name == '/community-details') {
          final community = settings.arguments as CommunityModel;
          // Return placeholder for now
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: Text(community.name)),
              body: Center(child: Text('Community Details: ${community.name}')),
            ),
          );
        }
        return null;
      },
    );
  }
}

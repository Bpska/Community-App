import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/profile_avatar.dart';
import '../providers/profile_provider.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          if (profileProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (profileProvider.error != null && profileProvider.user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  Text(
                    profileProvider.error!,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => profileProvider.loadProfile(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final user = profileProvider.user;
          if (user == null) {
            return const Center(child: Text('No user data'));
          }

          return CustomScrollView(
            slivers: [
              // Custom AppBar
              SliverAppBar(
                floating: true,
                actions: [
                  IconButton(
                    icon: Icon(Icons.search, color: theme.iconTheme.color?.withAlpha(180)),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert, color: theme.iconTheme.color?.withAlpha(180)),
                    onPressed: () {},
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Profile Header
                    _buildProfileHeader(user, theme),
                    const SizedBox(height: 20),

                    // Account Section
                    _buildSection(theme, [
                      _SettingsItem(
                        icon: Icons.person_rounded,
                        color: colorScheme.primary,
                        title: 'Account Settings',
                        subtitle: 'Username, Bio, Phone',
                        onTap: () => Navigator.pushNamed(context, '/account-settings'),
                      ),
                      _SettingsItem(
                        icon: Icons.shield_rounded,
                        color: const Color(0xFF22C55E),
                        title: 'Security & Privacy',
                        subtitle: 'Password, Privacy settings',
                        onTap: () => Navigator.pushNamed(context, '/security'),
                      ),
                      _SettingsItem(
                        icon: Icons.notifications_rounded,
                        color: const Color(0xFFEF4444),
                        title: 'Notifications',
                        subtitle: 'Sounds, Calls, Badges',
                        onTap: () => Navigator.pushNamed(context, '/notification-settings'),
                      ),
                      _SettingsItem(
                        icon: Icons.palette_rounded,
                        color: const Color(0xFF8B5CF6),
                        title: 'Theme Preferences',
                        subtitle: 'Night Mode, Wallpaper',
                        onTap: () => Navigator.pushNamed(context, '/theme-settings'),
                      ),
                    ]),
                    const SizedBox(height: 12),

                    // More Section
                    _buildSection(theme, [
                      _SettingsItem(
                        icon: Icons.folder_rounded,
                        color: const Color(0xFF06B6D4),
                        title: 'Data and Storage',
                        subtitle: 'Media download settings',
                        onTap: () {},
                      ),
                      _SettingsItem(
                        icon: Icons.block_rounded,
                        color: const Color(0xFFF97316),
                        title: 'Blocked Users',
                        subtitle: 'Manage blocked users',
                        onTap: () => Navigator.pushNamed(context, '/blocked-users'),
                      ),
                      _SettingsItem(
                        icon: Icons.language_rounded,
                        color: const Color(0xFFD946EF),
                        title: 'Language',
                        subtitle: 'English',
                        onTap: () {},
                      ),
                    ]),
                    const SizedBox(height: 12),

                    // Support Section
                    _buildSection(theme, [
                      _SettingsItem(
                        icon: Icons.help_outline_rounded,
                        color: const Color(0xFF14B8A6),
                        title: 'Help & Support',
                        subtitle: 'FAQ, Contact support',
                        onTap: () => Navigator.pushNamed(context, '/help'),
                      ),
                      _SettingsItem(
                        icon: Icons.info_outline_rounded,
                        color: const Color(0xFF64748B),
                        title: 'About',
                        subtitle: 'App version, Terms & Privacy',
                        onTap: () => Navigator.pushNamed(context, '/about'),
                      ),
                    ]),
                    const SizedBox(height: 12),

                    // Logout
                    _buildSection(theme, [
                      _SettingsItem(
                        icon: Icons.logout_rounded,
                        color: const Color(0xFFEF4444),
                        title: 'Log Out',
                        subtitle: '',
                        isDestructive: true,
                        onTap: () => _handleLogout(context),
                      ),
                    ]),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Avatar with camera button
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.tertiary,
                    ],
                  ),
                ),
                child: ProfileAvatar(
                  imageUrl: user.profilePhoto,
                  size: 90,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/edit-profile'),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          
          // Name
          Text(
            user.name,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          
          // Email
          Text(
            user.email,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
              letterSpacing: 0.2,
            ),
          ),

          // Bio
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              user.bio!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withAlpha(180),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(ThemeData theme, List<_SettingsItem> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withAlpha(20),
        ),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;

          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.vertical(
                    top: index == 0 ? const Radius.circular(16) : Radius.zero,
                    bottom: isLast ? const Radius.circular(16) : Radius.zero,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12,
                    ),
                    child: Row(
                      children: [
                        // Colorful icon circle
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: item.color,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            item.icon,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        
                        // Title and subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: item.isDestructive
                                      ? const Color(0xFFEF4444)
                                      : theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                              if (item.subtitle.isNotEmpty)
                                Text(
                                  item.subtitle,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Arrow
                        if (!item.isDestructive)
                          Icon(
                            Icons.chevron_right_rounded,
                            color: theme.textTheme.bodySmall?.color?.withAlpha(120),
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.only(left: 66),
                  child: Divider(
                    height: 1,
                    color: theme.dividerColor.withAlpha(20),
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final theme = Theme.of(context);

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: theme.textTheme.bodySmall?.color)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }
}

class _SettingsItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/community/screens/community_list_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/chat/screens/recent_chats_screen.dart';
import '../../features/chat/providers/chat_provider.dart';
import '../../core/services/socket_service.dart';
import '../../core/services/notification_overlay.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late final AnimationController _slideController;
  late final AnimationController _fadeController;
  SocketService? _socketService;

  final List<Widget> _screens = const [
    HomeScreen(),
    CommunityListScreen(),
    RecentChatsScreen(),
    ProfileScreen(),
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_alt_rounded,
      label: 'Communities',
    ),
    _NavItem(
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
      label: 'Chats',
      showBadge: true,
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 1.0,
    );

    // Set up notification listeners after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupNotificationListeners();
    });
  }

  Future<void> _setupNotificationListeners() async {
    try {
      _socketService = await SocketService.getInstance();
      await _socketService!.connect();

      // Listen for incoming private messages - show popup notification
      _socketService!.on('private_message', (data) {
        final senderName = data['senderName'] ?? 'Someone';
        final message = data['message'] ?? '';
        
        NotificationOverlay.showMessage(
          senderName: senderName,
          message: message,
          onTap: () {
            // Navigate to chats tab
            setState(() {
              _currentIndex = 2;
            });
          },
        );
      });

      // Listen for user online events
      _socketService!.on('user_online', (data) {
        // We could show user online notifications here
        // But it might be too noisy, so we'll keep it subtle
      });

    } catch (e) {
      print('Failed to set up notification listeners: $e');
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    // Clean up notification listeners
    _socketService?.off('private_message');
    _socketService?.off('user_online');
    super.dispose();
  }

  void _onTap(int index) {
    if (_currentIndex == index) return;
    _fadeController.reverse().then((_) {
      setState(() {
        _currentIndex = index;
      });
      _fadeController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final navBgColor = isDark 
        ? const Color(0xFF0A0E27).withAlpha(230) 
        : Colors.white.withAlpha(240);
    final navBorderColor = isDark 
        ? const Color(0xFFD4A017).withAlpha(40) 
        : theme.colorScheme.primary.withAlpha(40);
    final glowColor = isDark 
        ? const Color(0xFFD4A017).withAlpha(15) 
        : theme.colorScheme.primary.withAlpha(15);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      extendBody: true,
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 48,
          right: 48,
          bottom: bottomPadding + 6,
          top: 2,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: navBgColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: navBorderColor,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(80),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: glowColor,
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_navItems.length, (index) {
                  return _buildNavItem(index);
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isSelected = _currentIndex == index;
    final item = _navItems[index];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activeColor = isDark ? const Color(0xFFD4A017) : theme.colorScheme.primary;
    final inactiveColor = isDark ? Colors.grey.shade600 : Colors.grey.shade500;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedNavBuilder(
          animation: _fadeController,
          isSelected: isSelected,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutBack,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSelected ? 14 : 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? activeColor.withAlpha(25)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.8, end: 1.0)
                                .animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Icon(
                        isSelected ? item.activeIcon : item.icon,
                        key: ValueKey(isSelected),
                        size: 24,
                        color: isSelected ? activeColor : inactiveColor,
                      ),
                    ),
                  ),
                  // Badge
                  if (item.showBadge)
                    Consumer<ChatProvider>(
                      builder: (context, chatProvider, child) {
                        final unreadCount = chatProvider.unreadCount;
                        if (unreadCount <= 0) return const SizedBox.shrink();
                        return Positioned(
                          right: 2,
                          top: -2,
                          child: AnimatedScale(
                            scale: 1.0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.elasticOut,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF3B82F6).withAlpha(80),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                unreadCount > 99 ? '99+' : '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 2),
              // Label with smooth animation
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontSize: isSelected ? 10 : 9,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected ? activeColor : inactiveColor,
                  letterSpacing: 0.3,
                ),
                child: Text(item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper widget for smooth fade when switching tabs
class AnimatedNavBuilder extends StatelessWidget {
  final Animation<double> animation;
  final bool isSelected;
  final Widget child;

  const AnimatedNavBuilder({
    super.key,
    required this.animation,
    required this.isSelected,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isSelected ? 1.0 : 0.7,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: child,
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool showBadge;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.showBadge = false,
  });
}

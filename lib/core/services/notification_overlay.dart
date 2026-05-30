import 'package:flutter/material.dart';

class NotificationOverlay {
  static final NotificationOverlay _instance = NotificationOverlay._internal();
  factory NotificationOverlay() => _instance;
  NotificationOverlay._internal();

  static GlobalKey<NavigatorState>? navigatorKey;

  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    navigatorKey = key;
  }

  /// Show a popup notification at the top of the screen
  static void show({
    required String title,
    required String message,
    IconData icon = Icons.notifications,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
  }) {
    final context = navigatorKey?.currentContext;
    if (context == null) return;

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _NotificationPopup(
        title: title,
        message: message,
        icon: icon,
        backgroundColor: backgroundColor ?? const Color(0xFF1E293B),
        duration: duration,
        onTap: () {
          entry.remove();
          onTap?.call();
        },
        onDismiss: () {
          entry.remove();
        },
      ),
    );

    overlay.insert(entry);
  }

  /// Show a message notification
  static void showMessage({
    required String senderName,
    required String message,
    VoidCallback? onTap,
  }) {
    show(
      title: senderName,
      message: message,
      icon: Icons.chat_bubble_rounded,
      backgroundColor: const Color(0xFF1E40AF),
      onTap: onTap,
    );
  }

  /// Show a nearby user notification
  static void showNearbyUser({
    required String userName,
    VoidCallback? onTap,
  }) {
    show(
      title: 'Nearby User',
      message: '$userName is near you!',
      icon: Icons.location_on_rounded,
      backgroundColor: const Color(0xFF059669),
      onTap: onTap,
    );
  }

  /// Show a user online notification
  static void showUserOnline({
    required String userName,
  }) {
    show(
      title: 'User Online',
      message: '$userName is now online',
      icon: Icons.circle,
      backgroundColor: const Color(0xFF0D9488),
      duration: const Duration(seconds: 3),
    );
  }
}

class _NotificationPopup extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Duration duration;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationPopup({
    required this.title,
    required this.message,
    required this.icon,
    required this.backgroundColor,
    required this.duration,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_NotificationPopup> createState() => _NotificationPopupState();
}

class _NotificationPopupState extends State<_NotificationPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    // Auto-dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 8,
      left: 12,
      right: 12,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: widget.onTap,
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta != null && details.primaryDelta! < -5) {
                _dismiss();
              }
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: widget.backgroundColor.withAlpha(100),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withAlpha(40),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        widget.icon,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withAlpha(200),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.close,
                      color: Colors.white.withAlpha(120),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

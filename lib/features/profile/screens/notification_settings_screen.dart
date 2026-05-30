import 'package:flutter/material.dart';
import '../../../shared/widgets/menu_item.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../core/services/storage_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final _storageService = StorageService(); // Ideally use dependency injection or singleton access if strictly defined, but getInstance is static async.
  // Actually StorageService.getInstance() is async.
  
  bool _pushNotifications = true;
  bool _messageNotifications = true;
  bool _communityUpdates = true;
  bool _nearbyUsers = false;
  bool _sound = true;
  bool _vibration = true;
  bool _inAppNotifications = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final storage = await StorageService.getInstance();
    if (mounted) {
      setState(() {
        _pushNotifications = storage.getBool('notifications_push') ?? true;
        _messageNotifications = storage.getBool('notifications_message') ?? true;
        _communityUpdates = storage.getBool('notifications_community') ?? true;
        _nearbyUsers = storage.getBool('notifications_nearby') ?? false;
        _sound = storage.getBool('notifications_sound') ?? true;
        _vibration = storage.getBool('notifications_vibration') ?? true;
        _inAppNotifications = storage.getBool('notifications_in_app') ?? true;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSetting(String key, bool value) async {
    final storage = await StorageService.getInstance();
    await storage.saveBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        children: [
          const SectionHeader(
            title: 'GENERAL',
            subtitle: 'Manage your notification preferences',
          ),
          MenuItem(
            icon: Icons.notifications_outlined,
            title: 'Push Notifications',
            subtitle: 'Enable push notifications',
            trailing: Switch(
              value: _pushNotifications,
              onChanged: (value) {
                setState(() {
                  _pushNotifications = value;
                });
                _saveSetting('notifications_push', value);
              },
            ),
            onTap: null,
          ),
          const SectionHeader(
            title: 'NOTIFICATIONS',
          ),
          MenuItem(
            icon: Icons.message_outlined,
            title: 'Message Notifications',
            subtitle: 'Get notified for new messages',
            trailing: Switch(
              value: _messageNotifications,
              onChanged: (value) {
                setState(() {
                  _messageNotifications = value;
                });
                _saveSetting('notifications_message', value);
              },
            ),
            onTap: null,
          ),
          MenuItem(
            icon: Icons.group_outlined,
            title: 'Community Updates',
            subtitle: 'Get notified for community activities',
            trailing: Switch(
              value: _communityUpdates,
              onChanged: (value) {
                setState(() {
                  _communityUpdates = value;
                });
                _saveSetting('notifications_community', value);
              },
            ),
            onTap: null,
          ),
          MenuItem(
            icon: Icons.location_on_outlined,
            title: 'Nearby Users',
            subtitle: 'Get notified when users are nearby',
            trailing: Switch(
              value: _nearbyUsers,
              onChanged: (value) {
                setState(() {
                  _nearbyUsers = value;
                });
                _saveSetting('notifications_nearby', value);
              },
            ),
            onTap: null,
          ),
          const SectionHeader(
            title: 'ALERTS',
          ),
          MenuItem(
            icon: Icons.volume_up_outlined,
            title: 'Sound',
            subtitle: 'Play sound for notifications',
            trailing: Switch(
              value: _sound,
              onChanged: (value) {
                setState(() {
                  _sound = value;
                });
                _saveSetting('notifications_sound', value);
              },
            ),
            onTap: null,
          ),
          MenuItem(
            icon: Icons.vibration,
            title: 'Vibration',
            subtitle: 'Vibrate for notifications',
            trailing: Switch(
              value: _vibration,
              onChanged: (value) {
                setState(() {
                  _vibration = value;
                });
                _saveSetting('notifications_vibration', value);
              },
            ),
            onTap: null,
          ),
          MenuItem(
            icon: Icons.notifications_active_outlined,
            title: 'In-App Notifications',
            subtitle: 'Show notifications while using the app',
            trailing: Switch(
              value: _inAppNotifications,
              onChanged: (value) {
                setState(() {
                  _inAppNotifications = value;
                });
                _saveSetting('notifications_in_app', value);
              },
            ),
            onTap: null,
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

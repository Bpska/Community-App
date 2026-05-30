import 'package:flutter/material.dart';
import '../../../shared/widgets/menu_item.dart';
import '../../../shared/widgets/section_header.dart';

import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _twoFactorEnabled = false;
  bool _readReceipts = true;
  bool _lastSeenEnabled = true;
  String _profileVisibility = 'Everyone';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security & Privacy'),
      ),
      body: ListView(
        children: [
          const SectionHeader(
            title: 'SECURITY',
            subtitle: 'Manage your account security',
          ),
          MenuItem(
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your password',
            onTap: () {
              _showChangePasswordDialog();
            },
          ),
          MenuItem(
            icon: Icons.security,
            title: 'Two-Factor Authentication',
            subtitle: _twoFactorEnabled ? 'Enabled' : 'Disabled',
            trailing: Switch(
              value: _twoFactorEnabled,
              onChanged: (value) {
                setState(() {
                  _twoFactorEnabled = value;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? 'Two-factor authentication enabled'
                          : 'Two-factor authentication disabled',
                    ),
                  ),
                );
              },
            ),
            onTap: null,
          ),
          const SectionHeader(
            title: 'PRIVACY',
            subtitle: 'Control your privacy settings',
          ),
          MenuItem(
            icon: Icons.visibility_outlined,
            title: 'Profile Visibility',
            subtitle: _profileVisibility,
            onTap: () {
              _showProfileVisibilityDialog();
            },
          ),
          MenuItem(
            icon: Icons.access_time,
            title: 'Last Seen',
            subtitle: _lastSeenEnabled ? 'Everyone' : 'Nobody',
            trailing: Switch(
              value: _lastSeenEnabled,
              onChanged: (value) {
                setState(() {
                  _lastSeenEnabled = value;
                });
              },
            ),
            onTap: null,
          ),
          MenuItem(
            icon: Icons.done_all,
            title: 'Read Receipts',
            subtitle: 'Show when you\'ve read messages',
            trailing: Switch(
              value: _readReceipts,
              onChanged: (value) {
                setState(() {
                  _readReceipts = value;
                });
              },
            ),
            onTap: null,
          ),
          MenuItem(
            icon: Icons.block,
            title: 'Blocked Users',
            subtitle: 'Manage blocked users',
            onTap: () {
              Navigator.pushNamed(context, '/blocked-users');
            },
          ),
          const SectionHeader(
            title: 'DATA & STORAGE',
          ),
          MenuItem(
            icon: Icons.download_outlined,
            title: 'Download My Data',
            subtitle: 'Request a copy of your data',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data download request submitted')),
              );
            },
          ),
          MenuItem(
            icon: Icons.delete_outline,
            title: 'Clear Cache',
            subtitle: 'Free up storage space',
            onTap: () {
              _showClearCacheDialog();
            },
            showDivider: false,
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter current password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter new password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) {
                  if (value != newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            child: const Text('Update'),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final success = await context.read<ProfileProvider>().changePassword(
                  currentPasswordController.text,
                  newPasswordController.text,
                );
                
                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password updated successfully')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to update password')),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showProfileVisibilityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile Visibility'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Everyone'),
              value: 'Everyone',
              groupValue: _profileVisibility,
              onChanged: (value) {
                setState(() {
                  _profileVisibility = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('My Contacts'),
              value: 'My Contacts',
              groupValue: _profileVisibility,
              onChanged: (value) {
                setState(() {
                  _profileVisibility = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Nobody'),
              value: 'Nobody',
              groupValue: _profileVisibility,
              onChanged: (value) {
                setState(() {
                  _profileVisibility = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear the cache? This will free up storage space.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

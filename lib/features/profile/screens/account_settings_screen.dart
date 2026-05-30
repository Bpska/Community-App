import 'package:flutter/material.dart';
import '../../../shared/widgets/menu_item.dart';
import '../../../shared/widgets/section_header.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          return ListView(
            children: [
              const SectionHeader(
                title: 'PROFILE',
                subtitle: 'Manage your profile information',
              ),
              MenuItem(
                icon: Icons.edit_outlined,
                title: 'Edit Profile',
                subtitle: 'Update your profile details',
                onTap: () {
                  Navigator.pushNamed(context, '/edit-profile');
                },
              ),
              MenuItem(
                icon: Icons.email_outlined,
                title: 'Email Address',
                subtitle: provider.user?.email ?? 'user@example.com',
                onTap: () {
                  _showChangeEmailDialog(context);
                },
              ),
              MenuItem(
                icon: Icons.phone_outlined,
                title: 'Phone Number',
                subtitle: provider.user?.phone ?? 'Add phone number',
                onTap: () {
                  _showAddPhoneDialog(context);
                },
              ),
              const SectionHeader(
                title: 'ACCOUNT STATUS',
              ),
              MenuItem(
                icon: Icons.verified_user_outlined,
                title: 'Account Status',
                subtitle: 'Active',
                trailing: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                onTap: null,
              ),
              const SectionHeader(
                title: 'DANGER ZONE',
              ),
              MenuItem(
                icon: Icons.pause_circle_outline,
                title: 'Deactivate Account',
                subtitle: 'Temporarily deactivate your account',
                iconColor: Colors.orange,
                onTap: () {
                  _showDeactivateAccountDialog(context);
                },
              ),
              MenuItem(
                icon: Icons.delete_outline,
                title: 'Delete Account',
                subtitle: 'Permanently delete your account',
                iconColor: Colors.red,
                onTap: () {
                  _showDeleteAccountDialog(context);
                },
                showDivider: false,
              ),
            ],
          );
        },
      ),
    );
  }

  void _showChangeEmailDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your new email address:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'new@example.com',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            child: const Text('Update'),
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final success = await context.read<ProfileProvider>().changeEmail(controller.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Email updated successfully')),
                    );
                  } else {
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to update email')),
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

  void _showAddPhoneDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Phone Number'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your phone number:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: '+1 234 567 8900',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            child: const Text('Add'),
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                 final success = await context.read<ProfileProvider>().changePhone(controller.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Phone number updated successfully')),
                    );
                  } else {
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to update phone number')),
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

  void _showDeactivateAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Account'),
        content: const Text(
          'Are you sure you want to deactivate your account?\n\n'
          'You can reactivate it by logging in again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            child: const Text('Deactivate'),
             onPressed: () async {
              // Navigator.pop(context); // Close dialog first? Or wait? 
              // Better to wait and show loading? For now simple flow.
              final success = await context.read<ProfileProvider>().deactivateAccount();
              if (context.mounted) {
                 Navigator.pop(context);
                 if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Account deactivated')),
                    );
                    // Navigate to login or similar
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                 } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to deactivate account')),
                    );
                 }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account?\n\n'
          'This action is PERMANENT and cannot be undone.\n'
          'All your data will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showConfirmDeleteDialog(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showConfirmDeleteDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Type "DELETE" to confirm:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'DELETE',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            child: const Text('Confirm Delete'),
            onPressed: () async {
              if (controller.text == 'DELETE') {
                 final success = await context.read<ProfileProvider>().deleteAccount();
                 if (context.mounted) {
                    Navigator.pop(context);
                    if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Account deleted')),
                        );
                         Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                    } else {
                       ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to delete account')),
                        );
                    }
                 }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please type DELETE to confirm'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

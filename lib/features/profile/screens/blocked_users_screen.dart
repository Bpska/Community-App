import 'package:flutter/material.dart';
import '../../../shared/widgets/menu_item.dart';
import '../../../shared/widgets/section_header.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  // Mock data - replace with actual data from provider
  List<BlockedUser> blockedUsers = [
    BlockedUser(id: '1', name: 'John Doe', blockedDate: '2023-10-15'),
    BlockedUser(id: '2', name: 'Jane Smith', blockedDate: '2023-11-20'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Users'),
      ),
      body: blockedUsers.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: blockedUsers.length,
              itemBuilder: (context, index) {
                final user = blockedUsers[index];
                return _buildBlockedUserItem(user);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.block,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No blocked users',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Users you block will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedUserItem(BlockedUser user) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              user.name[0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(user.name),
          subtitle: Text('Blocked on ${user.blockedDate}'),
          trailing: OutlinedButton(
            onPressed: () => _showUnblockDialog(user),
            child: const Text('Unblock'),
          ),
        ),
        Divider(height: 1, color: Colors.grey[300]),
      ],
    );
  }

  void _showUnblockDialog(BlockedUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unblock User'),
        content: Text('Are you sure you want to unblock ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                blockedUsers.remove(user);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${user.name} has been unblocked')),
              );
            },
            child: const Text('Unblock'),
          ),
        ],
      ),
    );
  }
}

class BlockedUser {
  final String id;
  final String name;
  final String blockedDate;

  BlockedUser({
    required this.id,
    required this.name,
    required this.blockedDate,
  });
}

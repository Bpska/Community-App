import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/date_formatter.dart';
import '../providers/chat_provider.dart';
import '../../../core/models/user_model.dart';
import 'chat_screen.dart';

class RecentChatsScreen extends StatefulWidget {
  const RecentChatsScreen({super.key});

  @override
  State<RecentChatsScreen> createState() => _RecentChatsScreenState();
}

class _RecentChatsScreenState extends State<RecentChatsScreen> {
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    // Fetch conversations on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().fetchConversations();
      
      // Poll recent conversations list every 5 seconds
      _pollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (mounted) {
          context.read<ChatProvider>().fetchConversations();
        }
      });
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        elevation: 0,
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          if (chatProvider.isLoading && chatProvider.recentConversations.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (chatProvider.error != null && chatProvider.recentConversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    chatProvider.error!,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => chatProvider.fetchConversations(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final conversations = chatProvider.recentConversations;

          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No conversations yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find nearby users to start chatting!',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => chatProvider.fetchConversations(),
            child: ListView.separated(
              itemCount: conversations.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                final otherUser = conversation['otherUser'];
                final lastMessage = conversation['lastMessage'];
                final hasUnread = lastMessage['status'] == 'delivered' && 
                                 lastMessage['senderId'] == otherUser['id'];

                return ListTile(
                  onTap: () async {
                    // Navigate to chat screen
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          otherUser: UserModel(
                            id: otherUser['id'].toString(),
                            name: otherUser['name'],
                            email: '', // Not needed for chat header
                            profilePhoto: otherUser['profilePhoto'],
                            isOnline: otherUser['isOnline'] ?? false,
                            latitude: 0,
                            longitude: 0,
                          ),
                        ),
                      ),
                    );
                    // Refresh list when coming back
                    if (context.mounted) {
                      chatProvider.fetchConversations();
                    }
                  },
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: otherUser['profilePhoto'] != null
                            ? NetworkImage(otherUser['profilePhoto'])
                            : null,
                        child: otherUser['profilePhoto'] == null
                            ? Text(
                                otherUser['name'][0].toUpperCase(),
                                style: const TextStyle(fontSize: 20),
                              )
                            : null,
                      ),
                      if (otherUser['isOnline'] == true)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    otherUser['name'],
                    style: TextStyle(
                      fontWeight: hasUnread ? FontWeight.bold : FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      if (lastMessage['senderId'] != otherUser['id'])
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Text('You:', style: TextStyle(fontSize: 12)),
                        ),
                      Expanded(
                        child: Text(
                          lastMessage['message'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: hasUnread ? Colors.black87 : Colors.grey[600],
                            fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        DateFormatter.formatTime(
                          DateTime.parse(lastMessage['createdAt']),
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: hasUnread 
                              ? Theme.of(context).colorScheme.primary 
                              : Colors.grey[500],
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(height: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/community_model.dart';
import '../../../core/utils/date_formatter.dart';

import '../../chat/providers/chat_provider.dart';
import '../../chat/widgets/message_bubble.dart';
import '../../auth/providers/auth_provider.dart';

class CommunityChatScreen extends StatefulWidget {
  final CommunityModel community;

  const CommunityChatScreen({super.key, required this.community});

  @override
  State<CommunityChatScreen> createState() => _CommunityChatScreenState();
}

class _CommunityChatScreenState extends State<CommunityChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = context.read<ChatProvider>();
      // Fetch history immediately
      chatProvider.fetchCommunityChatHistory(widget.community.id);
      
      // Poll database for new community messages every 2 seconds
      _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
        if (mounted) {
          context.read<ChatProvider>().fetchCommunityChatHistory(widget.community.id);
        }
      });
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final currentUserId = context.read<AuthProvider>().currentUser?.id ?? '';
    context.read<ChatProvider>().sendCommunityMessage(
      widget.community.id,
      _messageController.text.trim(),
      currentUserId,
    );

    _messageController.clear();
    
    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthProvider>().currentUser?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              clipBehavior: Clip.antiAlias,
              child: widget.community.logo != null
                  ? Image.network(
                      widget.community.logo!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.people_rounded,
                        size: 20,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    )
                  : Icon(
                      Icons.people_rounded,
                      size: 20,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.community.name,
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    '${widget.community.membersCount} members',
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                final messages = chatProvider.getCommunityMessages(widget.community.id);

                if (messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet. Say hello to the community!'),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId.toString() == currentUserId.toString();
                    
                    return MessageBubble(
                      message: message.message,
                      isMe: isMe,
                      timestamp: DateFormatter.formatTime(message.timestamp),
                      status: message.status,
                      senderName: message.senderName,
                      senderPhoto: message.senderPhoto,
                    );
                  },
                );
              },
            ),
          ),
          
          // Message Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Message community...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

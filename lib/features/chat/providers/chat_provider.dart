import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/socket_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/models/message_model.dart';

class ChatProvider with ChangeNotifier {
  final ApiService _apiService;
  final SocketService _socketService;
  final StorageService _storageService;

  final Map<String, List<MessageModel>> _conversations = {};
  final Map<String, List<MessageModel>> _communityConversations = {};
  List<dynamic> _recentConversations = [];
  bool _isLoading = false;
  String? _error;

  ChatProvider(this._apiService, this._socketService, StorageService storageService)
      : _storageService = storageService {
    _initializeSocketListeners();
  }

  String? get _currentUserId => _storageService.getUserId();

  Map<String, List<MessageModel>> get conversations => _conversations;
  Map<String, List<MessageModel>> get communityConversations => _communityConversations;
  List<dynamic> get recentConversations => _recentConversations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Count of unread conversations for the badge
  int get unreadCount {
    int count = 0;
    for (final conv in _recentConversations) {
      final lastMessage = conv['lastMessage'];
      final otherUser = conv['otherUser'];
      if (lastMessage != null && otherUser != null) {
        final isFromOther =
            lastMessage['senderId'].toString() == otherUser['id'].toString();
        final status = lastMessage['status'];
        if (isFromOther && status != 'seen') {
          count++;
        }
      }
    }
    return count;
  }

  void _initializeSocketListeners() {
    _socketService.onPrivateMessage((data) {
      final currentUserId = _currentUserId;
      if (currentUserId == null) return;

      final message = MessageModel(
        id: data['id']?.toString() ??
            data['tempId']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: data['senderId']?.toString() ?? '',
        receiverId: data['receiverId']?.toString(),
        message: data['message'] ?? '',
        timestamp: DateTime.now(),
        status: data['status'] ?? 'delivered',
        senderName: data['senderName'],
        senderPhoto: data['senderPhoto'],
      );
      _addMessageToConversation(message);
    });

    _socketService.on('community_message', (data) {
      final currentUserId = _currentUserId;
      if (currentUserId == null) return;

      final message = MessageModel(
        id: data['id']?.toString() ??
            data['tempId']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: data['senderId']?.toString() ?? '',
        communityId: data['communityId']?.toString(),
        message: data['message'] ?? '',
        timestamp: DateTime.now(),
        status: 'delivered',
        senderName: data['senderName'] ?? 'User',
        senderPhoto: data['senderPhoto'],
      );
      if (message.communityId != null) {
        _addMessageToCommunityConversation(message);
      }
    });
  }

  // Get messages for a specific conversation
  List<MessageModel> getMessages(String userId) {
    return _conversations[userId] ?? [];
  }

  // Get messages for a specific community
  List<MessageModel> getCommunityMessages(String communityId) {
    return _communityConversations[communityId] ?? [];
  }

  // Fetch recent conversations (private chats with details)
  Future<void> fetchConversations() async {
    try {
      final currentUserId = _currentUserId;
      if (currentUserId == null) return;
      _error = null;

      // Show loading spinner on first load only
      if (_recentConversations.isEmpty) {
        _isLoading = true;
        notifyListeners();
      }

      final response = await _apiService.get(
        '/messages?or=(sender_id.eq.$currentUserId,receiver_id.eq.$currentUserId)&order=created_at.desc&limit=250',
      );

      if (response.statusCode == 200) {
        final List<dynamic> allMessages = response.data;

        // Group by otherUserId and get the latest message
        final Map<String, dynamic> conversationsMap = {};
        for (var msg in allMessages) {
          final senderId = msg['sender_id']?.toString();
          final receiverId = msg['receiver_id']?.toString();
          if (senderId == null) continue;
          if (msg['community_id'] != null) continue;

          final otherUserId =
              senderId == currentUserId ? receiverId : senderId;
          if (otherUserId == null) continue;

          if (!conversationsMap.containsKey(otherUserId)) {
            conversationsMap[otherUserId] = msg;
          }
        }

        final uniqueUserIds = conversationsMap.keys.toList();
        final List<dynamic> conversationsList = [];

        if (uniqueUserIds.isNotEmpty) {
          final userIdsQuery =
              uniqueUserIds.map((id) => '"$id"').join(',');
          final usersResponse =
              await _apiService.get('/users?id=in.($userIdsQuery)');

          if (usersResponse.statusCode == 200) {
            final List<dynamic> usersData = usersResponse.data;
            final Map<String, dynamic> usersMap = {
              for (var u in usersData) u['id'].toString(): u
            };

            for (var otherId in uniqueUserIds) {
              final user = usersMap[otherId] ?? {
                'id': otherId,
                'name': 'User',
                'is_online': false,
              };
              final lastMsg = conversationsMap[otherId];

              conversationsList.add({
                'otherUser': {
                  'id': user['id'],
                  'name': user['name'] ?? 'User',
                  'profilePhoto': user['profile_photo'],
                  'isOnline': user['is_online'] ?? false,
                },
                'lastMessage': {
                  'id': lastMsg['id']?.toString() ?? '',
                  'senderId': lastMsg['sender_id']?.toString() ?? '',
                  'receiverId': lastMsg['receiver_id']?.toString() ?? '',
                  'message': lastMsg['message'] ?? '',
                  'status': lastMsg['status'] ?? 'sent',
                  'createdAt': lastMsg['created_at'] ??
                      DateTime.now().toIso8601String(),
                }
              });
            }
          }
        }

        _recentConversations = conversationsList;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to fetch conversations: $e');
      _error = 'Failed to load conversations';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch chat history for a private conversation
  Future<void> fetchChatHistory(String userId) async {
    try {
      final currentUserId = _currentUserId;
      if (currentUserId == null) return;
      _error = null;

      if (!_conversations.containsKey(userId)) {
        _isLoading = true;
        notifyListeners();
      }

      final response = await _apiService.get(
        '/messages?or=(and(sender_id.eq.$currentUserId,receiver_id.eq.$userId),and(sender_id.eq.$userId,receiver_id.eq.$currentUserId))&order=created_at.asc',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final messages =
            data.map((json) => MessageModel.fromJson(json)).toList();
        _conversations[userId] = messages;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to fetch chat history: $e');
      _error = 'Failed to load chat history';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch community chat history
  Future<void> fetchCommunityChatHistory(String communityId) async {
    try {
      _error = null;

      if (!_communityConversations.containsKey(communityId)) {
        _isLoading = true;
        notifyListeners();
      }

      final response = await _apiService.get(
        '/messages?community_id=eq.$communityId&order=created_at.asc',
      );

      if (response.statusCode == 200) {
        final List<dynamic> messagesData = response.data;
        final List<MessageModel> rawMessages =
            messagesData.map((json) => MessageModel.fromJson(json)).toList();

        final uniqueSenderIds =
            rawMessages.map((m) => m.senderId).toSet().toList();

        if (uniqueSenderIds.isNotEmpty) {
          final userIdsQuery =
              uniqueSenderIds.map((id) => '"$id"').join(',');
          final usersResponse =
              await _apiService.get('/users?id=in.($userIdsQuery)');

          if (usersResponse.statusCode == 200) {
            final List<dynamic> usersData = usersResponse.data;
            final Map<String, dynamic> usersMap = {
              for (var u in usersData) u['id'].toString(): u
            };

            final messagesWithProfiles = rawMessages.map((msg) {
              final user = usersMap[msg.senderId];
              return msg.copyWith(
                senderName: user != null ? user['name'] : 'User',
                senderPhoto:
                    user != null ? user['profile_photo'] : null,
              );
            }).toList();

            _communityConversations[communityId] = messagesWithProfiles;
          } else {
            _communityConversations[communityId] = rawMessages;
          }
        } else {
          _communityConversations[communityId] = rawMessages;
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to fetch community chat history: $e');
      _error = 'Failed to load community chat history';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send private message
  Future<void> sendMessage(
      String receiverId, String message, String currentUserId) async {
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final newMessage = MessageModel(
      id: tempId,
      senderId: currentUserId,
      receiverId: receiverId,
      message: message,
      timestamp: DateTime.now(),
      status: 'sending',
    );

    _addMessageToConversation(newMessage);

    try {
      final response = await _apiService.post(
        '/messages?select=*',
        data: {
          'sender_id': currentUserId,
          'receiver_id': receiverId,
          'message': message,
          'status': 'sent',
          'created_at': DateTime.now().toUtc().toIso8601String(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final inserted =
            response.data is List ? response.data[0] : response.data;
        final realId = inserted['id'].toString();
        _updateMessageStatus(tempId, 'sent', newId: realId);
        _socketService.sendPrivateMessage(
            currentUserId, receiverId, message, realId);
      } else {
        _updateMessageStatus(tempId, 'failed');
      }
    } catch (e) {
      debugPrint('Failed to send private message: $e');
      _updateMessageStatus(tempId, 'failed');
    }
  }

  // Send community message
  Future<void> sendCommunityMessage(
      String communityId, String message, String currentUserId) async {
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final newMessage = MessageModel(
      id: tempId,
      senderId: currentUserId,
      communityId: communityId,
      message: message,
      timestamp: DateTime.now(),
      status: 'sending',
    );

    _addMessageToCommunityConversation(newMessage);

    try {
      final response = await _apiService.post(
        '/messages?select=*',
        data: {
          'sender_id': currentUserId,
          'community_id': communityId,
          'message': message,
          'status': 'sent',
          'created_at': DateTime.now().toUtc().toIso8601String(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final inserted =
            response.data is List ? response.data[0] : response.data;
        final realId = inserted['id'].toString();
        _updateMessageStatus(tempId, 'sent', newId: realId);
        _socketService.sendCommunityMessage(
            communityId, message, currentUserId);
      } else {
        _updateMessageStatus(tempId, 'failed');
      }
    } catch (e) {
      debugPrint('Failed to send community message: $e');
      _updateMessageStatus(tempId, 'failed');
    }
  }

  void joinCommunity(String communityId) {}
  void leaveCommunity(String communityId) {}

  void _updateMessageStatus(String messageId, String status,
      {String? newId}) {
    _conversations.forEach((userId, messages) {
      final index = messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        messages[index] = messages[index].copyWith(
          id: newId ?? messages[index].id,
          status: status,
        );
        notifyListeners();
      }
    });

    _communityConversations.forEach((communityId, messages) {
      final index = messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        messages[index] = messages[index].copyWith(
          id: newId ?? messages[index].id,
          status: status,
        );
        notifyListeners();
      }
    });
  }

  void _addMessageToConversation(MessageModel message) {
    String otherUserId;
    if (message.senderId == _currentUserId) {
      otherUserId = message.receiverId ?? message.senderId;
    } else {
      otherUserId = message.senderId;
    }

    _conversations[otherUserId] ??= [];
    final index =
        _conversations[otherUserId]!.indexWhere((m) => m.id == message.id);
    if (index != -1) {
      _conversations[otherUserId]![index] = message;
    } else {
      _conversations[otherUserId]!.add(message);
    }
    notifyListeners();
  }

  void _addMessageToCommunityConversation(MessageModel message) {
    final communityId = message.communityId;
    if (communityId == null) return;

    _communityConversations[communityId] ??= [];
    final index = _communityConversations[communityId]!
        .indexWhere((m) => m.id == message.id);
    if (index != -1) {
      _communityConversations[communityId]![index] = message;
    } else {
      _communityConversations[communityId]!.add(message);
    }
    notifyListeners();
  }

  Future<void> markMessagesAsSeen(
      String otherUserId, String currentUserId) async {
    if (_conversations.containsKey(otherUserId)) {
      final messages = _conversations[otherUserId]!;
      bool updated = false;
      for (var i = 0; i < messages.length; i++) {
        final message = messages[i];
        if (message.senderId == otherUserId && message.status != 'seen') {
          messages[i] = message.copyWith(status: 'seen');
          updated = true;
          try {
            await _apiService
                .put('/messages?id=eq.${message.id}', data: {'status': 'seen'});
          } catch (e) {
            debugPrint('Failed to update seen status: $e');
          }
        }
      }
      if (updated) notifyListeners();
    }
  }

  void connect() => _socketService.connect();
  void disconnect() => _socketService.disconnect();
}

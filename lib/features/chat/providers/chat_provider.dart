import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/socket_service.dart';
import '../../../core/models/message_model.dart';

class ChatProvider with ChangeNotifier {
  final ApiService _apiService;
  final SocketService _socketService;
  
  Map<String, List<MessageModel>> _conversations = {}; // userId -> messages
  List<dynamic> _recentConversations = []; // List of recent chats
  bool _isLoading = false;
  String? _error;

  ChatProvider(this._apiService, this._socketService) {
    _initializeSocketListeners();
  }

  Map<String, List<MessageModel>> get conversations => _conversations;
  List<dynamic> get recentConversations => _recentConversations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize socket listeners
  void _initializeSocketListeners() {
    _socketService.onPrivateMessage((data) {
      final message = MessageModel.fromJson(data);
      _addMessageToConversation(message);
      fetchConversations(); // Refresh recent chats list
    });
  }

  // Get messages for a specific conversation
  List<MessageModel> getMessages(String userId) {
    return _conversations[userId] ?? [];
  }

  // Fetch recent conversations
  Future<void> fetchConversations() async {
    try {
      // Don't set loading to true to avoid UI flickering on auto-refresh
      final response = await _apiService.get('/chat/conversations');
      
      if (response.statusCode == 200) {
        _recentConversations = response.data['conversations'];
        notifyListeners();
      }
    } catch (e) {
      print('Failed to fetch conversations: $e');
    }
  }

  // Fetch chat history
  Future<void> fetchChatHistory(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.get('/chat/history/$userId');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['messages'] ?? response.data;
        final messages = data.map((json) => MessageModel.fromJson(json)).toList();
        _conversations[userId] = messages;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load chat history';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send message
  void sendMessage(String receiverId, String message, String currentUserId) {
    final newMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: currentUserId,
      receiverId: receiverId,
      message: message,
      timestamp: DateTime.now(),
      status: 'sent',
    );

    // Add to local conversation
    _addMessageToConversation(newMessage);

    // Send via socket
    _socketService.sendPrivateMessage(receiverId, message);

    // Also send via API as backup
    _apiService.post('/chat/send', data: {
      'receiverId': receiverId,
      'message': message,
    });
  }

  // Add message to conversation
  void _addMessageToConversation(MessageModel message) {
    final otherUserId = message.receiverId ?? message.senderId;
    if (!_conversations.containsKey(otherUserId)) {
      _conversations[otherUserId] = [];
    }
    
    // Check if message already exists (avoid duplicates)
    final exists = _conversations[otherUserId]!.any((m) => 
      m.id == message.id || (m.message == message.message && m.timestamp.difference(message.timestamp).inSeconds.abs() < 1)
    );

    if (!exists) {
        _conversations[otherUserId]!.add(message);
        notifyListeners();
    }
  }

  // Connect to socket
  void connect() {
    _socketService.connect();
  }

  // Disconnect from socket
  void disconnect() {
    _socketService.disconnect();
  }
}

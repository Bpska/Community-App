import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config/app_config.dart';
import 'storage_service.dart';

class SocketService {
  static SocketService? _instance;
  final StorageService _storageService;
  io.Socket? _socket;

  SocketService._(this._storageService);

  static Future<SocketService> getInstance() async {
    if (_instance == null) {
      final storageService = await StorageService.getInstance();
      _instance = SocketService._(storageService);
    }
    return _instance!;
  }

  Future<void> connect() async {
    if (_socket != null && _socket!.connected) return;
    
    final token = _storageService.getToken();
    
    _socket = io.io(AppConfig.socketUrl, io.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .setAuth({'token': token})
        .build()
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      final userId = _storageService.getUserId();
      if (userId != null) {
        _socket!.emit('register', userId);
      }
      debugPrint('SocketService: Connected to socket server.');
    });

    _socket!.onDisconnect((_) {
      debugPrint('SocketService: Disconnected from socket server.');
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    debugPrint('SocketService: Disconnected.');
  }

  bool get isConnected => _socket?.connected ?? false;

  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  void off(String event) {
    _socket?.off(event);
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  void sendPrivateMessage(String senderId, String receiverId, String message, String tempId) {
    emit(AppConfig.socketPrivateMessage, {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'tempId': tempId,
    });
  }

  void sendCommunityMessage(String communityId, String message, String senderId) {
    emit(AppConfig.socketCommunityMessage, {
      'communityId': communityId,
      'message': message,
      'senderId': senderId,
    });
  }

  void onPrivateMessage(Function(dynamic) callback) {
    on(AppConfig.socketPrivateMessage, callback);
  }

  void onCommunityMessage(Function(dynamic) callback) {
    on(AppConfig.socketCommunityMessage, callback);
  }

  void onUserOnline(Function(dynamic) callback) {
    on(AppConfig.socketUserOnline, callback);
  }

  void onUserOffline(Function(dynamic) callback) {
    on(AppConfig.socketUserOffline, callback);
  }

  void onMessageDelivered(Function(dynamic) callback) {
    on(AppConfig.socketMessageDelivered, callback);
  }
  
  void onMessageSent(Function(dynamic) callback) {
    on('message_sent', callback);
  }

  void onMessageSeen(Function(dynamic) callback) {
    on(AppConfig.socketMessageSeen, callback);
  }

  void markAsSeen(String messageId, String userId) {
    emit('mark_seen', {'messageId': messageId, 'userId': userId});
  }

  void dispose() {
    disconnect();
  }
}

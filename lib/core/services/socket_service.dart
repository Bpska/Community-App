import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/app_config.dart';
import 'storage_service.dart';

class SocketService {
  static SocketService? _instance;
  late IO.Socket _socket;
  final StorageService _storageService;
  bool _isConnected = false;

  SocketService._(this._storageService) {
    _initSocket();
  }

  static Future<SocketService> getInstance() async {
    if (_instance == null) {
      final storageService = await StorageService.getInstance();
      _instance = SocketService._(storageService);
    }
    return _instance!;
  }

  void _initSocket() {
    final token = _storageService.getToken();
    
    _socket = IO.io(
      AppConfig.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket.onConnect((_) {
      print('Socket connected');
      _isConnected = true;
    });

    _socket.onDisconnect((_) {
      print('Socket disconnected');
      _isConnected = false;
    });

    _socket.onConnectError((error) {
      print('Socket connection error: $error');
      _isConnected = false;
    });

    _socket.onError((error) {
      print('Socket error: $error');
    });
  }

  // Connect to socket
  void connect() {
    if (!_isConnected) {
      _socket.connect();
    }
  }

  // Disconnect from socket
  void disconnect() {
    if (_isConnected) {
      _socket.disconnect();
      _isConnected = false;
    }
  }

  // Check if connected
  bool get isConnected => _isConnected;

  // Listen to an event
  void on(String event, Function(dynamic) callback) {
    _socket.on(event, callback);
  }

  // Stop listening to an event
  void off(String event) {
    _socket.off(event);
  }

  // Emit an event
  void emit(String event, dynamic data) {
    if (_isConnected) {
      _socket.emit(event, data);
    } else {
      print('Socket not connected. Cannot emit event: $event');
    }
  }

  // Send private message
  void sendPrivateMessage(String receiverId, String message) {
    emit(AppConfig.socketPrivateMessage, {
      'receiverId': receiverId,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Send community message
  void sendCommunityMessage(String communityId, String message) {
    emit(AppConfig.socketCommunityMessage, {
      'communityId': communityId,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Listen to private messages
  void onPrivateMessage(Function(dynamic) callback) {
    on(AppConfig.socketPrivateMessage, callback);
  }

  // Listen to community messages
  void onCommunityMessage(Function(dynamic) callback) {
    on(AppConfig.socketCommunityMessage, callback);
  }

  // Listen to user online status
  void onUserOnline(Function(dynamic) callback) {
    on(AppConfig.socketUserOnline, callback);
  }

  // Listen to user offline status
  void onUserOffline(Function(dynamic) callback) {
    on(AppConfig.socketUserOffline, callback);
  }

  // Listen to message delivered
  void onMessageDelivered(Function(dynamic) callback) {
    on(AppConfig.socketMessageDelivered, callback);
  }

  // Listen to message seen
  void onMessageSeen(Function(dynamic) callback) {
    on(AppConfig.socketMessageSeen, callback);
  }

  // Dispose (cleanup)
  void dispose() {
    disconnect();
    _socket.dispose();
  }
}

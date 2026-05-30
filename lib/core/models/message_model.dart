import '../config/app_config.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String? receiverId;
  final String? communityId;
  final String message;
  final DateTime timestamp;
  final String status; // sent, delivered, seen

  final String? senderName;
  final String? senderPhoto;

  MessageModel({
    required this.id,
    required this.senderId,
    this.receiverId,
    this.communityId,
    required this.message,
    required this.timestamp,
    this.status = 'sent',
    this.senderName,
    this.senderPhoto,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    // Parse timestamp - handle both 'timestamp' and 'createdAt' fields
    DateTime parsedTimestamp = DateTime.now();
    if (json['timestamp'] != null) {
      parsedTimestamp = DateTime.parse(json['timestamp']);
    } else if (json['createdAt'] != null) {
      parsedTimestamp = DateTime.parse(json['createdAt']);
    } else if (json['created_at'] != null) {
      parsedTimestamp = DateTime.parse(json['created_at']);
    }
    
    return MessageModel(
      id: json['id']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? json['sender_id']?.toString() ?? '',
      receiverId: json['receiverId']?.toString() ?? json['receiver_id']?.toString(),
      communityId: json['communityId']?.toString() ?? json['community_id']?.toString(),
      message: json['message'] ?? '',
      timestamp: parsedTimestamp,
      status: json['status'] ?? 'sent',
      senderName: json['senderName'] ?? json['sender_name'],
      senderPhoto: AppConfig.resolveMediaUrl(json['senderPhoto'] ?? json['sender_photo']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'communityId': communityId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'senderName': senderName,
      'senderPhoto': senderPhoto,
    };
  }

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? communityId,
    String? message,
    DateTime? timestamp,
    String? status,
    String? senderName,
    String? senderPhoto,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      communityId: communityId ?? this.communityId,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      senderName: senderName ?? this.senderName,
      senderPhoto: senderPhoto ?? this.senderPhoto,
    );
  }
}


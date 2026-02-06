class MessageModel {
  final String id;
  final String senderId;
  final String? receiverId;
  final String? communityId;
  final String message;
  final DateTime timestamp;
  final String status; // sent, delivered, seen

  MessageModel({
    required this.id,
    required this.senderId,
    this.receiverId,
    this.communityId,
    required this.message,
    required this.timestamp,
    this.status = 'sent',
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? json['sender_id']?.toString() ?? '',
      receiverId: json['receiverId']?.toString() ?? json['receiver_id']?.toString(),
      communityId: json['communityId']?.toString() ?? json['community_id']?.toString(),
      message: json['message'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      status: json['status'] ?? 'sent',
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
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      communityId: communityId ?? this.communityId,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }
}

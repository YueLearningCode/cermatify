class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final DateTime? readAt;
  bool isUnreadFor(String userId) =>
      userId.isNotEmpty &&
      receiverId == userId &&
      senderId != userId &&
      readAt == null;
  final String? orderId; // Order ID for chat room identification

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.readAt,
    this.orderId,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      message: json['message'] as String,
      timestamp: json['timestamp'] is DateTime
          ? json['timestamp'] as DateTime
          : DateTime.parse(json['timestamp'] as String),
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
    };
  }
}

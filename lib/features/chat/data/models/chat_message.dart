class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.createdAt,
  });

  final int id;
  final int roomId;
  final int senderId;
  final String senderName;
  final String content;
  final String createdAt;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: _parseInt(json['message_id'] ?? json['id']),
      roomId: _parseInt(json['conversation_id'] ?? json['room_id'] ?? json['roomId'] ?? 0),
      senderId: _parseInt(json['sender_id'] ?? json['senderId'] ?? 0),
      senderName: _parseString(json['sender_type'] ?? json['sender_name'] ?? json['senderName'] ?? ''),
      content: _parseString(json['text_content'] ?? json['content'] ?? json['message'] ?? ''),
      createdAt: _parseString(json['created_at'] ?? json['createdAt'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'room_id': roomId,
    'sender_id': senderId,
    'sender_name': senderName,
    'content': content,
    'created_at': createdAt,
  };

  ChatMessage copyWith({
    int? id,
    int? roomId,
    int? senderId,
    String? senderName,
    String? content,
    String? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static String _parseString(dynamic v) => v?.toString() ?? '';
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderType,
    required this.senderName,
    required this.content,
    required this.type,
    required this.mediaUrl,
    required this.isRead,
    required this.isDeleted,
    required this.createdAt,
  });

  final int id;
  final int roomId;
  final int senderId;
  final String senderType;
  final String senderName;
  final String content;
  final String type;
  final String mediaUrl;
  final bool isRead;
  final bool isDeleted;
  final String createdAt;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: _parseInt(json['message_id'] ?? json['id']),
      roomId: _parseInt(
        json['conversation_id'] ?? json['room_id'] ?? json['roomId'] ?? 0,
      ),
      senderId: _parseInt(json['sender_id'] ?? json['senderId'] ?? 0),
      senderType: _parseString(json['sender_type'] ?? json['senderType'] ?? ''),
      senderName: _parseString(json['sender_name'] ?? json['senderName'] ?? ''),
      content: _parseString(
        json['text_content'] ?? json['content'] ?? json['message'] ?? '',
      ),
      type: _parseString(json['type'] ?? 'text'),
      mediaUrl: _parseString(json['media_url'] ?? json['mediaUrl'] ?? ''),
      isRead: _parseBool(json['is_read'] ?? json['isRead'] ?? false),
      isDeleted: _parseBool(json['is_deleted'] ?? json['isDeleted'] ?? false),
      createdAt: _parseString(json['created_at'] ?? json['createdAt'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'room_id': roomId,
    'sender_id': senderId,
    'sender_type': senderType,
    'sender_name': senderName,
    'content': content,
    'type': type,
    'media_url': mediaUrl,
    'is_read': isRead,
    'is_deleted': isDeleted,
    'created_at': createdAt,
  };

  ChatMessage copyWith({
    int? id,
    int? roomId,
    int? senderId,
    String? senderType,
    String? senderName,
    String? content,
    String? type,
    String? mediaUrl,
    bool? isRead,
    bool? isDeleted,
    String? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      senderType: senderType ?? this.senderType,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      type: type ?? this.type,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      isRead: isRead ?? this.isRead,
      isDeleted: isDeleted ?? this.isDeleted,
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

  static bool _parseBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final normalized = v.toLowerCase().trim();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }
}

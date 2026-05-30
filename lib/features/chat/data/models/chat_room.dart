class ChatRoom {
  const ChatRoom({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.avatarUrl,
  });

  final int id;
  final String name;
  final String lastMessage;
  final String lastMessageAt;
  final int unreadCount;
  final String avatarUrl;

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: _parseInt(json['conversation_id'] ?? json['id'] ?? json['room_id']),
      name: _parseString(
        json['topic'] ??
            json['name'] ??
            json['room_name'] ??
            'Hỗ trợ bệnh nhân',
      ),
      lastMessage: _parseString(
        json['last_message'] ?? json['lastMessage'] ?? '',
      ),
      lastMessageAt: _parseString(
        json['updated_at'] ??
            json['last_message_at'] ??
            json['lastMessageAt'] ??
            '',
      ),
      unreadCount: _parseInt(json['unread_count'] ?? json['unreadCount'] ?? 0),
      avatarUrl: _parseString(json['avatar_url'] ?? json['avatarUrl'] ?? ''),
    );
  }

  ChatRoom copyWith({
    int? id,
    String? name,
    String? lastMessage,
    String? lastMessageAt,
    int? unreadCount,
    String? avatarUrl,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      avatarUrl: avatarUrl ?? this.avatarUrl,
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

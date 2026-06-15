import 'package:hospital_app/core/l10n/locale_controller.dart';

class ChatRoom {
  const ChatRoom({
    required this.id,
    required this.userId,
    required this.staffId,
    required this.status,
    required this.name,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.avatarUrl,
  });

  final int id;
  final int userId;
  final int staffId;
  final String status;
  final String name;
  final String lastMessage;
  final String lastMessageAt;
  final int unreadCount;
  final String avatarUrl;

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: _parseInt(json['conversation_id'] ?? json['id'] ?? json['room_id']),
      userId: _parseInt(json['user_id'] ?? json['userId'] ?? 0),
      staffId: _parseInt(json['staff_id'] ?? json['staffId'] ?? 0),
      status: _parseString(json['status'] ?? 'open'),
      name: _parseString(
        json['topic'] ??
            json['name'] ??
            json['room_name'] ??
            appL10n.chatSupportDefault,
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
    int? userId,
    int? staffId,
    String? status,
    String? name,
    String? lastMessage,
    String? lastMessageAt,
    int? unreadCount,
    String? avatarUrl,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      staffId: staffId ?? this.staffId,
      status: status ?? this.status,
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

// lib/features/notification/data/models/notification_model.dart

class NotificationModel {
  final int id;           // notif_id
  final String title;     // title
  final String content;   // content  ← NOT "body"
  final bool isRead;      // is_read
  final DateTime createdAt; // created_at
  final String? notifType;  // notif_type ← NOT "type"

  const NotificationModel({
    required this.id,
    required this.title,
    required this.content,
    required this.isRead,
    required this.createdAt,
    this.notifType,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['notif_id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      notifType: json['notif_type'] as String?,
    );
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      content: content,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      notifType: notifType,
    );
  }
}
import 'package:hospital_app/core/l10n/locale_controller.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
  });

  final int id;
  final String title;
  final String message;
  final String createdAt;
  final bool isRead;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final title = _parseString(
      json['title'] ?? json['subject'] ?? json['name'],
    );
    final message = _parseString(
      json['message'] ?? json['content'] ?? json['body'] ?? json['description'],
    );

    return AppNotification(
      id: _parseInt(json['id'] ?? json['notif_id'] ?? json['notification_id']),
      title: title.isEmpty ? appL10n.homeNotificationsTitle : title,
      message: message,
      createdAt: _parseString(
        json['created_at'] ?? json['time'] ?? json['createdAt'],
      ),
      isRead: _parseBool(json['is_read'] ?? json['read'] ?? json['isRead']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'created_at': createdAt,
      'is_read': isRead,
    };
  }

  AppNotification copyWith({
    int? id,
    String? title,
    String? message,
    String? createdAt,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }
}

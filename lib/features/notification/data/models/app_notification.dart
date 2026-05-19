class AppNotification {
  final int id;
  final String title;
  final String message;
  final String time;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: _parseInt(json['id'] ?? json['notif_id'] ?? json['notification_id']),
      title: _parseString(json['title']),
      message: _parseString(json['message'] ?? json['content'] ?? json['body']),
      time: _parseString(json['time'] ?? json['created_at']),
      isRead: _parseBool(json['is_read'] ?? json['read'] ?? json['isRead']),
    );
  }

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      time: time,
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

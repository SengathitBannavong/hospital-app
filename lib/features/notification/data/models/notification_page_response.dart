import 'app_notification.dart';

class NotificationPageResponse {
  const NotificationPageResponse({
    required this.total,
    required this.page,
    required this.limit,
    required this.data,
  });

  final int total;
  final int page;
  final int limit;
  final List<AppNotification> data;

  factory NotificationPageResponse.fromJson(Map<String, dynamic> json) {
    return NotificationPageResponse(
      total: _parseInt(json['total']),
      page: _parseInt(json['page']),
      limit: _parseInt(json['limit']),
      data: _parseList(json['data']),
    );
  }

  bool get hasMore => data.length < total;

  NotificationPageResponse copyWith({
    int? total,
    int? page,
    int? limit,
    List<AppNotification>? data,
  }) {
    return NotificationPageResponse(
      total: total ?? this.total,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      data: data ?? this.data,
    );
  }

  static List<AppNotification> _parseList(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map<String, dynamic>>()
          .map(AppNotification.fromJson)
          .toList(growable: false);
    }

    if (value is Map<String, dynamic>) {
      final nested = value['data'];
      if (nested is List) {
        return nested
            .whereType<Map<String, dynamic>>()
            .map(AppNotification.fromJson)
            .toList(growable: false);
      }
    }

    return const <AppNotification>[];
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

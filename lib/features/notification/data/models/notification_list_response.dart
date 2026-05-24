// lib/features/notification/data/models/notification_list_response.dart

import 'notification_model.dart';

class NotificationListResponse {
  final List<NotificationModel> notifications;
  final int total;
  final int page;
  final int limit;

  const NotificationListResponse({
    required this.notifications,
    required this.total,
    required this.page,
    required this.limit,
  });

  bool get hasMore => (page * limit) < total;

  // Backend returns:
  // { code: 1000, message: "OK", data: { notifications: [...], total, page, limit } }
  factory NotificationListResponse.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] as Map<String, dynamic>? ?? {};
    final rawList = dataMap['notifications'] as List<dynamic>? ?? [];

    return NotificationListResponse(
      notifications: rawList
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (dataMap['total'] as num?)?.toInt() ?? 0,
      page: (dataMap['page'] as num?)?.toInt() ?? 1,
      limit: (dataMap['limit'] as num?)?.toInt() ?? 20,
    );
  }
}
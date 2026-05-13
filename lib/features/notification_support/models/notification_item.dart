import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_item.freezed.dart';
part 'notification_item.g.dart';

@freezed
class NotificationItem with _$NotificationItem {
  const factory NotificationItem({
    @JsonKey(name: 'notif_id') required int notifId,
    @JsonKey(name: 'user_id') required int userId,
    required String title,
    required String content,
    @JsonKey(name: 'notif_type') required String notifType,
    @JsonKey(name: 'is_read') required bool isRead,
    @JsonKey(name: 'ExpiresAt') String? expiresAt,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'ReadAt') String? readAt,
  }) = _NotificationItem;

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemFromJson(json);
}

@freezed
class NotificationList with _$NotificationList {
  const factory NotificationList({
    required int limit,
    required List<NotificationItem> notifications,
    required int page,
    required int total,
  }) = _NotificationList;

  factory NotificationList.fromJson(Map<String, dynamic> json) =>
      _$NotificationListFromJson(json);
}

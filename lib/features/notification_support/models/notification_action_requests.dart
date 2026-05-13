import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_action_requests.freezed.dart';
part 'notification_action_requests.g.dart';

@freezed
class NotificationActionRequest with _$NotificationActionRequest {
  const factory NotificationActionRequest({
    @JsonKey(name: 'notif_id') required int notifId,
  }) = _NotificationActionRequest;

  factory NotificationActionRequest.fromJson(Map<String, dynamic> json) =>
      _$NotificationActionRequestFromJson(json);
}

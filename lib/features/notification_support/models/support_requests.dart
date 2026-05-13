import 'package:freezed_annotation/freezed_annotation.dart';

part 'support_requests.freezed.dart';
part 'support_requests.g.dart';

@freezed
class SosRequest with _$SosRequest {
  const factory SosRequest({
    double? lat,
    double? lng,
    String? note,
  }) = _SosRequest;

  factory SosRequest.fromJson(Map<String, dynamic> json) =>
      _$SosRequestFromJson(json);
}

@freezed
class ChatRoomRequest with _$ChatRoomRequest {
  const factory ChatRoomRequest({
    @JsonKey(name: 'target_user_id') int? targetUserId,
  }) = _ChatRoomRequest;

  factory ChatRoomRequest.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomRequestFromJson(json);
}

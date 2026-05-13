import 'package:freezed_annotation/freezed_annotation.dart';

part 'request_staff_request.freezed.dart';
part 'request_staff_request.g.dart';

@freezed
class RequestStaffRequest with _$RequestStaffRequest {
  const factory RequestStaffRequest({
    @JsonKey(name: 'asset_id') required String assetId,
    @JsonKey(name: 'node_id') required String nodeId,
    String? note,
  }) = _RequestStaffRequest;

  factory RequestStaffRequest.fromJson(Map<String, dynamic> json) =>
      _$RequestStaffRequestFromJson(json);
}

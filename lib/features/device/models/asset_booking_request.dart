import 'package:freezed_annotation/freezed_annotation.dart';

part 'asset_booking_request.freezed.dart';
part 'asset_booking_request.g.dart';

@freezed
class AssetBookingRequest with _$AssetBookingRequest {
  const factory AssetBookingRequest({
    @JsonKey(name: 'asset_id') required String assetId,
  }) = _AssetBookingRequest;

  factory AssetBookingRequest.fromJson(Map<String, dynamic> json) =>
      _$AssetBookingRequestFromJson(json);
}

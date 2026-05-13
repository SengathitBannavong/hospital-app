import 'package:freezed_annotation/freezed_annotation.dart';

part 'release_asset_request.freezed.dart';
part 'release_asset_request.g.dart';

@freezed
class ReleaseAssetRequest with _$ReleaseAssetRequest {
  const factory ReleaseAssetRequest({
    @JsonKey(name: 'asset_id') required String assetId,
    @JsonKey(name: 'station_id') required String stationId,
  }) = _ReleaseAssetRequest;

  factory ReleaseAssetRequest.fromJson(Map<String, dynamic> json) =>
      _$ReleaseAssetRequestFromJson(json);
}

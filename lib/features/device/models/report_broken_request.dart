import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_broken_request.freezed.dart';
part 'report_broken_request.g.dart';

@freezed
class ReportBrokenRequest with _$ReportBrokenRequest {
  const factory ReportBrokenRequest({
    @JsonKey(name: 'asset_id') required String assetId,
    required String reason,
    @JsonKey(name: 'image_url') String? imageUrl,
  }) = _ReportBrokenRequest;

  factory ReportBrokenRequest.fromJson(Map<String, dynamic> json) =>
      _$ReportBrokenRequestFromJson(json);
}

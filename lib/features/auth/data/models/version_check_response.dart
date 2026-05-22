// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'version_check_response.freezed.dart';
part 'version_check_response.g.dart';

@freezed
class VersionCheckResponse with _$VersionCheckResponse {
  const factory VersionCheckResponse({
    @JsonKey(name: 'minimum_version') String? minimumVersion,
    @JsonKey(name: 'latest_version') String? latestVersion,
    @JsonKey(name: 'update_type')
    String? updateType, // 'optional', 'force', or 'none'
    @JsonKey(name: 'message') String? message,
    @JsonKey(name: 'download_url') String? downloadUrl,
  }) = _VersionCheckResponse;

  factory VersionCheckResponse.fromJson(Map<String, dynamic> json) =>
      _$VersionCheckResponseFromJson(json);
}

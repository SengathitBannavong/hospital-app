// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'util_version_check.freezed.dart';
part 'util_version_check.g.dart';

@freezed
class UtilVersionCheck with _$UtilVersionCheck {
  const factory UtilVersionCheck({
    required String status,
    @JsonKey(name: 'latest_version') required String latestVersion,
    @JsonKey(name: 'change_log') required String changeLog,
    @JsonKey(name: 'download_url') required String downloadUrl,
  }) = _UtilVersionCheck;

  factory UtilVersionCheck.fromJson(Map<String, dynamic> json) =>
      _$UtilVersionCheckFromJson(json);
}

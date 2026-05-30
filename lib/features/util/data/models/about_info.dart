// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'about_info.freezed.dart';
part 'about_info.g.dart';

@freezed
class AboutInfo with _$AboutInfo {
  const factory AboutInfo({
    @JsonKey(name: 'hospital_name') required String hospitalName,
    required String description,
    required String version,
  }) = _AboutInfo;

  factory AboutInfo.fromJson(Map<String, dynamic> json) =>
      _$AboutInfoFromJson(json);
}

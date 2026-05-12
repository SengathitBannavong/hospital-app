// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'medical_json_helpers.dart';

part 'result_status.freezed.dart';
part 'result_status.g.dart';

@freezed
class ResultStatus with _$ResultStatus {
  const factory ResultStatus({
    @JsonKey(name: 'treatment_id', fromJson: parseInt) required int treatmentId,
    @JsonKey(name: 'has_result', fromJson: parseBool) required bool hasResult,
    @JsonKey(name: 'status', fromJson: parseString) required String status,
  }) = _ResultStatus;

  factory ResultStatus.fromJson(Map<String, dynamic> json) =>
      _$ResultStatusFromJson(json);
}

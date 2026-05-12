// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'medical_json_helpers.dart';

part 'medical_task.freezed.dart';
part 'medical_task.g.dart';

@freezed
class MedicalTask with _$MedicalTask {
  const factory MedicalTask({
    @JsonKey(name: 'treatment_id', fromJson: parseInt) required int treatmentId,
    @JsonKey(name: 'poi_id', fromJson: parseInt) required int poiId,
    @JsonKey(name: 'poi_name', fromJson: parseString) required String poiName,
    @JsonKey(name: 'ward_name') String? wardName,
    @JsonKey(name: 'task_type', fromJson: parseString) required String taskType,
    @JsonKey(name: 'task_name', fromJson: parseString) required String taskName,
    @JsonKey(name: 'priority', fromJson: parseInt) required int priority,
    @JsonKey(name: 'sequence_number', fromJson: parseInt)
    required int sequenceNumber,
    @JsonKey(name: 'status', fromJson: parseString) required String status,
    @JsonKey(name: 'has_result') required bool hasResult,
    @JsonKey(name: 'checkin_at') String? checkinAt,
    @JsonKey(name: 'completed_at') String? completedAt,
  }) = _MedicalTask;

  factory MedicalTask.fromJson(Map<String, dynamic> json) =>
      _$MedicalTaskFromJson(json);
}

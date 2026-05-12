// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'medical_json_helpers.dart';

part 'queue_status.freezed.dart';
part 'queue_status.g.dart';

@freezed
class QueueStatus with _$QueueStatus {
  const factory QueueStatus({
    @JsonKey(name: 'poi_id', fromJson: parseInt) required int poiId,
    @JsonKey(name: 'current_number', fromJson: parseInt)
    required int currentNumber,
    @JsonKey(name: 'waiting_count', fromJson: parseInt)
    required int waitingCount,
    @JsonKey(name: 'avg_wait_minutes', fromJson: parseDouble)
    required double avgWaitMinutes,
  }) = _QueueStatus;

  factory QueueStatus.fromJson(Map<String, dynamic> json) =>
      _$QueueStatusFromJson(json);
}

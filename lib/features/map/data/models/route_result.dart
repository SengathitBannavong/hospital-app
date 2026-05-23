// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'route_step.dart';

part 'route_result.freezed.dart';
part 'route_result.g.dart';

@freezed
class RouteResult with _$RouteResult {
  const factory RouteResult({
    required List<int> path,
    required List<RouteStep> steps,
    required double distance,
    @JsonKey(name: 'estimated_time') required double estimatedTime,
    @JsonKey(name: 'mode_id') required String modeId,
    @JsonKey(name: 'speed_factor') required double speedFactor,
  }) = _RouteResult;

  factory RouteResult.fromJson(Map<String, dynamic> json) =>
      _$RouteResultFromJson(json);
}

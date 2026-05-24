// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'route_step.freezed.dart';
part 'route_step.g.dart';

enum StepManeuver { start, straight, left, right, uTurn, floorChange, arrive }

@freezed
class RouteStep with _$RouteStep {
  const factory RouteStep({
    required int location,
    required StepManeuver maneuver,
    String? instruction,
    required double distance,
  }) = _RouteStep;

  factory RouteStep.fromJson(Map<String, dynamic> json) =>
      _$RouteStepFromJson(json);
}

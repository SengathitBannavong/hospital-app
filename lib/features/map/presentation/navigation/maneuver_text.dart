import 'package:hospital_app/features/map/data/models/route_step.dart';

String maneuverInstruction(RouteStep step) {
  final instruction = step.instruction;
  if (instruction != null && instruction.trim().isNotEmpty) {
    return instruction.trim();
  }
  return switch (step.maneuver) {
    StepManeuver.start => 'Start navigation',
    StepManeuver.straight => 'Continue straight',
    StepManeuver.left => 'Turn left',
    StepManeuver.right => 'Turn right',
    StepManeuver.uTurn => 'Make a U-turn',
    StepManeuver.floorChange => 'Change floor',
    StepManeuver.arrive => 'Arrive at destination',
  };
}

String maneuverDistanceLabel(double distanceCells) {
  if (distanceCells <= 0) {
    return 'Now';
  }
  return 'In ${distanceCells.toStringAsFixed(0)} cells';
}

String spokenManeuverText(RouteStep step, double distanceCells) {
  final instruction = maneuverInstruction(step).toLowerCase();
  if (distanceCells <= 0) {
    return maneuverInstruction(step);
  }
  return 'In ${distanceCells.toStringAsFixed(0)} cells, $instruction';
}

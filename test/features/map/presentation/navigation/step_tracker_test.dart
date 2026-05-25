import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/features/map/data/models/route_result.dart';
import 'package:hospital_app/features/map/data/models/route_step.dart';
import 'package:hospital_app/features/map/presentation/navigation/position_source.dart';
import 'package:hospital_app/features/map/presentation/navigation/step_tracker.dart';

void main() {
  group('StepTracker', () {
    test('selects current and next instruction at route start', () {
      final state = const StepTracker().track(
        position: const SimulatedPositionSource(
          currentLocation: 0,
          progress: 0,
        ),
        routeResult: _route(),
      );

      expect(state.currentStep?.maneuver, StepManeuver.start);
      expect(state.nextStep?.maneuver, StepManeuver.right);
      expect(state.distanceToNextStep, 2);
    });

    test('advances current and next instruction as progress moves', () {
      final state = const StepTracker().track(
        position: const SimulatedPositionSource(
          currentLocation: 2,
          progress: 0.5,
        ),
        routeResult: _route(),
      );

      expect(state.currentStep?.location, 2);
      expect(state.currentStep?.maneuver, StepManeuver.right);
      expect(state.nextStep?.maneuver, StepManeuver.arrive);
      expect(state.distanceToNextStep, 2);
    });

    test('uses fractional progress for distance to next step', () {
      final state = const StepTracker().track(
        position: const SimulatedPositionSource(
          currentLocation: 1,
          progress: 0.25,
        ),
        routeResult: _route(),
      );

      expect(state.currentStep?.location, 1);
      expect(state.nextStep?.location, 2);
      expect(state.distanceToNextStep, 1);
    });
  });
}

RouteResult _route() {
  return const RouteResult(
    path: [0, 1, 2, 5, 8],
    steps: [
      RouteStep(location: 0, maneuver: StepManeuver.start, distance: 0),
      RouteStep(location: 1, maneuver: StepManeuver.straight, distance: 1),
      RouteStep(location: 2, maneuver: StepManeuver.right, distance: 1),
      RouteStep(location: 5, maneuver: StepManeuver.straight, distance: 1),
      RouteStep(location: 8, maneuver: StepManeuver.arrive, distance: 0),
    ],
    distance: 4,
    estimatedTime: 0.7,
    modeId: 'walking',
    speedFactor: 6,
  );
}

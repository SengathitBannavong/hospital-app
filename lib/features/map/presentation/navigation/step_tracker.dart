import 'package:hospital_app/features/map/data/models/route_result.dart';
import 'package:hospital_app/features/map/data/models/route_step.dart';
import 'package:hospital_app/features/map/presentation/navigation/position_source.dart';

class StepTrackingState {
  final RouteStep? currentStep;
  final RouteStep? nextStep;
  final int currentStepIndex;
  final int? nextStepIndex;
  final double distanceToNextStep;

  const StepTrackingState({
    required this.currentStep,
    required this.nextStep,
    required this.currentStepIndex,
    required this.nextStepIndex,
    required this.distanceToNextStep,
  });

  const StepTrackingState.empty()
    : currentStep = null,
      nextStep = null,
      currentStepIndex = -1,
      nextStepIndex = null,
      distanceToNextStep = 0;
}

class StepTracker {
  const StepTracker();

  StepTrackingState track({
    required PositionSource position,
    required RouteResult? routeResult,
  }) {
    final route = routeResult;
    if (route == null || route.path.isEmpty || route.steps.isEmpty) {
      return const StepTrackingState.empty();
    }

    final exactPathIndex = _exactPathIndex(route.path, position);
    final currentStepIndex = _currentStepIndex(route, exactPathIndex);
    final nextStepIndex = _nextInstructionStepIndex(route, currentStepIndex);

    return StepTrackingState(
      currentStep: route.steps[currentStepIndex],
      nextStep: nextStepIndex == null ? null : route.steps[nextStepIndex],
      currentStepIndex: currentStepIndex,
      nextStepIndex: nextStepIndex,
      distanceToNextStep: _distanceToStep(
        route: route,
        exactPathIndex: exactPathIndex,
        stepIndex: nextStepIndex,
      ),
    );
  }

  double _exactPathIndex(List<int> path, PositionSource position) {
    if (path.length < 2) {
      return 0;
    }

    final progress = position.progress.clamp(0.0, 1.0).toDouble();
    var exact = progress * (path.length - 1);
    final currentLocation = position.currentLocation;
    if (currentLocation != null) {
      final locationIndex = path.indexOf(currentLocation);
      if (locationIndex >= 0 && locationIndex > exact.floor()) {
        exact = locationIndex.toDouble();
      }
    }
    return exact.clamp(0.0, path.length - 1).toDouble();
  }

  int _currentStepIndex(RouteResult route, double exactPathIndex) {
    final currentPathIndex = exactPathIndex.floor();
    var result = 0;
    for (var i = 0; i < route.steps.length; i++) {
      final pathIndex = route.path.indexOf(route.steps[i].location);
      if (pathIndex < 0) {
        continue;
      }
      if (pathIndex <= currentPathIndex) {
        result = i;
      }
    }
    return result.clamp(0, route.steps.length - 1).toInt();
  }

  int? _nextInstructionStepIndex(RouteResult route, int currentStepIndex) {
    for (var i = currentStepIndex + 1; i < route.steps.length; i++) {
      if (route.steps[i].maneuver != StepManeuver.straight) {
        return i;
      }
    }
    if (currentStepIndex + 1 < route.steps.length) {
      return currentStepIndex + 1;
    }
    return null;
  }

  double _distanceToStep({
    required RouteResult route,
    required double exactPathIndex,
    required int? stepIndex,
  }) {
    if (stepIndex == null) {
      return 0;
    }
    final nextPathIndex = route.path.indexOf(route.steps[stepIndex].location);
    if (nextPathIndex < 0) {
      return 0;
    }
    return (nextPathIndex - exactPathIndex)
        .clamp(0.0, double.infinity)
        .toDouble();
  }
}

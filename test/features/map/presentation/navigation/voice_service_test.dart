import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/features/map/data/models/route_step.dart';
import 'package:hospital_app/features/map/presentation/navigation/maneuver_text.dart';
import 'package:hospital_app/features/map/presentation/navigation/step_tracker.dart';
import 'package:hospital_app/features/map/presentation/navigation/voice_service.dart';

void main() {
  group('VoiceCueDecider', () {
    test('new step triggers one utterance', () {
      final decider = VoiceCueDecider();
      final state = _state(
        nextStep: const RouteStep(
          location: 4,
          maneuver: StepManeuver.left,
          distance: 1,
        ),
        nextStepIndex: 2,
        distance: 3,
      );

      final first = decider.decide(state: state, muted: false);
      final second = decider.decide(state: state, muted: false);

      expect(first?.text, spokenManeuverText(state.nextStep!, 3));
      expect(second, isNull);
    });

    test('same step does not repeat', () {
      final decider = VoiceCueDecider();
      final state = _state(
        nextStep: const RouteStep(
          location: 8,
          maneuver: StepManeuver.right,
          distance: 1,
        ),
        nextStepIndex: 3,
        distance: 2,
      );

      expect(decider.decide(state: state, muted: false), isNotNull);
      expect(decider.decide(state: state, muted: false), isNull);
    });

    test('mute suppresses without marking the step spoken', () {
      final decider = VoiceCueDecider();
      final state = _state(
        nextStep: const RouteStep(
          location: 10,
          maneuver: StepManeuver.uTurn,
          distance: 1,
        ),
        nextStepIndex: 4,
        distance: 1,
      );

      expect(decider.decide(state: state, muted: true), isNull);
      expect(decider.decide(state: state, muted: false), isNotNull);
    });

    test('spoken text matches shared helper', () {
      final decider = VoiceCueDecider();
      final state = _state(
        nextStep: const RouteStep(
          location: 12,
          maneuver: StepManeuver.arrive,
          distance: 0,
        ),
        nextStepIndex: 5,
        distance: 0,
      );

      final cue = decider.decide(state: state, muted: false);

      expect(cue?.text, spokenManeuverText(state.nextStep!, 0));
      expect(cue?.text, 'Arrive at destination');
    });
  });
}

StepTrackingState _state({
  required RouteStep nextStep,
  required int nextStepIndex,
  required double distance,
}) {
  return StepTrackingState(
    currentStep: const RouteStep(
      location: 0,
      maneuver: StepManeuver.start,
      distance: 0,
    ),
    nextStep: nextStep,
    currentStepIndex: 0,
    nextStepIndex: nextStepIndex,
    distanceToNextStep: distance,
  );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/features/map/data/models/route_step.dart';
import 'package:hospital_app/features/map/data/services/route_result_mapper.dart';

void main() {
  test('RouteResultMapper maps online preview steps and speed factor', () {
    const mapper = RouteResultMapper();

    final result = mapper.fromPreviewJson({
      'distance': 3,
      'estimated_time': 0.75,
      'mode_id': 'wheelchair',
      'speed_factor': 4,
      'steps': [
        {
          'step_order': 3,
          'grid_row': 0,
          'grid_col': 2,
          'grid_location': 2,
          'maneuver': 'arrive',
        },
        {
          'step_order': 1,
          'grid_row': 0,
          'grid_col': 0,
          'grid_location': 0,
          'maneuver': 'start',
        },
        {
          'step_order': 2,
          'grid_row': 0,
          'grid_col': 1,
          'grid_location': 1,
          'voice_text': 'turn_left',
          'instruction': 'Take the elevator',
          'distance': 1,
        },
      ],
    });

    expect(result.path, [0, 1, 2]);
    expect(result.distance, 3);
    expect(result.estimatedTime, 0.75);
    expect(result.modeId, 'wheelchair');
    expect(result.speedFactor, 4);
    expect(result.steps.map((step) => step.location), [0, 1, 2]);
    expect(result.steps[1].maneuver, StepManeuver.left);
    expect(result.steps[1].voiceText, 'turn_left');
    expect(result.steps[1].instruction, 'Take the elevator');
    expect(result.steps[1].distance, 1);
  });

  test('RouteResultMapper derives maneuvers from voice text', () {
    const mapper = RouteResultMapper();

    expect(mapper.maneuverFromVoiceText('turn_left'), StepManeuver.left);
    expect(mapper.maneuverFromVoiceText('turn_right'), StepManeuver.right);
    expect(mapper.maneuverFromVoiceText('go_straight'), StepManeuver.straight);
    expect(mapper.maneuverFromVoiceText('arrived'), StepManeuver.arrive);
    expect(
      mapper.maneuverFromVoiceText('elevator_up'),
      StepManeuver.floorChange,
    );
    expect(
      mapper.maneuverFromVoiceText('stairs_down'),
      StepManeuver.floorChange,
    );
  });

  test('RouteResultMapper parses backend paths as route steps', () {
    const mapper = RouteResultMapper();

    final result = mapper.fromPreviewJson({
      'distance': 2,
      'paths': [
        {
          'step_order': 2,
          'grid_location': 11,
          'voice_text': 'turn_right',
          'instruction': 'Rẽ phải',
          'distance': 1,
        },
        {
          'step_order': 1,
          'grid_location': 10,
          'voice_text': 'go_straight',
          'instruction': 'Đi thẳng',
          'distance': 1,
        },
      ],
    });

    expect(result.path, [10, 11]);
    expect(result.steps.map((step) => step.location), [10, 11]);
    expect(result.steps[0].voiceText, 'go_straight');
    expect(result.steps[0].instruction, 'Đi thẳng');
    expect(result.steps[0].maneuver, StepManeuver.straight);
    expect(result.steps[1].voiceText, 'turn_right');
    expect(result.steps[1].instruction, 'Rẽ phải');
    expect(result.steps[1].maneuver, StepManeuver.right);
  });
}

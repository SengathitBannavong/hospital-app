import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/features/map/data/models/route_step.dart';
import 'package:hospital_app/features/map/data/services/route_modes.dart';
import 'package:hospital_app/features/map/data/services/routing_engine.dart';

void main() {
  group('RoutingEngine', () {
    test('computes a route with cell-based distance and eta', () {
      final result = RoutingEngine().route(
        startLocation: 0,
        destLocation: 2,
        modeId: 'walking',
        adjacency: const {
          0: [1],
          1: [0, 2],
          2: [1],
        },
        cols: 3,
      );

      expect(result.path, [0, 1, 2]);
      expect(result.distance, 2);
      expect(result.estimatedTime, 2 / baseSpeedFor('walking'));
      expect(result.steps.map((step) => step.maneuver), [
        StepManeuver.start,
        StepManeuver.straight,
        StepManeuver.arrive,
      ]);
    });

    test('excludes blocked edges', () {
      final result = RoutingEngine().route(
        startLocation: 0,
        destLocation: 2,
        modeId: 'walking',
        adjacency: const {
          0: [1, 3],
          1: [0, 2],
          2: [1, 5],
          3: [0, 4],
          4: [3, 5],
          5: [4, 2],
        },
        cols: 3,
        edgeStatuses: {
          edgeStatusKey(1, 2): const EdgeStatus(
            fromLocation: 1,
            toLocation: 2,
            blocked: true,
          ),
        },
      );

      expect(result.path, [0, 3, 4, 5, 2]);
    });
  });
}

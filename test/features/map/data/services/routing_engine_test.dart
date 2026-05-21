import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/features/map/data/models/edge_status.dart';
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
          2: [1, 4],
          3: [0, 4],
          4: [3, 2],
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

      expect(result.path, [0, 3, 4, 2]);
    });

    test('prefers lower-cost routes when flow congestion is present', () {
      final result = RoutingEngine().route(
        startLocation: 0,
        destLocation: 2,
        modeId: 'walking',
        adjacency: const {
          0: [1, 3],
          1: [0, 2],
          2: [1, 4],
          3: [0, 4],
          4: [3, 2],
        },
        cols: 3,
        edgeStatuses: {
          edgeStatusKey(0, 1): const EdgeStatus(
            fromLocation: 0,
            toLocation: 1,
            congestion: 1,
          ),
          edgeStatusKey(1, 2): const EdgeStatus(
            fromLocation: 1,
            toLocation: 2,
            congestion: 1,
          ),
        },
      );

      expect(result.path, [0, 3, 4, 2]);
      expect(result.distance, 3);
    });

    test('uses screen coordinates for left and right maneuvers', () {
      final rightTurn = RoutingEngine().route(
        startLocation: 0,
        destLocation: 5,
        modeId: 'walking',
        adjacency: const {
          0: [1],
          1: [0, 2],
          2: [1, 5],
          5: [2],
        },
        cols: 3,
      );
      final leftTurn = RoutingEngine().route(
        startLocation: 0,
        destLocation: 7,
        modeId: 'walking',
        adjacency: const {
          0: [3],
          3: [0, 6],
          6: [3, 7],
          7: [6],
        },
        cols: 3,
      );

      expect(rightTurn.steps[2].maneuver, StepManeuver.right);
      expect(leftTurn.steps[2].maneuver, StepManeuver.left);
    });
  });
}

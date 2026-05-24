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

    test('avoids POI cells as pass-through intermediates', () {
      // Grid (3 cols):
      //   0 - 1 - 2
      //   |       |
      //   3       4
      // Node 1 is a POI. Direct path 0→1→2 should detour via 3→...→4.
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
        poiCells: {1},
      );

      expect(result.path, isNot(contains(1)));
      expect(result.path.first, 0);
      expect(result.path.last, 2);
    });

    test('routes to and from a POI cell as endpoint', () {
      // POI as destination — should still be reachable.
      final toDest = RoutingEngine().route(
        startLocation: 0,
        destLocation: 1,
        modeId: 'walking',
        adjacency: const {
          0: [1],
          1: [0, 2],
          2: [1],
        },
        cols: 3,
        poiCells: {1},
      );

      expect(toDest.path, [0, 1]);

      // POI as start — should not be blocked.
      final fromStart = RoutingEngine().route(
        startLocation: 1,
        destLocation: 2,
        modeId: 'walking',
        adjacency: const {
          0: [1],
          1: [0, 2],
          2: [1],
        },
        cols: 3,
        poiCells: {1},
      );

      expect(fromStart.path, [1, 2]);
    });

    test('falls back to unrestricted path when POI blocking '
        'isolates the destination', () {
      // Only path is 0→1→2 and node 1 is a POI. With
      // POI restriction the path is empty, so the engine
      // should fall back to unrestricted routing.
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
        poiCells: {1},
      );

      expect(result.path, [0, 1, 2]);
    });

    test('detours around bottleneck cell when '
        'alternative exists', () {
      // Grid (3 cols):
      //   0 - 1 - 2
      //   |       |
      //   3       4
      // Cell 1 has bottleneck weight 1.0. The engine
      // should prefer 0→3→4→2 (longer but cheaper).
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
        bottleneckWeights: {1: 1.0},
      );

      expect(
        result.path,
        isNot(contains(1)),
        reason: 'should avoid bottleneck cell 1',
      );
      expect(result.path.first, 0);
      expect(result.path.last, 2);
    });

    test('passes through bottleneck when it is '
        'the only path', () {
      // Only path is 0→1→2, bottleneck on 1.
      // Soft penalty — path is still returned.
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
        bottleneckWeights: {1: 1.0},
      );

      expect(result.path, [0, 1, 2]);
    });

    test('empty bottleneckWeights produces the same '
        'route as without', () {
      final baseline = RoutingEngine().route(
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
      );

      final withEmpty = RoutingEngine().route(
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
        bottleneckWeights: const <int, double>{},
      );

      expect(withEmpty.path, baseline.path);
    });
  });
}

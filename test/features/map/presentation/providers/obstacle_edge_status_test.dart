import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/features/map/data/models/edge_status.dart';
import 'package:hospital_app/features/map/data/models/flow_cell.dart';
import 'package:hospital_app/features/map/data/models/flow_snapshot.dart';
import 'package:hospital_app/features/map/data/models/map_obstacle.dart';
import 'package:hospital_app/features/map/data/services/routing_engine.dart';
import 'package:hospital_app/features/map/presentation/providers/map_provider.dart';

void main() {
  test('obstacles synthesize blocked incident edge statuses', () {
    final result = mergeObstacleEdgeStatuses(
      edgeStatuses: {
        edgeStatusKey(4, 5): const EdgeStatus(
          fromLocation: 4,
          toLocation: 5,
          congestion: 0.4,
        ),
      },
      obstacles: [
        MapObstacle(
          id: 'obs-4',
          gridLocation: 4,
          type: 'blockage',
          reportedAt: DateTime.utc(2026, 5, 22),
        ),
      ],
      adjacency: const {
        4: [1, 5],
      },
    );

    expect(result[edgeStatusKey(4, 1)]?.blocked, isTrue);
    expect(result[edgeStatusKey(4, 5)]?.blocked, isTrue);
    expect(result[edgeStatusKey(4, 5)]?.congestion, 0.4);
  });

  test(
    'corridorStatusProvider derives congestion and blocked status',
    () async {
      final container = ProviderContainer(
        overrides: [
          flowSnapshotProvider.overrideWith(
            (ref, mapId) async => FlowSnapshot(
              cells: const [
                FlowCell(location: 1, density: 0.25),
                FlowCell(location: 2, density: 0.75),
              ],
              edgeStatuses: const [],
              alerts: const [],
              updatedAt: DateTime.utc(2026, 5, 24),
            ),
          ),
          adjacencyProvider.overrideWith(
            (ref, mapId) => const {
              1: [2],
              2: [1, 3],
              3: [2],
            },
          ),
          mapObstaclesProvider.overrideWith(
            (ref, mapId) async => [
              MapObstacle(
                id: 'obs-3',
                gridLocation: 3,
                type: 'blockage',
                reportedAt: DateTime.utc(2026, 5, 24),
              ),
            ],
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(flowSnapshotProvider(1).future);
      await container.read(mapObstaclesProvider(1).future);

      final statuses = container.read(corridorStatusProvider(1));
      final byKey = {
        for (final status in statuses)
          edgeStatusKey(status.fromLocation, status.toLocation): status,
      };

      expect(statuses, hasLength(2));
      expect(byKey[edgeStatusKey(1, 2)]?.congestion, 0.75);
      expect(byKey[edgeStatusKey(1, 2)]?.blocked, isFalse);
      expect(byKey[edgeStatusKey(2, 3)]?.congestion, 0.75);
      expect(byKey[edgeStatusKey(2, 3)]?.blocked, isTrue);
    },
  );
}

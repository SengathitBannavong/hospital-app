import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/features/map/data/models/edge_status.dart';
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
}

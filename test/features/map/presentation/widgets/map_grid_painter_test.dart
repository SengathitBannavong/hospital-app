import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/features/map/data/models/edge_status.dart';
import 'package:hospital_app/features/map/data/models/flow_cell.dart';
import 'package:hospital_app/features/map/presentation/widgets/map_grid_painter.dart';

void main() {
  group('MapGridPainter shouldRepaint Tests', () {
    test('shouldRepaint returns false for identical painters', () {
      final painter1 = MapGridPainter(
        rows: 10,
        cols: 10,
        walkableLocations: const {1, 2, 3},
        pois: const [],
        routeLocations: const [],
      );

      final painter2 = MapGridPainter(
        rows: 10,
        cols: 10,
        walkableLocations: const {1, 2, 3},
        pois: const [],
        routeLocations: const [],
      );

      expect(painter1.shouldRepaint(painter2), isFalse);
    });

    test('shouldRepaint returns true when showEdgeStatus changes', () {
      final painter1 = MapGridPainter(
        rows: 10,
        cols: 10,
        walkableLocations: const {1, 2, 3},
        pois: const [],
        routeLocations: const [],
        showEdgeStatus: false,
      );

      final painter2 = MapGridPainter(
        rows: 10,
        cols: 10,
        walkableLocations: const {1, 2, 3},
        pois: const [],
        routeLocations: const [],
        showEdgeStatus: true,
      );

      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test('shouldRepaint returns true when edgeStatuses changes', () {
      final painter1 = MapGridPainter(
        rows: 10,
        cols: 10,
        walkableLocations: const {1, 2, 3},
        pois: const [],
        routeLocations: const [],
        edgeStatuses: const [],
      );

      final painter2 = MapGridPainter(
        rows: 10,
        cols: 10,
        walkableLocations: const {1, 2, 3},
        pois: const [],
        routeLocations: const [],
        edgeStatuses: const [
          EdgeStatus(fromLocation: 1, toLocation: 2, congestion: 0.5),
        ],
      );

      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test('shouldRepaint returns true when showBottlenecks changes', () {
      final painter1 = MapGridPainter(
        rows: 10,
        cols: 10,
        walkableLocations: const {1, 2, 3},
        pois: const [],
        routeLocations: const [],
        showBottlenecks: false,
      );

      final painter2 = MapGridPainter(
        rows: 10,
        cols: 10,
        walkableLocations: const {1, 2, 3},
        pois: const [],
        routeLocations: const [],
        showBottlenecks: true,
      );

      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test('shouldRepaint returns true when bottlenecks changes', () {
      final painter1 = MapGridPainter(
        rows: 10,
        cols: 10,
        walkableLocations: const {1, 2, 3},
        pois: const [],
        routeLocations: const [],
        bottlenecks: const [],
      );

      final painter2 = MapGridPainter(
        rows: 10,
        cols: 10,
        walkableLocations: const {1, 2, 3},
        pois: const [],
        routeLocations: const [],
        bottlenecks: const [FlowCell(location: 1, density: 5)],
      );

      expect(painter1.shouldRepaint(painter2), isTrue);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/features/map/data/models/edge_status.dart';
import 'package:hospital_app/features/map/data/models/flow_cell.dart';
import 'package:hospital_app/features/map/presentation/widgets/map_grid_painter.dart';

void main() {
  group('MapStaticPainter shouldRepaint Tests', () {
    test('shouldRepaint returns false for identical painters', () {
      final painter1 = MapStaticPainter(
        rows: 10,
        cols: 10,
        walkableRuns: const [],
        pois: const [],
      );

      final painter2 = MapStaticPainter(
        rows: 10,
        cols: 10,
        walkableRuns: const [],
        pois: const [],
      );

      expect(painter1.shouldRepaint(painter2), isFalse);
    });

    test('shouldRepaint returns true when showEdgeStatus changes', () {
      final painter1 = MapStaticPainter(
        rows: 10,
        cols: 10,
        walkableRuns: const [],
        pois: const [],
        showEdgeStatus: false,
      );

      final painter2 = MapStaticPainter(
        rows: 10,
        cols: 10,
        walkableRuns: const [],
        pois: const [],
        showEdgeStatus: true,
      );

      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test('shouldRepaint returns true when edgeStatuses changes', () {
      final painter1 = MapStaticPainter(
        rows: 10,
        cols: 10,
        walkableRuns: const [],
        pois: const [],
        edgeStatuses: const [],
      );

      final painter2 = MapStaticPainter(
        rows: 10,
        cols: 10,
        walkableRuns: const [],
        pois: const [],
        edgeStatuses: const [
          EdgeStatus(fromLocation: 1, toLocation: 2, congestion: 0.5),
        ],
      );

      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test('shouldRepaint returns true when showBottlenecks changes', () {
      final painter1 = MapStaticPainter(
        rows: 10,
        cols: 10,
        walkableRuns: const [],
        pois: const [],
        showBottlenecks: false,
      );

      final painter2 = MapStaticPainter(
        rows: 10,
        cols: 10,
        walkableRuns: const [],
        pois: const [],
        showBottlenecks: true,
      );

      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test('shouldRepaint returns true when bottlenecks changes', () {
      final painter1 = MapStaticPainter(
        rows: 10,
        cols: 10,
        walkableRuns: const [],
        pois: const [],
        bottlenecks: const [],
      );

      final painter2 = MapStaticPainter(
        rows: 10,
        cols: 10,
        walkableRuns: const [],
        pois: const [],
        bottlenecks: const [FlowCell(location: 1, density: 5)],
      );

      expect(painter1.shouldRepaint(painter2), isTrue);
    });
  });

  group('MapDynamicPainter shouldRepaint Tests', () {
    test('shouldRepaint returns false for identical painters', () {
      final painter1 = MapDynamicPainter(
        rows: 10,
        cols: 10,
        routeLocations: const [],
      );

      final painter2 = MapDynamicPainter(
        rows: 10,
        cols: 10,
        routeLocations: const [],
      );

      expect(painter1.shouldRepaint(painter2), isFalse);
    });

    test('shouldRepaint returns true when routeProgress changes', () {
      final painter1 = MapDynamicPainter(
        rows: 10,
        cols: 10,
        routeLocations: const [],
        routeProgress: 0.5,
      );

      final painter2 = MapDynamicPainter(
        rows: 10,
        cols: 10,
        routeLocations: const [],
        routeProgress: 0.6,
      );

      expect(painter1.shouldRepaint(painter2), isTrue);
    });
  });
}

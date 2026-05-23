import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/features/map/data/models/flow_cell.dart';

/// Stand-alone unit tests for the bottleneck-weight
/// normalization logic used by
/// `bottleneckWeightsProvider`.
///
/// The logic is extracted here to keep the test
/// deterministic (no Riverpod container needed).
Map<int, double> normalizeBottleneckWeights({
  required List<FlowCell> cells,
  required int rows,
  required int cols,
}) {
  if (cells.isEmpty) return const <int, double>{};

  final maxCell = rows * cols;

  double maxDensity = 0;
  for (final c in cells) {
    if (c.density > maxDensity) maxDensity = c.density;
  }
  if (maxDensity <= 0) return const <int, double>{};

  final result = <int, double>{};
  for (final c in cells) {
    if (c.location >= maxCell) continue;
    result[c.location] = c.density / maxDensity;
  }
  return result;
}

void main() {
  group('normalizeBottleneckWeights', () {
    test('max density maps to 1.0, others '
        'proportional', () {
      final weights = normalizeBottleneckWeights(
        cells: const [
          FlowCell(location: 0, density: 10),
          FlowCell(location: 1, density: 5),
          FlowCell(location: 2, density: 2),
        ],
        rows: 3,
        cols: 3,
      );

      expect(weights[0], 1.0);
      expect(weights[1], 0.5);
      expect(weights[2], closeTo(0.2, 1e-9));
    });

    test('drops cells outside floor grid', () {
      // Grid is 2×2 → maxCell = 4.  Cell 10 is
      // off-floor and must be dropped.
      final weights = normalizeBottleneckWeights(
        cells: const [
          FlowCell(location: 1, density: 8),
          FlowCell(location: 10, density: 4),
        ],
        rows: 2,
        cols: 2,
      );

      expect(weights, {1: 1.0});
      expect(weights.containsKey(10), isFalse);
    });

    test('empty input returns empty map', () {
      final weights = normalizeBottleneckWeights(
        cells: const [],
        rows: 5,
        cols: 5,
      );

      expect(weights, isEmpty);
    });

    test('all-zero density returns empty map', () {
      final weights = normalizeBottleneckWeights(
        cells: const [
          FlowCell(location: 0, density: 0),
          FlowCell(location: 1, density: 0),
        ],
        rows: 3,
        cols: 3,
      );

      expect(weights, isEmpty);
    });
  });
}

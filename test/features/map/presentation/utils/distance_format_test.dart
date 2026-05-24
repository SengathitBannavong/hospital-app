import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/features/map/presentation/utils/distance_format.dart';

void main() {
  test('cellsToMeters scales by kMetersPerCell', () {
    expect(cellsToMeters(0), 0);
    expect(cellsToMeters(5), 5 * kMetersPerCell);
  });

  test('formatDistanceFromCells renders meters and kilometers', () {
    expect(formatDistanceFromCells(0), '0 m');
    expect(formatDistanceFromCells(12), '${(12 * kMetersPerCell).round()} m');
    expect(formatDistanceFromCells(1500 / kMetersPerCell), '1.5 km');
  });

  test('spokenDistanceFromCells uses full words', () {
    final meters = (8 * kMetersPerCell).round();
    expect(spokenDistanceFromCells(8), '$meters meters');
    expect(spokenDistanceFromCells(2300 / kMetersPerCell), '2.3 kilometers');
  });
}

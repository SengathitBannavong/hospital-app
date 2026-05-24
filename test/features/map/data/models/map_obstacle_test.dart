import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/features/map/data/models/map_obstacle.dart';

void main() {
  test('MapObstacle round-trips JSON', () {
    final obstacle = MapObstacle.fromJson({
      'id': 'obs-1',
      'grid_location': 42,
      'type': 'blockage',
      'note': 'Wet floor',
      'reported_at': '2026-05-22T08:00:00.000Z',
    });

    expect(obstacle.gridLocation, 42);
    expect(obstacle.type, 'blockage');
    expect(obstacle.toJson()['grid_location'], 42);
  });
}

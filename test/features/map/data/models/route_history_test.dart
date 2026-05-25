import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/features/map/data/models/route_history.dart';

void main() {
  test('RouteHistory parses typed route entries', () {
    final history = RouteHistory.fromJson({
      'limit': 20,
      'page': 1,
      'total': 1,
      'routes': [
        {
          'route_id': 'route-001',
          'destination_name': 'Radiology',
          'dest_location': 42,
          'mode_id': 'walking',
          'map_id': 2,
          'created_at': '2026-05-22T08:30:00Z',
        },
      ],
    });

    final entry = history.routes.single;
    expect(entry.routeId, 'route-001');
    expect(entry.displayName, 'Radiology');
    expect(entry.resolvedLocation, 42);
    expect(entry.modeId, 'walking');
    expect(entry.mapId, 2);
    expect(entry.createdAt, DateTime.utc(2026, 5, 22, 8, 30));
  });
}

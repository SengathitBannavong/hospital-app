import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/features/map/data/services/route_modes.dart';
import 'package:hospital_app/features/map/data/services/routing_engine.dart';

void main() {
  test('route modes expose distinct speed and cost multipliers', () {
    expect(baseSpeedFor('walking'), 6);
    expect(baseSpeedFor('wheelchair'), 4);
    expect(baseSpeedFor('stretcher'), 3);
    expect(baseSpeedFor('hospital_cart'), 3);

    expect(modeCostMultiplier('walking'), 1);
    expect(modeCostMultiplier('wheelchair'), greaterThan(1));
    expect(modeCostMultiplier('stretcher'), greaterThan(1));
    expect(modeCostMultiplier('hospital_cart'), greaterThan(1));
  });

  test('RoutingEngine mode speed changes estimated time on same graph', () {
    final engine = RoutingEngine();
    const adjacency = {
      0: [1],
      1: [0, 2],
      2: [1],
    };

    final walking = engine.route(
      startLocation: 0,
      destLocation: 2,
      modeId: 'walking',
      adjacency: adjacency,
      cols: 3,
    );
    final wheelchair = engine.route(
      startLocation: 0,
      destLocation: 2,
      modeId: 'wheelchair',
      adjacency: adjacency,
      cols: 3,
    );
    final stretcher = engine.route(
      startLocation: 0,
      destLocation: 2,
      modeId: 'stretcher',
      adjacency: adjacency,
      cols: 3,
    );

    expect(walking.distance, wheelchair.distance);
    expect(wheelchair.estimatedTime, greaterThan(walking.estimatedTime));
    expect(stretcher.estimatedTime, greaterThan(wheelchair.estimatedTime));
  });
}

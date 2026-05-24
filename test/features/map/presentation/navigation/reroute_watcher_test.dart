import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/features/map/data/models/edge_status.dart';
import 'package:hospital_app/features/map/data/models/route_result.dart';
import 'package:hospital_app/features/map/data/models/route_step.dart';
import 'package:hospital_app/features/map/data/services/routing_engine.dart';
import 'package:hospital_app/features/map/presentation/navigation/position_source.dart';
import 'package:hospital_app/features/map/presentation/navigation/reroute_watcher.dart';

void main() {
  group('RerouteWatcher', () {
    test('blocked upcoming edge triggers reroute', () {
      final decision = const RerouteWatcher().evaluate(
        routeResult: _route(),
        position: const SimulatedPositionSource(
          currentLocation: 1,
          progress: 0.25,
        ),
        edgeStatuses: {
          edgeStatusKey(2, 3): const EdgeStatus(
            fromLocation: 2,
            toLocation: 3,
            blocked: true,
          ),
        },
      );

      expect(decision.shouldReroute, isTrue);
      expect(decision.edgeKey, edgeStatusKey(2, 3));
    });

    test('blocked edge already passed does not trigger', () {
      final decision = const RerouteWatcher().evaluate(
        routeResult: _route(),
        position: const SimulatedPositionSource(
          currentLocation: 3,
          progress: 0.75,
        ),
        edgeStatuses: {
          edgeStatusKey(1, 2): const EdgeStatus(
            fromLocation: 1,
            toLocation: 2,
            blocked: true,
          ),
        },
      );

      expect(decision.shouldReroute, isFalse);
    });

    test('congestion below threshold does not trigger', () {
      final decision = const RerouteWatcher().evaluate(
        routeResult: _route(),
        position: const SimulatedPositionSource(
          currentLocation: 1,
          progress: 0.25,
        ),
        edgeStatuses: {
          edgeStatusKey(2, 3): const EdgeStatus(
            fromLocation: 2,
            toLocation: 3,
            congestion: kRerouteCongestionThreshold - 0.01,
          ),
        },
      );

      expect(decision.shouldReroute, isFalse);
    });

    test('congestion at threshold ahead triggers reroute', () {
      final decision = const RerouteWatcher().evaluate(
        routeResult: _route(),
        position: const SimulatedPositionSource(
          currentLocation: 1,
          progress: 0.25,
        ),
        edgeStatuses: {
          edgeStatusKey(2, 3): const EdgeStatus(
            fromLocation: 2,
            toLocation: 3,
            congestion: kRerouteCongestionThreshold,
          ),
        },
      );

      expect(decision.shouldReroute, isTrue);
      expect(decision.edgeKey, edgeStatusKey(2, 3));
    });
  });
}

RouteResult _route() {
  return const RouteResult(
    path: [0, 1, 2, 3, 4],
    steps: [
      RouteStep(location: 0, maneuver: StepManeuver.start, distance: 0),
      RouteStep(location: 1, maneuver: StepManeuver.straight, distance: 1),
      RouteStep(location: 2, maneuver: StepManeuver.straight, distance: 1),
      RouteStep(location: 3, maneuver: StepManeuver.straight, distance: 1),
      RouteStep(location: 4, maneuver: StepManeuver.arrive, distance: 0),
    ],
    distance: 4,
    estimatedTime: 0.7,
    modeId: 'walking',
    speedFactor: 6,
  );
}

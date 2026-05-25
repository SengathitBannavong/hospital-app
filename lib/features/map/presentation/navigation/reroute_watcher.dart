import 'package:hospital_app/features/map/data/models/edge_status.dart';
import 'package:hospital_app/features/map/data/models/route_result.dart';
import 'package:hospital_app/features/map/data/services/routing_engine.dart';
import 'package:hospital_app/features/map/presentation/navigation/position_source.dart';

const double kRerouteCongestionThreshold = 0.7;

class RerouteDecision {
  final bool shouldReroute;
  final int? fromLocation;
  final int? toLocation;
  final EdgeStatus? edgeStatus;
  final String? edgeKey;

  const RerouteDecision._({
    required this.shouldReroute,
    this.fromLocation,
    this.toLocation,
    this.edgeStatus,
    this.edgeKey,
  });

  const RerouteDecision.none() : this._(shouldReroute: false);

  factory RerouteDecision.reroute({
    required int fromLocation,
    required int toLocation,
    required EdgeStatus edgeStatus,
  }) {
    return RerouteDecision._(
      shouldReroute: true,
      fromLocation: fromLocation,
      toLocation: toLocation,
      edgeStatus: edgeStatus,
      edgeKey: edgeStatusKey(fromLocation, toLocation),
    );
  }
}

class RerouteWatcher {
  const RerouteWatcher();

  RerouteDecision evaluate({
    required RouteResult? routeResult,
    required PositionSource position,
    required Map<String, EdgeStatus> edgeStatuses,
    Set<String> ignoredEdgeKeys = const <String>{},
  }) {
    final route = routeResult;
    if (route == null || route.path.length < 2 || edgeStatuses.isEmpty) {
      return const RerouteDecision.none();
    }

    final startIndex = _remainingStartIndex(route.path, position);
    for (var i = startIndex; i < route.path.length - 1; i++) {
      final from = route.path[i];
      final to = route.path[i + 1];
      final key = edgeStatusKey(from, to);
      if (ignoredEdgeKeys.contains(key)) {
        continue;
      }
      final status = edgeStatuses[key];
      if (status == null) {
        continue;
      }
      if (status.blocked || status.congestion >= kRerouteCongestionThreshold) {
        return RerouteDecision.reroute(
          fromLocation: from,
          toLocation: to,
          edgeStatus: status,
        );
      }
    }

    return const RerouteDecision.none();
  }

  int _remainingStartIndex(List<int> path, PositionSource position) {
    final progressIndex =
        (position.progress.clamp(0.0, 1.0) * (path.length - 1))
            .floor()
            .clamp(0, path.length - 2)
            .toInt();
    final currentLocation = position.currentLocation;
    if (currentLocation == null) {
      return progressIndex;
    }
    final locationIndex = path.indexOf(currentLocation);
    if (locationIndex < 0) {
      return progressIndex;
    }
    return locationIndex.clamp(progressIndex, path.length - 2).toInt();
  }
}

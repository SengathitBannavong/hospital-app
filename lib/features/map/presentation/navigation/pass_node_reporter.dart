import 'package:hospital_app/features/map/data/models/route_result.dart';
import 'package:hospital_app/features/map/presentation/navigation/position_source.dart';

class PassNodeReporter {
  final Set<int> _reportedLocations = <int>{};
  final List<int> _offlineQueue = <int>[];
  int? _routeSignature;

  List<int> get queuedLocations => List<int>.unmodifiable(_offlineQueue);

  void syncRoute(RouteResult? route) {
    final signature = route == null ? null : Object.hashAll(route.path);
    if (signature == _routeSignature) {
      return;
    }
    _routeSignature = signature;
    _reportedLocations.clear();
    _offlineQueue.clear();
  }

  Future<void> reportFrom(PositionSource position, RouteResult? route) async {
    final location = position.currentLocation;
    if (location == null || route == null || !route.path.contains(location)) {
      return;
    }
    if (!_reportedLocations.add(location)) {
      return;
    }

    // The current RouteResult has no route_id field. Until a server route id is
    // available, keep the simulated pass_node report queued and no-op safe.
    _offlineQueue.add(location);
  }
}

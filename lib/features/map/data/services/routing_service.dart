import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hospital_app/features/map/data/map_repository.dart';
import 'package:hospital_app/features/map/data/models/edge_status.dart';
import 'package:hospital_app/features/map/data/models/route_result.dart';
import 'package:hospital_app/features/map/data/services/map_cache_service.dart';
import 'package:hospital_app/features/map/data/services/route_result_mapper.dart';
import 'package:hospital_app/features/map/data/services/routing_engine.dart';

class RoutingService {
  final MapRepository _repository;
  final RoutingEngine _engine;
  final Connectivity _connectivity;
  final RouteResultMapper _mapper;
  final MapCacheService _cache;

  RoutingService({
    required MapRepository repository,
    required RoutingEngine engine,
    required MapCacheService cache,
    Connectivity? connectivity,
    RouteResultMapper mapper = const RouteResultMapper(),
  }) : _repository = repository,
       _engine = engine,
       _cache = cache,
       _connectivity = connectivity ?? Connectivity(),
       _mapper = mapper;

  Future<RouteResult> route({
    required int mapId,
    required int startLocation,
    required int destLocation,
    required String modeId,
    required Map<int, List<int>> adjacency,
    required int cols,
    Map<String, EdgeStatus> edgeStatuses =
        const <String, EdgeStatus>{},
    Set<int> poiCells = const <int>{},
  }) async {
    if (await _hasNetwork()) {
      try {
        final preview = await _repository.previewRoute(
          startLocation: startLocation,
          destLocation: destLocation,
          modeId: modeId,
        );
        final result = _mapper.fromPreviewJson(preview);
        if (result.path.isNotEmpty) {
          await _cache.saveRoute(
            mapId: mapId,
            startLocation: startLocation,
            destLocation: destLocation,
            modeId: modeId,
            result: result,
          );
          debugPrint(
            '[route] ONLINE+SAVED $startLocation->$destLocation ($modeId)',
          );
          return result;
        }
      } catch (_) {
        // The local engine is the required fallback whenever online preview
        // cannot be reached or parsed by the repository layer.
      }
    }

    final cached = await _cache.loadRoute(
      mapId: mapId,
      startLocation: startLocation,
      destLocation: destLocation,
      modeId: modeId,
    );
    if (cached != null && cached.path.isNotEmpty) {
      debugPrint('[route] CACHE HIT $startLocation->$destLocation ($modeId)');
      return cached;
    }

    debugPrint(
      '[route] ENGINE FALLBACK $startLocation->$destLocation ($modeId)',
    );
    return _engine.route(
      startLocation: startLocation,
      destLocation: destLocation,
      modeId: modeId,
      adjacency: adjacency,
      cols: cols,
      edgeStatuses: edgeStatuses,
      poiCells: poiCells,
    );
  }

  Future<RouteResult> reroute({
    required int mapId,
    required int currentLocation,
    required int destLocation,
    required String modeId,
    required Map<int, List<int>> adjacency,
    required int cols,
    required Map<String, EdgeStatus> edgeStatuses,
    String? routeId,
    Set<int> poiCells = const <int>{},
  }) async {
    // TODO(Phase J backend:route-id): wire online route/recalculate once the
    // active route flow provides a stable route_id from route/order.
    if (routeId != null && await _hasNetwork()) {
      try {
        final preview = await _repository.recalculateRoute(
          routeId: routeId,
          currentLocation: currentLocation,
        );
        final result = _mapper.fromPreviewJson(preview);
        if (result.path.isNotEmpty) {
          await _cache.saveRoute(
            mapId: mapId,
            startLocation: currentLocation,
            destLocation: destLocation,
            modeId: modeId,
            result: result,
          );
          debugPrint(
            '[reroute] ONLINE+SAVED $currentLocation->$destLocation ($modeId)',
          );
          return result;
        }
      } catch (_) {
        // Fall through to local reroute; offline/local correctness is required.
      }
    }

    final cached = await _cache.loadRoute(
      mapId: mapId,
      startLocation: currentLocation,
      destLocation: destLocation,
      modeId: modeId,
    );
    if (cached != null && cached.path.isNotEmpty) {
      debugPrint(
        '[reroute] CACHE HIT $currentLocation->$destLocation ($modeId)',
      );
      return cached;
    }

    debugPrint(
      '[reroute] ENGINE FALLBACK $currentLocation->$destLocation ($modeId)',
    );
    return _engine.route(
      startLocation: currentLocation,
      destLocation: destLocation,
      modeId: modeId,
      adjacency: adjacency,
      cols: cols,
      edgeStatuses: edgeStatuses,
      poiCells: poiCells,
    );
  }

  Future<bool> _hasNetwork() async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }
}

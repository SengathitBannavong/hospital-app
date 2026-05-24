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
    Map<String, EdgeStatus> edgeStatuses = const <String, EdgeStatus>{},
    Set<int> poiCells = const <int>{},
    Map<int, double> bottleneckWeights = const <int, double>{},
  }) async {
    // ── 1. Engine (crowd-aware) — primary authority ──
    if (adjacency.isNotEmpty) {
      try {
        final result = _engine.route(
          startLocation: startLocation,
          destLocation: destLocation,
          modeId: modeId,
          adjacency: adjacency,
          cols: cols,
          edgeStatuses: edgeStatuses,
          poiCells: poiCells,
          bottleneckWeights: bottleneckWeights,
        );
        if (result.path.isNotEmpty) {
          await _cache.saveRoute(
            mapId: mapId,
            startLocation: startLocation,
            destLocation: destLocation,
            modeId: modeId,
            result: result,
          );
          debugPrint(
            '[route] ENGINE(crowd-aware) '
            '$startLocation->$destLocation '
            '($modeId)',
          );
          return result;
        }
      } catch (_) {
        // Engine could not produce a route;
        // fall through to cache / preview.
      }
    }

    // ── 2. Cache ──
    final cached = await _cache.loadRoute(
      mapId: mapId,
      startLocation: startLocation,
      destLocation: destLocation,
      modeId: modeId,
    );
    if (cached != null && cached.path.isNotEmpty) {
      debugPrint(
        '[route] CACHE HIT '
        '$startLocation->$destLocation '
        '($modeId)',
      );
      return cached;
    }

    // ── 3. Preview fallback (online, crowd-blind) ──
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
            '[route] PREVIEW FALLBACK '
            '(crowd-blind) '
            '$startLocation->$destLocation '
            '($modeId)',
          );
          return result;
        }
      } catch (_) {
        // Preview unavailable — no more
        // fallbacks.
      }
    }

    throw Exception(
      'No route found for '
      '$startLocation->$destLocation.',
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
    Map<int, double> bottleneckWeights = const <int, double>{},
  }) async {
    // ── 1. Engine (crowd-aware) — primary ──
    if (adjacency.isNotEmpty) {
      try {
        final result = _engine.route(
          startLocation: currentLocation,
          destLocation: destLocation,
          modeId: modeId,
          adjacency: adjacency,
          cols: cols,
          edgeStatuses: edgeStatuses,
          poiCells: poiCells,
          bottleneckWeights: bottleneckWeights,
        );
        if (result.path.isNotEmpty) {
          await _cache.saveRoute(
            mapId: mapId,
            startLocation: currentLocation,
            destLocation: destLocation,
            modeId: modeId,
            result: result,
          );
          debugPrint(
            '[reroute] ENGINE(crowd-aware) '
            '$currentLocation->'
            '$destLocation ($modeId)',
          );
          return result;
        }
      } catch (_) {
        // Fall through to cache / preview.
      }
    }

    // ── 2. Cache ──
    final cached = await _cache.loadRoute(
      mapId: mapId,
      startLocation: currentLocation,
      destLocation: destLocation,
      modeId: modeId,
    );
    if (cached != null && cached.path.isNotEmpty) {
      debugPrint(
        '[reroute] CACHE HIT '
        '$currentLocation->'
        '$destLocation ($modeId)',
      );
      return cached;
    }

    // ── 3. Preview fallback (crowd-blind) ──
    // TODO(Phase J backend:route-id): wire online
    // route/recalculate once the active route flow
    // provides a stable route_id from route/order.
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
            '[reroute] PREVIEW FALLBACK '
            '(crowd-blind) '
            '$currentLocation->'
            '$destLocation ($modeId)',
          );
          return result;
        }
      } catch (_) {
        // No more fallbacks.
      }
    }

    throw Exception(
      'No reroute found for '
      '$currentLocation->$destLocation.',
    );
  }

  Future<bool> _hasNetwork() async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }
}

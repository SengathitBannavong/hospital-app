import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/features/map/data/models/edge_status.dart';
import 'package:hospital_app/features/map/data/models/flow_snapshot.dart';
import 'package:hospital_app/features/map/data/map_repository.dart';
import 'package:hospital_app/features/map/data/models/location_source.dart';
import 'package:hospital_app/features/map/data/models/map_edge.dart';
import 'package:hospital_app/features/map/data/models/map_floor.dart';
import 'package:hospital_app/features/map/data/models/map_obstacle.dart';
import 'package:hospital_app/features/map/data/models/map_poi.dart';
import 'package:hospital_app/features/map/data/models/map_sync_full.dart';
import 'package:hospital_app/features/map/data/models/nav_state.dart';
import 'package:hospital_app/features/map/data/models/route_result.dart';
import 'package:hospital_app/features/map/data/models/route_history.dart';
import 'package:hospital_app/features/map/data/services/map_cache_service.dart';
import 'package:hospital_app/features/map/data/services/flow_service.dart';
import 'package:hospital_app/features/map/data/services/report_queue.dart';
import 'package:hospital_app/features/map/data/services/routing_engine.dart';
import 'package:hospital_app/features/map/data/services/routing_service.dart';
import 'package:hospital_app/features/map/presentation/controllers/navigation_controller.dart';
import 'package:hospital_app/features/map/presentation/navigation/pass_node_reporter.dart';
import 'package:hospital_app/features/map/presentation/navigation/position_source.dart';
import 'package:hospital_app/features/map/presentation/navigation/reroute_watcher.dart';
import 'package:hospital_app/features/map/presentation/navigation/step_tracker.dart';
import 'package:hospital_app/features/map/presentation/navigation/voice_service.dart';
import 'package:hospital_app/features/map/presentation/utils/search_utils.dart';

final mapRepositoryProvider = Provider<MapRepository>((ref) {
  return MapRepository();
});

final mapCacheProvider = Provider<MapCacheService>((ref) {
  return MapCacheService();
});

final mapLastSyncedAtProvider = FutureProvider.family<DateTime?, int>((
  ref,
  mapId,
) {
  final cache = ref.watch(mapCacheProvider);
  return cache.lastSyncedAt(mapId: mapId);
});

final selectedFloorProvider = StateProvider<int?>((ref) => null);

final floorsProvider = FutureProvider<List<MapFloor>>((ref) async {
  final repository = ref.watch(mapRepositoryProvider);
  final cache = ref.watch(mapCacheProvider);
  List<MapFloor> floors;
  try {
    floors = await repository.getFloors();
    if (floors.isNotEmpty) {
      await cache.saveFloors(floors);
    }
  } catch (_) {
    floors = await cache.loadFloors();
  }

  final selected = ref.read(selectedFloorProvider);
  if (floors.isNotEmpty &&
      (selected == null || !floors.any((floor) => floor.mapId == selected))) {
    ref.read(selectedFloorProvider.notifier).state = floors.first.mapId;
  }
  return floors;
});

final routingServiceProvider = Provider<RoutingService>((ref) {
  return RoutingService(
    repository: ref.watch(mapRepositoryProvider),
    engine: RoutingEngine(),
  );
});

final flowServiceProvider = Provider<FlowService>((ref) {
  return FlowService(
    repository: ref.watch(mapRepositoryProvider),
    cache: ref.watch(mapCacheProvider),
  );
});

final reportQueueProvider = Provider<ReportQueue>((ref) {
  return ReportQueue(repository: ref.watch(mapRepositoryProvider));
});

final routeHistoryProvider = FutureProvider.autoDispose<RouteHistory>((ref) {
  return ref.watch(mapRepositoryProvider).getRouteHistory();
});

// Fetch map metadata by mapId. Rows and cols must come from the backend,
// otherwise POI coordinates can be outside the painted grid.
final mapMetaProvider = FutureProvider.family<MapFloor, int>((
  ref,
  mapId,
) async {
  final repository = ref.watch(mapRepositoryProvider);
  try {
    return await repository.getMeta(mapId: mapId);
  } catch (_) {
    final syncFull = await _cachedOrOnlineSyncFull(ref, mapId);
    final meta = syncFull.maps.where((map) => map.mapId == mapId).firstOrNull;
    if (meta != null) {
      return meta;
    }
    rethrow;
  }
});

// Fetch nodes by mapId
final mapNodesProvider = FutureProvider.family<List<MapPoi>, int>((
  ref,
  mapId,
) async {
  final repository = ref.watch(mapRepositoryProvider);
  try {
    final nodes = await repository.getNodes(mapId: mapId);
    await _tryRefreshSyncFull(ref, mapId);
    return nodes;
  } catch (_) {
    final syncFull = await _cachedOrOnlineSyncFull(ref, mapId);
    return syncFull.pois.where((poi) => poi.mapId == mapId).toList();
  }
});

// Fetch edges by mapId
final mapEdgesProvider = FutureProvider.family<List<MapEdge>, int>((
  ref,
  mapId,
) async {
  final repository = ref.watch(mapRepositoryProvider);
  try {
    final response = await repository.getEdges(mapId: mapId);
    await _tryRefreshSyncFull(ref, mapId);
    return response.edges;
  } catch (_) {
    final syncFull = await _cachedOrOnlineSyncFull(ref, mapId);
    return syncFull.edges;
  }
});

// Search keyword
final searchKeywordProvider = StateProvider<String>((ref) => '');

final userPositionProvider = StateProvider<int?>((ref) => null);
final locationSourceProvider = StateProvider<LocationSource>(
  (ref) => LocationSource.entranceDefault,
);
final navPhaseProvider = StateProvider<NavPhase>((ref) => NavPhase.idle);
final flowOverlayVisibleProvider = StateProvider<bool>((ref) => false);
final rerouteResultProvider = StateProvider<RouteResult?>((ref) => null);
final voiceMutedProvider = StateProvider<bool>((ref) => false);
final navProgressProvider = StateProvider<double>((ref) => 0.0);
final navSpeedProvider = StateProvider<double>((ref) => 1.0);
final navCurrentLocationProvider = StateProvider<int?>((ref) => null);
final navMetersRemainingProvider = StateProvider<double>((ref) => 0.0);
final navSecondsRemainingProvider = StateProvider<double>((ref) => 0.0);
final positionSourceProvider = Provider<PositionSource>((ref) {
  final navLocation = ref.watch(navCurrentLocationProvider);
  final restingLocation = ref.watch(userPositionProvider);
  return SimulatedPositionSource(
    currentLocation: navLocation ?? restingLocation,
    progress: ref.watch(navProgressProvider).clamp(0.0, 1.0).toDouble(),
  );
});
final stepTrackerProvider = Provider<StepTracker>((ref) {
  return const StepTracker();
});
final rerouteWatcherProvider = Provider<RerouteWatcher>((ref) {
  return const RerouteWatcher();
});
final voiceServiceProvider = Provider<VoiceService>((ref) {
  final service = VoiceService();
  ref.onDispose(() {
    service.reset();
  });
  return service;
});
final activeRouteResultProvider =
    Provider.autoDispose<AsyncValue<RouteResult?>>((ref) {
      final reroute = ref.watch(rerouteResultProvider);
      if (reroute != null) {
        return AsyncData(reroute);
      }
      return ref.watch(routeResultProvider);
    });
final stepTrackingProvider = Provider.autoDispose<StepTrackingState>((ref) {
  final tracker = ref.watch(stepTrackerProvider);
  final position = ref.watch(positionSourceProvider);
  final route = ref.watch(activeRouteResultProvider).valueOrNull;
  return tracker.track(position: position, routeResult: route);
});
final passNodeReporterProvider = Provider<PassNodeReporter>((ref) {
  return PassNodeReporter();
});
final navigationControllerProvider = Provider.autoDispose<NavigationController>(
  (ref) {
    final controller = NavigationController(ref);
    ref.onDispose(controller.dispose);
    return controller;
  },
);

final flowSnapshotProvider = StreamProvider.autoDispose
    .family<FlowSnapshot, int>((ref, mapId) async* {
      final service = ref.watch(flowServiceProvider);
      final phase = ref.watch(navPhaseProvider);
      final interval = phase == NavPhase.navigating
          ? const Duration(seconds: 15)
          : const Duration(seconds: 30);

      yield await service.snapshot(mapId: mapId);
      final timer = Timer.periodic(interval, (_) {
        ref.invalidateSelf();
      });
      ref.onDispose(timer.cancel);
    });

final obstaclesProvider = StreamProvider.autoDispose
    .family<List<MapObstacle>, int>((ref, mapId) async* {
      final repository = ref.watch(mapRepositoryProvider);
      final cache = ref.watch(mapCacheProvider);
      final queue = ref.watch(reportQueueProvider);
      final phase = ref.watch(navPhaseProvider);
      final interval = phase == NavPhase.navigating
          ? const Duration(seconds: 15)
          : const Duration(seconds: 30);

      yield await _loadObstacles(
        repository: repository,
        cache: cache,
        queue: queue,
        mapId: mapId,
      );
      final timer = Timer.periodic(interval, (_) {
        ref.invalidateSelf();
      });
      final subscription = queue.onConnectivityChanged().listen((results) {
        if (results.contains(ConnectivityResult.none)) {
          return;
        }
        unawaited(queue.flush().then((_) => ref.invalidateSelf()));
      });
      ref
        ..onDispose(timer.cancel)
        ..onDispose(subscription.cancel);
    });

final flowEdgeStatusMapProvider = Provider.autoDispose
    .family<Map<String, EdgeStatus>, int>((ref, mapId) {
      final snapshot = ref.watch(flowSnapshotProvider(mapId)).valueOrNull;
      final obstacles =
          ref.watch(obstaclesProvider(mapId)).valueOrNull ??
          const <MapObstacle>[];
      final adjacency = ref.watch(adjacencyProvider(mapId));
      if (snapshot == null && obstacles.isEmpty) {
        return const <String, EdgeStatus>{};
      }
      final edgeStatuses = <String, EdgeStatus>{
        for (final edge in snapshot?.edgeStatuses ?? const <EdgeStatus>[])
          edgeStatusKey(edge.fromLocation, edge.toLocation): edge,
      };
      return mergeObstacleEdgeStatuses(
        edgeStatuses: edgeStatuses,
        obstacles: obstacles,
        adjacency: adjacency,
      );
    });

Map<String, EdgeStatus> mergeObstacleEdgeStatuses({
  required Map<String, EdgeStatus> edgeStatuses,
  required List<MapObstacle> obstacles,
  required Map<int, List<int>> adjacency,
}) {
  final result = Map<String, EdgeStatus>.of(edgeStatuses);
  for (final obstacle in obstacles) {
    for (final next in adjacency[obstacle.gridLocation] ?? const <int>[]) {
      final key = edgeStatusKey(obstacle.gridLocation, next);
      final existing = result[key];
      result[key] = existing == null
          ? EdgeStatus(
              fromLocation: obstacle.gridLocation,
              toLocation: next,
              blocked: true,
            )
          : existing.copyWith(blocked: true);
    }
  }
  return result;
}

// Normalized POI names cache keyed by poiId — computed once when nodes settle.
final normalizedPoiNamesProvider = Provider.family<Map<int, String>, int>((
  ref,
  mapId,
) {
  final nodes = ref.watch(mapNodesProvider(mapId)).value ?? const <MapPoi>[];
  return {for (final poi in nodes) poi.poiId: normalizeForSearch(poi.poiName)};
});

// O(1) lookup by poiId.
final poiByIdProvider = Provider.family<Map<int, MapPoi>, int>((ref, mapId) {
  final nodes = ref.watch(mapNodesProvider(mapId)).value ?? const <MapPoi>[];
  return {for (final poi in nodes) poi.poiId: poi};
});

// O(1) lookup keyed by row*cols+col. Skips out-of-bounds POIs.
final poiByCellProvider = Provider.family<Map<int, MapPoi>, int>((ref, mapId) {
  final nodes = ref.watch(mapNodesProvider(mapId)).value ?? const <MapPoi>[];
  final meta = ref.watch(mapMetaProvider(mapId)).value;
  if (meta == null) {
    return const <int, MapPoi>{};
  }
  final cols = meta.cols;
  final rows = meta.rows;
  final result = <int, MapPoi>{};
  for (final poi in nodes) {
    if (poi.gridRow < 0 ||
        poi.gridRow >= rows ||
        poi.gridCol < 0 ||
        poi.gridCol >= cols) {
      continue;
    }
    result[poi.gridRow * cols + poi.gridCol] = poi;
  }
  return result;
});

// Walkable cell set derived from edges. Stable identity until edges change.
final walkableCellsProvider = Provider.family<Set<int>, int>((ref, mapId) {
  final edges = ref.watch(mapEdgesProvider(mapId)).value ?? const <MapEdge>[];
  final result = <int>{};
  for (final edge in edges) {
    result
      ..add(edge.fromLocation)
      ..add(edge.toLocation);
  }
  return result;
});

final defaultUserPositionProvider = Provider.family<int?, int>((ref, mapId) {
  final nodes = ref.watch(mapNodesProvider(mapId)).value ?? const <MapPoi>[];
  final walkable = ref.watch(walkableCellsProvider(mapId));

  if (nodes.isNotEmpty) {
    for (final poi in nodes) {
      if (poi.poiCode.toUpperCase().startsWith('ENT')) {
        return poi.gridLocation;
      }
    }

    for (final poi in nodes) {
      if (poi.poiName.toLowerCase().contains('entrance')) {
        return poi.gridLocation;
      }
    }

    for (final poi in nodes) {
      if (poi.isLandmark) {
        return poi.gridLocation;
      }
    }
  }

  return walkable.isEmpty ? null : walkable.first;
});

// Adjacency for potential client-side routing / consumers. Cheap to keep here.
final adjacencyProvider = Provider.family<Map<int, List<int>>, int>((
  ref,
  mapId,
) {
  final edges = ref.watch(mapEdgesProvider(mapId)).value ?? const <MapEdge>[];
  final result = <int, List<int>>{};
  for (final edge in edges) {
    result.putIfAbsent(edge.fromLocation, () => <int>[]).add(edge.toLocation);
    result.putIfAbsent(edge.toLocation, () => <int>[]).add(edge.fromLocation);
  }
  return result;
});

// Search results by keyword + mapId
final searchResultsProvider = FutureProvider.family<List<MapPoi>, int>((
  ref,
  mapId,
) async {
  final keyword = ref.watch(searchKeywordProvider).trim();

  if (keyword.isEmpty) {
    return [];
  }

  final nodes = await ref.watch(mapNodesProvider(mapId).future);
  final normalized = ref.watch(normalizedPoiNamesProvider(mapId));
  return _filterPois(nodes, normalized, keyword);
});

List<MapPoi> _filterPois(
  List<MapPoi> pois,
  Map<int, String> normalized,
  String keyword,
) {
  final normalizedKeyword = normalizeForSearch(keyword);
  if (normalizedKeyword.isEmpty) {
    return [];
  }

  String nameOf(MapPoi poi) =>
      normalized[poi.poiId] ?? normalizeForSearch(poi.poiName);

  return pois.where((poi) {
    return nameOf(poi).contains(normalizedKeyword);
  }).toList()..sort((a, b) {
    final aName = nameOf(a);
    final bName = nameOf(b);
    final aStarts = aName.startsWith(normalizedKeyword);
    final bStarts = bName.startsWith(normalizedKeyword);
    if (aStarts != bStarts) {
      return aStarts ? -1 : 1;
    }
    return aName.compareTo(bName);
  });
}

// Route state
final routeDestProvider = StateProvider<MapPoi?>((ref) => null);
final routeModeProvider = StateProvider<String>((ref) => 'walking');

// Route result based on start + dest + mode
final routeResultProvider = FutureProvider.autoDispose<RouteResult?>((
  ref,
) async {
  final routingService = ref.watch(routingServiceProvider);
  final start = ref.watch(userPositionProvider);
  final dest = ref.watch(routeDestProvider);
  final mode = ref.watch(routeModeProvider);
  final selectedMapId = ref.watch(selectedFloorProvider);
  final floors = await ref.watch(floorsProvider.future);
  final mapId = selectedMapId ?? floors.firstOrNull?.mapId;

  if (start == null || dest == null || mapId == null) {
    return null;
  }

  final meta = await ref.watch(mapMetaProvider(mapId).future);
  await ref.watch(mapEdgesProvider(mapId).future);
  final adjacency = ref.watch(adjacencyProvider(mapId));
  final edgeStatuses = ref.watch(flowEdgeStatusMapProvider(mapId));

  // TODO(Phase J backend:cross-floor-links): offline cross-floor routing
  // requires a documented stair/elevator link model between map_ids. swagger.yaml
  // only exposes per-floor map nodes/edges today, so the local engine stays
  // floor-scoped.

  return routingService.route(
    startLocation: start,
    destLocation: dest.gridLocation,
    modeId: mode,
    adjacency: adjacency,
    cols: meta.cols,
    edgeStatuses: edgeStatuses,
  );
});

// Extracted route locations memoized off the typed RouteResult.
final routeLocationsProvider = Provider.autoDispose<List<int>>((ref) {
  final result = ref.watch(activeRouteResultProvider);
  return result.maybeWhen(
    data: (route) => route?.path ?? const <int>[],
    orElse: () => const <int>[],
  );
});

final navDotProvider = Provider.autoDispose<NavDot?>((ref) {
  final path = ref.watch(routeLocationsProvider);
  final progress = ref.watch(navProgressProvider).clamp(0.0, 1.0).toDouble();
  final resting = ref.watch(userPositionProvider);

  if (path.length < 2) {
    return resting == null ? null : NavDot.resting(resting);
  }

  final totalLength = path.length - 1;
  final reached = totalLength * progress;
  final segmentIndex = reached.floor().clamp(0, totalLength - 1).toInt();
  final t = (reached - segmentIndex).clamp(0.0, 1.0).toDouble();

  return NavDot(
    fromLocation: path[segmentIndex],
    toLocation: path[segmentIndex + 1],
    t: t,
  );
});

Future<MapSyncFull> _cachedOrOnlineSyncFull(Ref ref, int mapId) async {
  final cache = ref.read(mapCacheProvider);
  final cached = await cache.loadSyncFull(mapId: mapId);
  if (cached != null) {
    return cached;
  }
  return _refreshSyncFull(ref, mapId);
}

Future<MapSyncFull> _refreshSyncFull(Ref ref, int mapId) async {
  final repository = ref.read(mapRepositoryProvider);
  final cache = ref.read(mapCacheProvider);
  final syncFull = await repository.syncFull(mapId: mapId);
  await cache.saveSyncFull(mapId: mapId, syncFull: syncFull);
  ref.invalidate(mapLastSyncedAtProvider(mapId));
  return syncFull;
}

Future<void> _tryRefreshSyncFull(Ref ref, int mapId) async {
  try {
    await _refreshSyncFull(ref, mapId);
  } catch (_) {
    // Individual map endpoints remain authoritative when the bulk sync endpoint
    // is unavailable; the cache refresh will retry on the next successful load.
  }
}

Future<List<MapObstacle>> _loadObstacles({
  required MapRepository repository,
  required MapCacheService cache,
  required ReportQueue queue,
  required int mapId,
}) async {
  final queued = await queue.queuedObstacles();
  try {
    await queue.flush();
    final remote = await repository.getObstacles();
    final refreshedQueued = await queue.queuedObstacles();
    final merged = _mergeObstacles(remote, refreshedQueued);
    await cache.saveObstacles(mapId: mapId, obstacles: merged);
    return merged;
  } catch (_) {
    final cached = await cache.loadObstacles(mapId: mapId);
    return _mergeObstacles(cached, queued);
  }
}

List<MapObstacle> _mergeObstacles(
  List<MapObstacle> primary,
  List<MapObstacle> secondary,
) {
  final byId = <String, MapObstacle>{
    for (final obstacle in primary) obstacle.id: obstacle,
  };
  for (final obstacle in secondary) {
    byId[obstacle.id] = obstacle;
  }
  return byId.values.toList(growable: false);
}

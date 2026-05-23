import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/features/map/data/models/edge_status.dart';
import 'package:hospital_app/features/map/data/models/flow_snapshot.dart';
import 'package:hospital_app/features/map/data/models/flow_cell.dart';
import 'package:hospital_app/features/map/data/map_repository.dart';
import 'package:hospital_app/features/map/data/models/location_source.dart';
import 'package:hospital_app/features/map/data/models/map_edge.dart';
import 'package:hospital_app/features/map/data/models/map_floor.dart';
import 'package:hospital_app/features/map/data/models/map_obstacle.dart';
import 'package:hospital_app/features/map/data/models/map_poi.dart';
import 'package:hospital_app/features/map/data/models/nav_state.dart';
import 'package:hospital_app/features/map/data/models/route_history.dart';
import 'package:hospital_app/features/map/data/models/route_result.dart';
import 'package:hospital_app/features/map/data/models/map_sync_full.dart';
import 'package:hospital_app/features/map/data/services/flow_service.dart';
import 'package:hospital_app/features/map/data/services/map_cache_service.dart';
import 'package:hospital_app/features/map/data/services/report_queue.dart';
import 'package:hospital_app/features/map/data/services/routing_engine.dart';
import 'package:hospital_app/features/map/data/services/routing_service.dart';
import 'package:hospital_app/features/map/presentation/controllers/navigation_controller.dart';
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
    cache: ref.watch(mapCacheProvider),
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

final mapConnectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  bool isOnline(List<ConnectivityResult> results) {
    return !results.contains(ConnectivityResult.none);
  }

  yield isOnline(await connectivity.checkConnectivity());
  await for (final results in connectivity.onConnectivityChanged) {
    yield isOnline(results);
  }
});

final mapInlineNoticeProvider = StateProvider<String?>((ref) => null);

final flowOverlayVisibleProvider = StateProvider<bool>((ref) => false);

final edgeStatusVisibleProvider = StateProvider<bool>((ref) => false);

final bottlenecksVisibleProvider = StateProvider<bool>((ref) => false);

final forecastVisibleProvider = StateProvider<bool>((ref) => false);

final forecastHoursProvider = StateProvider<int>((ref) => 2);

final bottlenecksProvider = FutureProvider.autoDispose
    .family<List<FlowCell>, int>((ref, mapId) async {
      final repository = ref.watch(mapRepositoryProvider);
      final isOnline = ref.watch(mapConnectivityProvider).valueOrNull ?? false;
      if (!isOnline) {
        return const <FlowCell>[];
      }
      try {
        return await repository.getFlowBottlenecks();
      } catch (_) {
        return const <FlowCell>[];
      }
    });

final forecastProvider = FutureProvider.family<List<FlowCell>, int>((
  ref,
  mapId,
) async {
  final repository = ref.watch(mapRepositoryProvider);
  final hours = ref.watch(forecastHoursProvider);
  final isOnline = ref.watch(mapConnectivityProvider).valueOrNull ?? false;
  if (!isOnline) {
    return const <FlowCell>[];
  }
  try {
    return await repository.getFlowForecast(hours: hours);
  } catch (_) {
    return const <FlowCell>[];
  }
});

final flowSnapshotProvider = FutureProvider.family<FlowSnapshot, int>((
  ref,
  mapId,
) {
  return ref.watch(flowServiceProvider).snapshot(mapId: mapId);
});

final mapObstaclesProvider = FutureProvider.family<List<MapObstacle>, int>((
  ref,
  mapId,
) {
  return _loadObstacles(
    repository: ref.watch(mapRepositoryProvider),
    cache: ref.watch(mapCacheProvider),
    queue: ref.watch(reportQueueProvider),
    mapId: mapId,
  );
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
  final cache = ref.read(mapCacheProvider);
  try {
    final meta = await repository.getMeta(mapId: mapId);
    await cache.saveMeta(mapId: mapId, meta: meta);
    return meta;
  } catch (_) {
    final cached = await cache.loadMeta(mapId: mapId);
    if (cached != null) {
      return cached;
    }
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
  final cache = ref.read(mapCacheProvider);
  try {
    final nodes = await repository.getNodes(mapId: mapId);
    await cache.saveNodes(mapId: mapId, nodes: nodes);
    await _tryRefreshSyncFull(ref, mapId);
    return nodes;
  } catch (_) {
    final cached = await cache.loadNodes(mapId: mapId);
    if (cached.isNotEmpty) {
      return cached;
    }
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
  final cache = ref.read(mapCacheProvider);
  try {
    final response = await repository.getEdges(mapId: mapId);
    await cache.saveEdges(mapId: mapId, edges: response.edges);
    await _tryRefreshSyncFull(ref, mapId);
    return response.edges;
  } catch (_) {
    final cached = await cache.loadEdges(mapId: mapId);
    if (cached.isNotEmpty) {
      return cached;
    }
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
final navProgressProvider = StateProvider<double>((ref) => 0.0);
final navSpeedProvider = StateProvider<double>((ref) => 1.0);
final navCurrentLocationProvider = StateProvider<int?>((ref) => null);
final navMetersRemainingProvider = StateProvider<double>((ref) => 0.0);
final navSecondsRemainingProvider = StateProvider<double>((ref) => 0.0);
final navigationControllerProvider = Provider.autoDispose<NavigationController>(
  (ref) {
    final controller = NavigationController(ref);
    ref.onDispose(controller.dispose);
    return controller;
  },
);

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

// Route result based on start + dest + mode.
final routeResultProvider = FutureProvider.autoDispose<RouteResult?>((
  ref,
) async {
  final service = ref.watch(routingServiceProvider);
  final start = ref.watch(userPositionProvider);
  final dest = ref.watch(routeDestProvider);
  final mode = ref.watch(routeModeProvider);

  // While a trip is in progress, replay the frozen active route so a mid-trip
  // recompute (e.g. a connection drop or a flow/obstacle refresh) can't swap the
  // drawn path out from under the moving dot. Cleared when navigation ends.
  final navPhase = ref.watch(navPhaseProvider);
  final navActive =
      navPhase == NavPhase.navigating ||
      navPhase == NavPhase.paused ||
      navPhase == NavPhase.arrived;
  if (navActive) {
    final activeRoute = await ref.read(mapCacheProvider).loadActiveRoute();
    if (activeRoute != null && activeRoute.path.isNotEmpty) {
      return activeRoute;
    }
  }

  final selectedMapId = ref.watch(selectedFloorProvider);
  final floors = await ref.watch(floorsProvider.future);
  final mapId = selectedMapId ?? floors.firstOrNull?.mapId;

  if (start == null || dest == null || mapId == null) {
    return null;
  }

  final meta = await ref.watch(mapMetaProvider(mapId).future);
  final adjacency = ref.watch(adjacencyProvider(mapId));
  final flowSnapshot = ref.watch(flowSnapshotProvider(mapId)).valueOrNull;
  final obstacles =
      ref.watch(mapObstaclesProvider(mapId)).valueOrNull ??
      const <MapObstacle>[];
  final edgeStatuses = mergeObstacleEdgeStatuses(
    edgeStatuses: {
      for (final edge in flowSnapshot?.edgeStatuses ?? const <EdgeStatus>[])
        edgeStatusKey(edge.fromLocation, edge.toLocation): edge,
    },
    obstacles: obstacles,
    adjacency: adjacency,
  );
  final poiCells = ref.watch(poiByCellProvider(mapId)).keys.toSet();

  return service.route(
    mapId: mapId,
    startLocation: start,
    destLocation: dest.gridLocation,
    modeId: mode,
    adjacency: adjacency,
    cols: meta.cols,
    edgeStatuses: edgeStatuses,
    poiCells: poiCells,
  );
});

final activeRouteResultProvider = routeResultProvider;

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

List<int> extractRouteLocations(dynamic data) {
  if (data == null) {
    return const [];
  }

  if (data is RouteResult) {
    return data.path;
  }

  if (data is List) {
    return _coerceLocationsList(data);
  }

  if (data is Map) {
    const keys = ['steps', 'path', 'path_locations', 'locations', 'nodes'];
    for (final key in keys) {
      final value = data[key];
      if (value is List) {
        if (key == 'steps') {
          return _coerceRouteSteps(value);
        }
        return _coerceLocationsList(value);
      }
    }
  }

  return const [];
}

List<int> _coerceRouteSteps(List<dynamic> raw) {
  final steps = raw.whereType<Map>().toList()
    ..sort((a, b) {
      final aOrder = a['step_order'];
      final bOrder = b['step_order'];
      if (aOrder is num && bOrder is num) {
        return aOrder.compareTo(bOrder);
      }
      return 0;
    });
  return _coerceLocationsList(steps);
}

List<int> _coerceLocationsList(List<dynamic> raw) {
  final locations = <int>[];
  for (final item in raw) {
    if (item is int) {
      locations.add(item);
    } else if (item is num) {
      locations.add(item.toInt());
    } else if (item is Map) {
      final location = item['location'] ?? item['grid_location'];
      if (location is int) {
        locations.add(location);
      } else if (location is num) {
        locations.add(location.toInt());
      }
    }
  }
  return locations;
}

Map<String, EdgeStatus> mergeObstacleEdgeStatuses({
  required Map<String, EdgeStatus> edgeStatuses,
  required List<MapObstacle> obstacles,
  required Map<int, List<int>> adjacency,
}) {
  final result = Map<String, EdgeStatus>.of(edgeStatuses);
  for (final obstacle in obstacles) {
    final neighbors = adjacency[obstacle.gridLocation] ?? const <int>[];
    for (final neighbor in neighbors) {
      final key = edgeStatusKey(obstacle.gridLocation, neighbor);
      final existing = result[key];
      result[key] = EdgeStatus(
        fromLocation: obstacle.gridLocation,
        toLocation: neighbor,
        congestion: existing?.congestion ?? 1,
        blocked: true,
      );

      final reverseKey = edgeStatusKey(neighbor, obstacle.gridLocation);
      final reverseExisting = result[reverseKey];
      result[reverseKey] = EdgeStatus(
        fromLocation: neighbor,
        toLocation: obstacle.gridLocation,
        congestion: reverseExisting?.congestion ?? existing?.congestion ?? 1,
        blocked: true,
      );
    }
  }
  return result;
}

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
  if (syncFull.edges.isEmpty && syncFull.pois.isEmpty) {
    return syncFull; // stubbed/empty — do not overwrite cache or stamp lastSyncedAt
  }
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

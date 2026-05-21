import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/features/map/data/map_repository.dart';
import 'package:hospital_app/features/map/data/models/location_source.dart';
import 'package:hospital_app/features/map/data/models/map_edge.dart';
import 'package:hospital_app/features/map/data/models/map_floor.dart';
import 'package:hospital_app/features/map/data/models/map_poi.dart';
import 'package:hospital_app/features/map/data/models/map_sync_full.dart';
import 'package:hospital_app/features/map/data/models/nav_state.dart';
import 'package:hospital_app/features/map/data/services/map_cache_service.dart';
import 'package:hospital_app/features/map/data/services/routing_engine.dart';
import 'package:hospital_app/features/map/data/services/routing_service.dart';
import 'package:hospital_app/features/map/presentation/controllers/navigation_controller.dart';
import 'package:hospital_app/features/map/presentation/utils/search_utils.dart';

const int _defaultRouteMapId = 1;

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

final routingServiceProvider = Provider<RoutingService>((ref) {
  return RoutingService(
    repository: ref.watch(mapRepositoryProvider),
    engine: RoutingEngine(),
  );
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

// Route result based on start + dest + mode
final routeResultProvider = FutureProvider.autoDispose<dynamic>((ref) async {
  final routingService = ref.watch(routingServiceProvider);
  final start = ref.watch(userPositionProvider);
  final dest = ref.watch(routeDestProvider);
  final mode = ref.watch(routeModeProvider);

  if (start == null || dest == null) {
    return null;
  }

  final meta = await ref.watch(mapMetaProvider(_defaultRouteMapId).future);
  await ref.watch(mapEdgesProvider(_defaultRouteMapId).future);
  final adjacency = ref.watch(adjacencyProvider(_defaultRouteMapId));

  return routingService.route(
    startLocation: start,
    destLocation: dest.gridLocation,
    modeId: mode,
    adjacency: adjacency,
    cols: meta.cols,
  );
});

// Extracted route locations memoized off routeResultProvider.
final routeLocationsProvider = Provider.autoDispose<List<int>>((ref) {
  final result = ref.watch(routeResultProvider);
  return result.maybeWhen(
    data: extractRouteLocations,
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

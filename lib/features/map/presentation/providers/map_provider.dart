import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/features/map/data/map_repository.dart';
import 'package:hospital_app/features/map/data/models/map_edge.dart';
import 'package:hospital_app/features/map/data/models/map_floor.dart';
import 'package:hospital_app/features/map/data/models/map_poi.dart';
import 'package:hospital_app/features/map/presentation/utils/search_utils.dart';

final mapRepositoryProvider = Provider<MapRepository>((ref) {
  return MapRepository();
});

// Fetch map metadata by mapId. Rows and cols must come from the backend,
// otherwise POI coordinates can be outside the painted grid.
final mapMetaProvider = FutureProvider.family<MapFloor, int>((ref, mapId) {
  final repository = ref.watch(mapRepositoryProvider);
  return repository.getMeta(mapId: mapId);
});

// Fetch nodes by mapId
final mapNodesProvider = FutureProvider.family<List<MapPoi>, int>((ref, mapId) {
  final repository = ref.watch(mapRepositoryProvider);
  return repository.getNodes(mapId: mapId);
});

// Fetch edges by mapId
final mapEdgesProvider = FutureProvider.family<List<MapEdge>, int>((
  ref,
  mapId,
) async {
  final repository = ref.watch(mapRepositoryProvider);
  final response = await repository.getEdges(mapId: mapId);
  return response.edges;
});

// Search keyword
final searchKeywordProvider = StateProvider<String>((ref) => '');

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
final routeStartProvider = StateProvider<MapPoi?>((ref) => null);
final routeDestProvider = StateProvider<MapPoi?>((ref) => null);
final routeModeProvider = StateProvider<String>((ref) => 'walking');

// Route result based on start + dest + mode
final routeResultProvider = FutureProvider.autoDispose<dynamic>((ref) async {
  final repository = ref.watch(mapRepositoryProvider);
  final start = ref.watch(routeStartProvider);
  final dest = ref.watch(routeDestProvider);
  final mode = ref.watch(routeModeProvider);

  if (start == null || dest == null) {
    return null;
  }

  return repository.previewRoute(
    startLocation: start.gridLocation,
    destLocation: dest.gridLocation,
    modeId: mode,
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

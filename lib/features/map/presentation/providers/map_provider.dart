import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/features/map/data/map_repository.dart';
import 'package:hospital_app/features/map/data/models/map_edge.dart';
import 'package:hospital_app/features/map/data/models/map_floor.dart';
import 'package:hospital_app/features/map/data/models/map_poi.dart';

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

// Search results by keyword + mapId
final searchResultsProvider = FutureProvider.family<List<MapPoi>, int>((
  ref,
  mapId,
) async {
  final repository = ref.watch(mapRepositoryProvider);
  final keyword = ref.watch(searchKeywordProvider).trim();

  if (keyword.isEmpty) {
    return [];
  }

  return repository.searchLocation(keyword: keyword, mapId: mapId);
});

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

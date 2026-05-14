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
  final keyword = ref.watch(searchKeywordProvider).trim();

  if (keyword.isEmpty) {
    return [];
  }

  final nodes = await ref.watch(mapNodesProvider(mapId).future);
  return _filterPois(nodes, keyword);
});

List<MapPoi> _filterPois(List<MapPoi> pois, String keyword) {
  final normalizedKeyword = _normalizeForSearch(keyword);
  if (normalizedKeyword.isEmpty) {
    return [];
  }

  return pois.where((poi) {
    final normalizedName = _normalizeForSearch(poi.poiName);
    return normalizedName.contains(normalizedKeyword);
  }).toList()..sort((a, b) {
    final aName = _normalizeForSearch(a.poiName);
    final bName = _normalizeForSearch(b.poiName);
    final aStarts = aName.startsWith(normalizedKeyword);
    final bStarts = bName.startsWith(normalizedKeyword);
    if (aStarts != bStarts) {
      return aStarts ? -1 : 1;
    }
    return aName.compareTo(bName);
  });
}

String _normalizeForSearch(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a')
      .replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e')
      .replaceAll(RegExp(r'[ìíịỉĩ]'), 'i')
      .replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o')
      .replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u')
      .replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y')
      .replaceAll('đ', 'd')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
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

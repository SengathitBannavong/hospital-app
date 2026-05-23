import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hospital_app/features/map/data/models/flow_snapshot.dart';
import 'package:hospital_app/features/map/data/models/map_floor.dart';
import 'package:hospital_app/features/map/data/models/map_obstacle.dart';
import 'package:hospital_app/features/map/data/models/map_sync_full.dart';
import 'package:hospital_app/features/map/data/models/route_result.dart';
import 'package:hospital_app/features/map/data/models/map_poi.dart';
import 'package:hospital_app/features/map/data/models/map_edge.dart';

class MapCacheService {
  static const _boxName = 'map_sync_full_cache';
  static const _lastSyncedAtKey = 'last_synced_at';

  Future<Box<dynamic>>? _boxFuture;

  Future<void> saveSyncFull({
    required int mapId,
    required MapSyncFull syncFull,
  }) async {
    final box = await _openBox();
    final syncedAt = DateTime.now().toUtc();
    await box.put(_dataKey(mapId), jsonEncode(syncFull.toJson()));
    if (syncFull.maps.isNotEmpty) {
      await box.put(
        _floorsKey,
        jsonEncode(syncFull.maps.map((floor) => floor.toJson()).toList()),
      );
    }
    await box.put(_lastSyncedAtDataKey(mapId), syncedAt.toIso8601String());
    await box.put(_lastSyncedAtKey, syncedAt.toIso8601String());
  }

  Future<MapSyncFull?> loadSyncFull({required int mapId}) async {
    final box = await _openBox();
    final raw = box.get(_dataKey(mapId));
    if (raw is String) {
      final json = jsonDecode(raw);
      if (json is Map<String, dynamic>) {
        return MapSyncFull.fromJson(json);
      }
      if (json is Map) {
        return MapSyncFull.fromJson(Map<String, dynamic>.from(json));
      }
      return null;
    }
    if (raw is Map) {
      return MapSyncFull.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  Future<DateTime?> lastSyncedAt({int? mapId}) async {
    final box = await _openBox();
    final key = mapId == null ? _lastSyncedAtKey : _lastSyncedAtDataKey(mapId);
    final raw = box.get(key);
    if (raw is! String) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  Future<void> saveFloors(List<MapFloor> floors) async {
    final box = await _openBox();
    await box.put(
      _floorsKey,
      jsonEncode(floors.map((floor) => floor.toJson()).toList()),
    );
  }

  Future<List<MapFloor>> loadFloors() async {
    final box = await _openBox();
    final raw = box.get(_floorsKey);
    Object? decoded;
    if (raw is String) {
      decoded = jsonDecode(raw);
    } else {
      decoded = raw;
    }
    if (decoded is! List) {
      return const <MapFloor>[];
    }
    return decoded
        .whereType<Map>()
        .map((item) => MapFloor.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> saveFlowSnapshot({
    required int mapId,
    required FlowSnapshot snapshot,
  }) async {
    final box = await _openBox();
    await box.put(_flowDataKey(mapId), jsonEncode(snapshot.toJson()));
  }

  Future<FlowSnapshot?> loadFlowSnapshot({required int mapId}) async {
    final box = await _openBox();
    final raw = box.get(_flowDataKey(mapId));
    if (raw is String) {
      final json = jsonDecode(raw);
      if (json is Map) {
        return FlowSnapshot.fromJson(Map<String, dynamic>.from(json)).asStale();
      }
    }
    if (raw is Map) {
      return FlowSnapshot.fromJson(Map<String, dynamic>.from(raw)).asStale();
    }
    return null;
  }

  Future<void> saveVoiceFiles(Map<String, String> files) async {
    final box = await _openBox();
    await box.put(_voiceFilesKey, jsonEncode(files));
  }

  Future<Map<String, String>> loadVoiceFiles() async {
    final box = await _openBox();
    final raw = box.get(_voiceFilesKey);
    if (raw is String) {
      final json = jsonDecode(raw);
      if (json is Map) {
        return {
          for (final entry in json.entries)
            entry.key.toString(): entry.value.toString(),
        };
      }
    }
    if (raw is Map) {
      return {
        for (final entry in raw.entries)
          entry.key.toString(): entry.value.toString(),
      };
    }
    return const <String, String>{};
  }

  Future<void> saveObstacles({
    required int mapId,
    required List<MapObstacle> obstacles,
  }) async {
    final box = await _openBox();
    await box.put(
      _obstaclesKey(mapId),
      jsonEncode(obstacles.map((obstacle) => obstacle.toJson()).toList()),
    );
  }

  Future<List<MapObstacle>> loadObstacles({required int mapId}) async {
    final box = await _openBox();
    final raw = box.get(_obstaclesKey(mapId));
    Object? decoded;
    if (raw is String) {
      decoded = jsonDecode(raw);
    } else {
      decoded = raw;
    }
    if (decoded is! List) {
      return const <MapObstacle>[];
    }
    return decoded
        .whereType<Map>()
        .map((item) => MapObstacle.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> saveNodes({
    required int mapId,
    required List<MapPoi> nodes,
  }) async {
    final box = await _openBox();
    await box.put(
      _nodesKey(mapId),
      jsonEncode(nodes.map((node) => node.toJson()).toList()),
    );
  }

  Future<List<MapPoi>> loadNodes({required int mapId}) async {
    final box = await _openBox();
    final raw = box.get(_nodesKey(mapId));
    Object? decoded;
    if (raw is String) {
      decoded = jsonDecode(raw);
    } else {
      decoded = raw;
    }
    if (decoded is! List) {
      return const <MapPoi>[];
    }
    return decoded
        .whereType<Map>()
        .map((item) => MapPoi.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> saveEdges({
    required int mapId,
    required List<MapEdge> edges,
  }) async {
    final box = await _openBox();
    await box.put(
      _edgesKey(mapId),
      jsonEncode(edges.map((edge) => edge.toJson()).toList()),
    );
  }

  Future<List<MapEdge>> loadEdges({required int mapId}) async {
    final box = await _openBox();
    final raw = box.get(_edgesKey(mapId));
    Object? decoded;
    if (raw is String) {
      decoded = jsonDecode(raw);
    } else {
      decoded = raw;
    }
    if (decoded is! List) {
      return const <MapEdge>[];
    }
    return decoded
        .whereType<Map>()
        .map((item) => MapEdge.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> saveMeta({
    required int mapId,
    required MapFloor meta,
  }) async {
    final box = await _openBox();
    await box.put(
      _metaKey(mapId),
      jsonEncode(meta.toJson()),
    );
  }

  Future<MapFloor?> loadMeta({required int mapId}) async {
    final box = await _openBox();
    final raw = box.get(_metaKey(mapId));
    if (raw is String) {
      final json = jsonDecode(raw);
      if (json is Map) {
        return MapFloor.fromJson(Map<String, dynamic>.from(json));
      }
    }
    if (raw is Map) {
      return MapFloor.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  // Active-route cache: a single in-progress route, persisted so an ongoing
  // navigation survives a mid-trip connection drop (or app restart) without the
  // displayed path jumping to a freshly recomputed offline route. Cleared when
  // navigation ends; ignored once stale.
  Future<void> saveActiveRoute(RouteResult result) async {
    final box = await _openBox();
    await box.put(_activeRouteKey, jsonEncode(result.toJson()));
    await box.put(
      _activeRouteAtKey,
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  Future<RouteResult?> loadActiveRoute({
    Duration maxAge = const Duration(hours: 1),
  }) async {
    final box = await _openBox();
    final at = box.get(_activeRouteAtKey);
    if (at is String) {
      final savedAt = DateTime.tryParse(at);
      if (savedAt != null &&
          DateTime.now().toUtc().difference(savedAt) > maxAge) {
        debugPrint('[cache] active route STALE -> clearing');
        await clearActiveRoute();
        return null;
      }
    }
    final raw = box.get(_activeRouteKey);
    if (raw is! String) {
      debugPrint('[cache] active route MISS');
      return null;
    }
    final json = jsonDecode(raw);
    if (json is Map) {
      return RouteResult.fromJson(Map<String, dynamic>.from(json));
    }
    return null;
  }

  Future<void> clearActiveRoute() async {
    final box = await _openBox();
    await box.delete(_activeRouteKey);
    await box.delete(_activeRouteAtKey);
    debugPrint('[cache] active route CLEARED');
  }

  Future<void> saveRoute({
    required int mapId,
    required int startLocation,
    required int destLocation,
    required String modeId,
    required RouteResult result,
  }) async {
    final box = await _openBox();
    final key = _routeKey(mapId, startLocation, destLocation, modeId);
    await box.put(key, jsonEncode(result.toJson()));
    debugPrint('[cache] route SAVED $key');
  }

  Future<RouteResult?> loadRoute({
    required int mapId,
    required int startLocation,
    required int destLocation,
    required String modeId,
  }) async {
    final box = await _openBox();
    final key = _routeKey(mapId, startLocation, destLocation, modeId);
    final raw = box.get(key);
    if (raw is! String) {
      debugPrint('[cache] route MISS $key');
      return null;
    }
    final json = jsonDecode(raw);
    if (json is Map) {
      debugPrint('[cache] route HIT $key');
      return RouteResult.fromJson(Map<String, dynamic>.from(json));
    }
    debugPrint('[cache] route MISS $key (corrupt)');
    return null;
  }

  Future<Box<dynamic>> _openBox() {
    return _boxFuture ??= _initAndOpenBox();
  }

  Future<Box<dynamic>> _initAndOpenBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<dynamic>(_boxName);
    }
    try {
      return await Hive.openBox<dynamic>(_boxName);
    } catch (_) {
      await Hive.initFlutter();
      return Hive.openBox<dynamic>(_boxName);
    }
  }

  String _dataKey(int mapId) => 'map:$mapId:sync_full';

  String _lastSyncedAtDataKey(int mapId) => 'map:$mapId:last_synced_at';

  String get _floorsKey => 'map:floors';

  String _flowDataKey(int mapId) => 'map:$mapId:flow_snapshot';

  String get _voiceFilesKey => 'voice:files';

  String _obstaclesKey(int mapId) => 'map:$mapId:obstacles';

  String _nodesKey(int mapId) => 'map:$mapId:nodes';

  String _edgesKey(int mapId) => 'map:$mapId:edges';

  String _metaKey(int mapId) => 'map:$mapId:meta';

  String get _activeRouteKey => 'route:active';

  String get _activeRouteAtKey => 'route:active:at';

  String _routeKey(
    int mapId,
    int start,
    int dest,
    String mode,
  ) =>
      'route:$mapId:$start:$dest:$mode';
}

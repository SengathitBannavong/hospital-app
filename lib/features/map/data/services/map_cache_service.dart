import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:hospital_app/features/map/data/models/flow_snapshot.dart';
import 'package:hospital_app/features/map/data/models/map_obstacle.dart';
import 'package:hospital_app/features/map/data/models/map_sync_full.dart';

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

  String _flowDataKey(int mapId) => 'map:$mapId:flow_snapshot';

  String get _voiceFilesKey => 'voice:files';

  String _obstaclesKey(int mapId) => 'map:$mapId:obstacles';
}

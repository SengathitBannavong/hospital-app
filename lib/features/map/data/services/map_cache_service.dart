import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
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

  Future<Box<dynamic>> _openBox() {
    return _boxFuture ??= _initAndOpenBox();
  }

  Future<Box<dynamic>> _initAndOpenBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.initFlutter();
    }
    return Hive.openBox<dynamic>(_boxName);
  }

  String _dataKey(int mapId) => 'map:$mapId:sync_full';

  String _lastSyncedAtDataKey(int mapId) => 'map:$mapId:last_synced_at';
}

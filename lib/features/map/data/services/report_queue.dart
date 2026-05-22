import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hospital_app/features/map/data/map_repository.dart';
import 'package:hospital_app/features/map/data/models/map_obstacle.dart';

class ReportQueue {
  static const _boxName = 'map_report_queue';
  static const _obstaclesKey = 'obstacles';

  final MapRepository _repository;
  final Connectivity _connectivity;
  Future<Box<dynamic>>? _boxFuture;

  ReportQueue({
    required MapRepository repository,
    Connectivity? connectivity,
  }) : _repository = repository,
       _connectivity = connectivity ?? Connectivity();

  Future<bool> submitObstacle(MapObstacle obstacle) async {
    if (await _hasNetwork()) {
      try {
        await _repository.reportObstacle(
          gridLocation: obstacle.gridLocation,
          type: obstacle.type,
          note: obstacle.note,
        );
        await flush();
        return true;
      } catch (_) {
        // Queue below.
      }
    }
    await enqueueObstacle(obstacle);
    return false;
  }

  Future<void> enqueueObstacle(MapObstacle obstacle) async {
    final obstacles = await queuedObstacles();
    if (obstacles.any((item) => item.id == obstacle.id)) {
      return;
    }
    await _saveObstacles([...obstacles, obstacle]);
  }

  Future<List<MapObstacle>> queuedObstacles() async {
    final box = await _openBox();
    final raw = box.get(_obstaclesKey);
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

  Future<void> flush() async {
    if (!await _hasNetwork()) {
      return;
    }
    final queued = await queuedObstacles();
    if (queued.isEmpty) {
      return;
    }

    final remaining = <MapObstacle>[];
    for (final obstacle in queued) {
      try {
        await _repository.reportObstacle(
          gridLocation: obstacle.gridLocation,
          type: obstacle.type,
          note: obstacle.note,
        );
      } catch (_) {
        remaining.add(obstacle);
      }
    }
    await _saveObstacles(remaining);
  }

  Stream<List<ConnectivityResult>> onConnectivityChanged() {
    return _connectivity.onConnectivityChanged;
  }

  Future<bool> _hasNetwork() async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  Future<void> _saveObstacles(List<MapObstacle> obstacles) async {
    final box = await _openBox();
    await box.put(
      _obstaclesKey,
      jsonEncode(obstacles.map((obstacle) => obstacle.toJson()).toList()),
    );
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
}

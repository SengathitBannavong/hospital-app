import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hospital_app/features/map/data/models/edge_status.dart';
import 'package:hospital_app/features/map/data/models/flow_alert.dart';
import 'package:hospital_app/features/map/data/models/flow_cell.dart';
import 'package:hospital_app/features/map/data/models/flow_snapshot.dart';
import 'package:hospital_app/features/map/data/models/map_floor.dart';
import 'package:hospital_app/features/map/data/services/map_cache_service.dart';

void main() {
  test('MapCacheService round-trips stale flow snapshots', () async {
    final dir = await Directory.systemTemp.createTemp('flow-cache-test-');
    Hive.init(dir.path);
    addTearDown(() async {
      await Hive.close();
      await dir.delete(recursive: true);
    });

    final service = MapCacheService();
    final snapshot = FlowSnapshot(
      cells: const [FlowCell(location: 12, density: 0.7)],
      edgeStatuses: const [
        EdgeStatus(fromLocation: 1, toLocation: 2, congestion: 0.5),
      ],
      alerts: const [
        FlowAlert(
          id: 'a1',
          message: 'Busy corridor',
          location: 12,
          level: 'warning',
        ),
      ],
      updatedAt: DateTime.utc(2026, 5, 21, 10),
    );

    await service.saveFlowSnapshot(mapId: 1, snapshot: snapshot);
    final cached = await service.loadFlowSnapshot(mapId: 1);

    expect(cached, isNotNull);
    expect(cached!.isStale, isTrue);
    expect(cached.cells.single.location, 12);
    expect(cached.edgeStatuses.single.congestion, 0.5);
    expect(cached.alerts.single.message, 'Busy corridor');
  });

  test('MapCacheService round-trips cached floors', () async {
    final dir = await Directory.systemTemp.createTemp('floors-cache-test-');
    Hive.init(dir.path);
    addTearDown(() async {
      await Hive.close();
      await dir.delete(recursive: true);
    });

    final service = MapCacheService();
    const floors = [
      MapFloor(mapId: 2, mapName: 'Floor 2', rows: 33, cols: 57),
      MapFloor(mapId: 3, mapName: 'Floor 3', rows: 34, cols: 58),
    ];

    await service.saveFloors(floors);
    final cached = await service.loadFloors();

    expect(cached.map((floor) => floor.mapId), [2, 3]);
    expect(cached.last.mapName, 'Floor 3');
  });
}

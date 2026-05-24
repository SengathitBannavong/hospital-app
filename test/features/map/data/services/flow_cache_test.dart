import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hospital_app/features/map/data/models/edge_status.dart';
import 'package:hospital_app/features/map/data/models/flow_alert.dart';
import 'package:hospital_app/features/map/data/models/flow_cell.dart';
import 'package:hospital_app/features/map/data/models/flow_snapshot.dart';
import 'package:hospital_app/features/map/data/models/map_floor.dart';
import 'package:hospital_app/features/map/data/services/map_cache_service.dart';
import 'package:hospital_app/features/map/data/models/map_poi.dart';
import 'package:hospital_app/features/map/data/models/map_edge.dart';
import 'package:hospital_app/features/map/data/models/route_result.dart';
import 'package:hospital_app/features/map/data/models/route_step.dart';

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

  test(
    'MapCacheService round-trips granular slices (meta, nodes, edges)',
    () async {
      final dir = await Directory.systemTemp.createTemp('granular-cache-test-');
      Hive.init(dir.path);
      addTearDown(() async {
        await Hive.close();
        await dir.delete(recursive: true);
      });

      final service = MapCacheService();
      const meta = MapFloor(mapId: 4, mapName: 'Floor 4', rows: 40, cols: 40);
      const nodes = [
        MapPoi(
          poiId: 10,
          mapId: 4,
          poiCode: 'A',
          poiName: 'Room A',
          poiType: 'room',
          gridRow: 10,
          gridCol: 10,
          gridLocation: 100,
          isLandmark: false,
          isAccessible: true,
          wheelchairAccessible: false,
        ),
      ];
      const edges = [
        MapEdge(
          fromRow: 10,
          fromCol: 10,
          fromLocation: 100,
          toRow: 10,
          toCol: 11,
          toLocation: 101,
        ),
      ];

      await service.saveMeta(mapId: 4, meta: meta);
      await service.saveNodes(mapId: 4, nodes: nodes);
      await service.saveEdges(mapId: 4, edges: edges);

      // Read through a *fresh* instance so loadEdges cannot be served by the
      // in-memory edge cache — this proves the on-disk (Hive) round-trip.
      final reader = MapCacheService();
      final loadedMeta = await reader.loadMeta(mapId: 4);
      final loadedNodes = await reader.loadNodes(mapId: 4);
      final loadedEdges = await reader.loadEdges(mapId: 4);

      expect(loadedMeta, isNotNull);
      expect(loadedMeta!.mapName, 'Floor 4');
      expect(loadedNodes.single.poiName, 'Room A');
      expect(loadedEdges.single.fromLocation, 100);
    },
  );

  test(
    'MapCacheService clearAll wipes cached map data and memory edges',
    () async {
      final dir = await Directory.systemTemp.createTemp('clear-cache-test-');
      Hive.init(dir.path);
      addTearDown(() async {
        await Hive.close();
        await dir.delete(recursive: true);
      });

      final service = MapCacheService();
      const meta = MapFloor(mapId: 9, mapName: 'Floor 9', rows: 10, cols: 10);
      const nodes = [
        MapPoi(
          poiId: 90,
          mapId: 9,
          poiCode: 'N',
          poiName: 'Node',
          poiType: 'room',
          gridRow: 1,
          gridCol: 1,
          gridLocation: 11,
          isLandmark: false,
          isAccessible: true,
          wheelchairAccessible: false,
        ),
      ];
      const edges = [
        MapEdge(
          fromRow: 1,
          fromCol: 1,
          fromLocation: 11,
          toRow: 1,
          toCol: 2,
          toLocation: 12,
        ),
      ];

      await service.saveFloors(const [meta]);
      await service.saveMeta(mapId: 9, meta: meta);
      await service.saveNodes(mapId: 9, nodes: nodes);
      await service.saveEdges(mapId: 9, edges: edges);

      await service.clearAll();

      expect(await service.loadFloors(), isEmpty);
      expect(await service.loadMeta(mapId: 9), isNull);
      expect(await service.loadNodes(mapId: 9), isEmpty);
      expect(await service.loadEdges(mapId: 9), isEmpty);
    },
  );

  test(
    'MapCacheService round-trips a large edge set via the parse isolate',
    () async {
      final dir = await Directory.systemTemp.createTemp('large-edges-test-');
      Hive.init(dir.path);
      addTearDown(() async {
        await Hive.close();
        await dir.delete(recursive: true);
      });

      // Above _edgeParseIsolateThreshold (1000) so both save and load route
      // through compute() — the isolate serialize/parse path that the smaller
      // fixtures never exercise.
      final edges = [
        for (var i = 0; i < 1500; i++)
          MapEdge(
            fromRow: i ~/ 40,
            fromCol: i % 40,
            fromLocation: i,
            toRow: i ~/ 40,
            toCol: (i % 40) + 1,
            toLocation: i + 1,
          ),
      ];

      await MapCacheService().saveEdges(mapId: 7, edges: edges);

      // Fresh instance: bypass the in-memory cache and force the Hive read plus
      // isolate parse.
      final loaded = await MapCacheService().loadEdges(mapId: 7);

      expect(loaded.length, edges.length);
      expect(loaded.first.fromLocation, 0);
      expect(loaded.last.toLocation, 1500);
    },
  );

  test('MapCacheService round-trips the active route and clears it', () async {
    final dir = await Directory.systemTemp.createTemp('active-route-test-');
    Hive.init(dir.path);
    addTearDown(() async {
      await Hive.close();
      await dir.delete(recursive: true);
    });

    final service = MapCacheService();
    const route = RouteResult(
      path: [100, 101, 102],
      steps: [
        RouteStep(location: 100, maneuver: StepManeuver.start, distance: 1),
        RouteStep(location: 102, maneuver: StepManeuver.arrive, distance: 0),
      ],
      distance: 2,
      estimatedTime: 4,
      modeId: 'walking',
      speedFactor: 1,
    );

    await service.saveActiveRoute(route);
    final loaded = await service.loadActiveRoute();

    expect(loaded, isNotNull);
    expect(loaded!.path, [100, 101, 102]);
    expect(loaded.modeId, 'walking');
    expect(loaded.steps.length, 2);

    await service.clearActiveRoute();
    expect(await service.loadActiveRoute(), isNull);
  });

  test('MapCacheService ignores a stale active route', () async {
    final dir = await Directory.systemTemp.createTemp('active-route-stale-');
    Hive.init(dir.path);
    addTearDown(() async {
      await Hive.close();
      await dir.delete(recursive: true);
    });

    final service = MapCacheService();
    const route = RouteResult(
      path: [1, 2],
      steps: [
        RouteStep(location: 1, maneuver: StepManeuver.start, distance: 1),
        RouteStep(location: 2, maneuver: StepManeuver.arrive, distance: 0),
      ],
      distance: 1,
      estimatedTime: 2,
      modeId: 'walking',
      speedFactor: 1,
    );

    await service.saveActiveRoute(route);
    // A zero max-age makes any saved route immediately stale.
    final loaded = await service.loadActiveRoute(maxAge: Duration.zero);

    expect(loaded, isNull);
  });

  test('MapCacheService round-trips multiple directional routes', () async {
    final dir = await Directory.systemTemp.createTemp('route-cache-test-');
    Hive.init(dir.path);
    addTearDown(() async {
      await Hive.close();
      await dir.delete(recursive: true);
    });

    final service = MapCacheService();
    const routeAD = RouteResult(
      path: [1, 2, 3],
      steps: [
        RouteStep(location: 1, maneuver: StepManeuver.start, distance: 1),
        RouteStep(location: 3, maneuver: StepManeuver.arrive, distance: 0),
      ],
      distance: 2,
      estimatedTime: 5,
      modeId: 'walking',
      speedFactor: 1,
    );

    const routeDA = RouteResult(
      path: [3, 2, 1],
      steps: [
        RouteStep(location: 3, maneuver: StepManeuver.start, distance: 1),
        RouteStep(location: 1, maneuver: StepManeuver.arrive, distance: 0),
      ],
      distance: 2,
      estimatedTime: 5,
      modeId: 'walking',
      speedFactor: 1,
    );

    await service.saveRoute(
      mapId: 1,
      startLocation: 1,
      destLocation: 3,
      modeId: 'walking',
      result: routeAD,
    );

    await service.saveRoute(
      mapId: 1,
      startLocation: 3,
      destLocation: 1,
      modeId: 'walking',
      result: routeDA,
    );

    final loadedAD = await service.loadRoute(
      mapId: 1,
      startLocation: 1,
      destLocation: 3,
      modeId: 'walking',
    );

    final loadedDA = await service.loadRoute(
      mapId: 1,
      startLocation: 3,
      destLocation: 1,
      modeId: 'walking',
    );

    expect(loadedAD, isNotNull);
    expect(loadedAD!.path, [1, 2, 3]);
    expect(loadedAD.estimatedTime, 5);

    expect(loadedDA, isNotNull);
    expect(loadedDA!.path, [3, 2, 1]);
    expect(loadedDA.estimatedTime, 5);
  });
}

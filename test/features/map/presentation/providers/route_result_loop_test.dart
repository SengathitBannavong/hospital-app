import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hospital_app/features/map/data/map_repository.dart';
import 'package:hospital_app/features/map/data/models/map_floor.dart';
import 'package:hospital_app/features/map/data/models/map_obstacle.dart';
import 'package:hospital_app/features/map/data/models/map_poi.dart';
import 'package:hospital_app/features/map/data/models/flow_cell.dart';
import 'package:hospital_app/features/map/data/models/edge_status.dart';
import 'package:hospital_app/features/map/data/models/flow_snapshot.dart';
import 'package:hospital_app/features/map/data/models/route_result.dart';
import 'package:hospital_app/features/map/data/services/map_cache_service.dart';
import 'package:hospital_app/features/map/data/services/routing_engine.dart';
import 'package:hospital_app/features/map/data/services/routing_service.dart';
import 'package:hospital_app/features/map/presentation/providers/map_provider.dart';

/// Regression guard for the routeResultProvider rebuild loop:
/// invalidating a provider that is then watched in the same build made the
/// route recompute (and bottlenecks re-point) ~continuously. Mount the REAL
/// provider and assert it settles instead of looping.
void main() {
  late Directory tempDir;
  late MapCacheService testCache;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('route-loop-test-');
    Hive.init(tempDir.path);
    testCache = MapCacheService();
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test(
    'routeResultProvider settles (does not loop) with start+dest set',
    () async {
      final service = RoutingService(
        repository: FakeMapRepository(),
        engine: RoutingEngine(),
        cache: testCache,
        connectivity: FakeConnectivity([ConnectivityResult.none]),
      );

      const dest = MapPoi(
        poiId: 1,
        mapId: 1,
        poiCode: 'D',
        poiName: 'Dest',
        poiType: 'room',
        gridRow: 0,
        gridCol: 2,
        gridLocation: 2,
        isLandmark: false,
        isAccessible: true,
        wheelchairAccessible: true,
      );

      // The loop manifests as routeResultProvider re-invalidating its inputs
      // every rebuild, so a re-fetched input fires repeatedly. Tap the
      // bottlenecks input: count how many times it is rebuilt.
      var bottlenecksBuilds = 0;

      final container = ProviderContainer(
        overrides: [
          routingServiceProvider.overrideWithValue(service),
          userPositionProvider.overrideWith((ref) => 0),
          routeDestProvider.overrideWith((ref) => dest),
          selectedFloorProvider.overrideWith((ref) => 1),
          floorsProvider.overrideWith((ref) async => const <MapFloor>[]),
          mapMetaProvider.overrideWith(
            (ref, id) async =>
                const MapFloor(mapId: 1, mapName: 't', rows: 3, cols: 3),
          ),
          adjacencyProvider.overrideWith((ref, id) => const <int, List<int>>{}),
          flowSnapshotProvider.overrideWith(
            (ref, id) async => throw StateError('no flow'),
          ),
          mapObstaclesProvider.overrideWith(
            (ref, id) async => const <MapObstacle>[],
          ),
          poiByCellProvider.overrideWith((ref, id) => const <int, MapPoi>{}),
          bottlenecksProvider.overrideWith((ref, id) async {
            bottlenecksBuilds++;
            return const <FlowCell>[];
          }),
        ],
      );
      addTearDown(container.dispose);

      final sub = container.listen<AsyncValue<dynamic>>(
        routeResultProvider,
        (prev, next) {},
        fireImmediately: true,
      );
      addTearDown(sub.close);

      // Let the graph churn for well over a second — a loop would rebuild the
      // bottlenecks input dozens of times in this window.
      await Future<void>.delayed(const Duration(milliseconds: 1500));

      // ignore: avoid_print
      print('BOTTLENECKS_BUILDS=$bottlenecksBuilds');
      expect(
        bottlenecksBuilds,
        lessThan(5),
        reason: 'routeResultProvider should settle, not loop its inputs',
      );
    },
  );

  test('flow refresh does not recompute an already-rendered route', () async {
    final service = CountingRoutingService(cache: testCache);

    const dest = MapPoi(
      poiId: 1,
      mapId: 1,
      poiCode: 'D',
      poiName: 'Dest',
      poiType: 'room',
      gridRow: 0,
      gridCol: 2,
      gridLocation: 2,
      isLandmark: false,
      isAccessible: true,
      wheelchairAccessible: true,
    );

    final container = ProviderContainer(
      overrides: [
        routingServiceProvider.overrideWithValue(service),
        userPositionProvider.overrideWith((ref) => 0),
        routeDestProvider.overrideWith((ref) => dest),
        selectedFloorProvider.overrideWith((ref) => 1),
        floorsProvider.overrideWith((ref) async => const <MapFloor>[]),
        mapMetaProvider.overrideWith(
          (ref, id) async =>
              const MapFloor(mapId: 1, mapName: 't', rows: 3, cols: 3),
        ),
        adjacencyProvider.overrideWith(
          (ref, id) => const <int, List<int>>{
            0: [1],
            1: [0, 2],
            2: [1],
          },
        ),
        flowSnapshotProvider.overrideWith(
          (ref, id) async => FlowSnapshot.empty(),
        ),
        mapObstaclesProvider.overrideWith(
          (ref, id) async => const <MapObstacle>[],
        ),
        poiByCellProvider.overrideWith((ref, id) => const <int, MapPoi>{}),
        bottlenecksProvider.overrideWith((ref, id) async => const <FlowCell>[]),
      ],
    );
    addTearDown(container.dispose);

    final route = await container.read(routeResultProvider.future);
    expect(route?.path, [0, 1, 2]);
    expect(service.routeCalls, 1);

    container
      ..invalidate(flowSnapshotProvider(1))
      ..invalidate(bottlenecksProvider(1));
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(service.routeCalls, 1);
  });

  test('route avoids a bottleneck with no analytics overlay active', () async {
    // Regression: routeResultProvider used to read crowd inputs with
    // .read().valueOrNull, which was null unless an overlay had already fetched
    // them — so routing ignored bottlenecks/obstacles and walked straight
    // through. It now fetches them on demand, so this passes with overlays off.
    final service = RoutingService(
      repository: FakeMapRepository(),
      engine: RoutingEngine(),
      cache: testCache,
      connectivity: FakeConnectivity([ConnectivityResult.none]),
    );

    const dest = MapPoi(
      poiId: 1,
      mapId: 1,
      poiCode: 'D',
      poiName: 'Dest',
      poiType: 'room',
      gridRow: 0,
      gridCol: 2,
      gridLocation: 2,
      isLandmark: false,
      isAccessible: true,
      wheelchairAccessible: true,
    );

    final container = ProviderContainer(
      overrides: [
        routingServiceProvider.overrideWithValue(service),
        userPositionProvider.overrideWith((ref) => 0),
        routeDestProvider.overrideWith((ref) => dest),
        selectedFloorProvider.overrideWith((ref) => 1),
        floorsProvider.overrideWith((ref) async => const <MapFloor>[]),
        mapMetaProvider.overrideWith(
          (ref, id) async =>
              const MapFloor(mapId: 1, mapName: 't', rows: 3, cols: 3),
        ),
        // 0->2 directly via cell 1, or detour 0-3-4-5-2 avoiding it.
        adjacencyProvider.overrideWith(
          (ref, id) => const <int, List<int>>{
            0: [1, 3],
            1: [0, 2],
            2: [1, 5],
            3: [0, 4],
            4: [3, 5],
            5: [2, 4],
          },
        ),
        flowSnapshotProvider.overrideWith(
          (ref, id) async => FlowSnapshot.empty(),
        ),
        mapObstaclesProvider.overrideWith(
          (ref, id) async => const <MapObstacle>[],
        ),
        poiByCellProvider.overrideWith((ref, id) => const <int, MapPoi>{}),
        // Bottleneck on cell 1 — never read by an overlay here, only by
        // routeResultProvider's own on-demand fetch.
        bottlenecksProvider.overrideWith(
          (ref, id) async => const [FlowCell(location: 1, density: 1)],
        ),
      ],
    );
    addTearDown(container.dispose);

    final route = await container.read(routeResultProvider.future);

    expect(route, isNotNull);
    expect(route!.path.first, 0);
    expect(route.path.last, 2);
    expect(
      route.path,
      isNot(contains(1)),
      reason: 'crowd-aware engine should detour around the bottleneck cell '
          'even with the analytics overlay closed',
    );
  });
}

class FakeConnectivity implements Connectivity {
  FakeConnectivity(this.results);
  final List<ConnectivityResult> results;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => results;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeMapRepository extends MapRepository {
  @override
  Future<Map<String, dynamic>> previewRoute({
    required int startLocation,
    required int destLocation,
    required String modeId,
  }) async => throw UnimplementedError();
}

class CountingRoutingService extends RoutingService {
  CountingRoutingService({required super.cache})
    : super(
        repository: FakeMapRepository(),
        engine: RoutingEngine(),
        connectivity: FakeConnectivity([ConnectivityResult.none]),
      );

  int routeCalls = 0;

  @override
  Future<RouteResult> route({
    required int mapId,
    required int startLocation,
    required int destLocation,
    required String modeId,
    required Map<int, List<int>> adjacency,
    required int cols,
    Map<String, EdgeStatus> edgeStatuses = const <String, EdgeStatus>{},
    Set<int> poiCells = const <int>{},
    Map<int, double> bottleneckWeights = const <int, double>{},
  }) async {
    routeCalls++;
    return const RouteResult(
      path: [0, 1, 2],
      steps: [],
      distance: 2,
      estimatedTime: 1,
      modeId: 'walking',
      speedFactor: 6,
    );
  }
}

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

  test('routeResultProvider settles (does not loop) with start+dest set',
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
          (ref, id) async => const MapFloor(
            mapId: 1,
            mapName: 't',
            rows: 3,
            cols: 3,
          ),
        ),
        adjacencyProvider.overrideWith(
          (ref, id) => const <int, List<int>>{},
        ),
        flowSnapshotProvider.overrideWith(
          (ref, id) async => throw StateError('no flow'),
        ),
        mapObstaclesProvider.overrideWith(
          (ref, id) async => const <MapObstacle>[],
        ),
        poiByCellProvider.overrideWith(
          (ref, id) => const <int, MapPoi>{},
        ),
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
  });
}

class FakeConnectivity implements Connectivity {
  FakeConnectivity(this.results);
  final List<ConnectivityResult> results;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => results;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class FakeMapRepository extends MapRepository {
  @override
  Future<Map<String, dynamic>> previewRoute({
    required int startLocation,
    required int destLocation,
    required String modeId,
  }) async =>
      throw UnimplementedError();
}

import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hospital_app/features/map/data/map_repository.dart';
import 'package:hospital_app/features/map/data/models/route_result.dart';
import 'package:hospital_app/features/map/data/models/route_step.dart';
import 'package:hospital_app/features/map/data/services/map_cache_service.dart';
import 'package:hospital_app/features/map/data/services/routing_engine.dart';
import 'package:hospital_app/features/map/data/services/routing_service.dart';

void main() {
  group('RoutingService Caching', () {
    late Directory tempDir;
    late MapCacheService testCache;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('routing-service-test-');
      Hive.init(tempDir.path);
      testCache = MapCacheService();
    });

    tearDown(() async {
      await Hive.close();
      await tempDir.delete(recursive: true);
    });

    test('Online route caching (network available)', () async {
      final fakeRepo = FakeMapRepository(
        onPreviewRoute: () async => {
          'steps': [
            {'step_order': 1, 'grid_location': 10},
            {'step_order': 2, 'grid_location': 11},
          ],
          'distance': 1.0,
          'estimated_time': 2.0,
          'mode_id': 'walking',
          'speed_factor': 1.0,
        },
      );

      final service = RoutingService(
        repository: fakeRepo,
        engine: RoutingEngine(),
        cache: testCache,
        connectivity: FakeConnectivity([ConnectivityResult.wifi]),
      );

      final result = await service.route(
        mapId: 1,
        startLocation: 10,
        destLocation: 11,
        modeId: 'walking',
        adjacency: const {},
        cols: 10,
      );

      expect(result.path, [10, 11]);
      expect(result.distance, 1.0);

      // Verify that it is saved in the cache
      final cached = await testCache.loadRoute(
        mapId: 1,
        startLocation: 10,
        destLocation: 11,
        modeId: 'walking',
      );
      expect(cached, isNotNull);
      expect(cached!.path, [10, 11]);
    });

    test('Offline cached replay', () async {
      // Pre-seed cache with a specific route
      const cachedRoute = RouteResult(
        path: [100, 101, 102],
        steps: [
          RouteStep(
            location: 100,
            maneuver: StepManeuver.start,
            distance: 1.0,
          ),
          RouteStep(
            location: 102,
            maneuver: StepManeuver.arrive,
            distance: 0.0,
          ),
        ],
        distance: 2.0,
        estimatedTime: 4.0,
        modeId: 'walking',
        speedFactor: 1.0,
      );

      await testCache.saveRoute(
        mapId: 1,
        startLocation: 100,
        destLocation: 102,
        modeId: 'walking',
        result: cachedRoute,
      );

      final fakeRepo = FakeMapRepository(
        onPreviewRoute: () async =>
            throw Exception('No network should be reached'),
      );

      final service = RoutingService(
        repository: fakeRepo,
        engine: RoutingEngine(),
        cache: testCache,
        connectivity: FakeConnectivity([ConnectivityResult.none]),
      );

      final result = await service.route(
        mapId: 1,
        startLocation: 100,
        destLocation: 102,
        modeId: 'walking',
        adjacency: const {},
        cols: 10,
      );

      // Should return the cached route immediately without calling engine/repo
      expect(result.path, [100, 101, 102]);
      expect(result.distance, 2.0);
    });

    test('Offline cache miss fallback to RoutingEngine', () async {
      final fakeRepo = FakeMapRepository(
        onPreviewRoute: () async => throw Exception('Network error'),
      );

      final service = RoutingService(
        repository: fakeRepo,
        engine: RoutingEngine(),
        cache: testCache,
        connectivity: FakeConnectivity([ConnectivityResult.none]),
      );

      // RoutingEngine needs a valid graph to calculate path
      final adjacency = {
        200: [201],
        201: [200],
      };

      final result = await service.route(
        mapId: 1,
        startLocation: 200,
        destLocation: 201,
        modeId: 'walking',
        adjacency: adjacency,
        cols: 10,
      );

      // Should fall back to the engine and calculate path correctly
      expect(result.path, [200, 201]);
    });
  });
}

class FakeConnectivity implements Connectivity {
  final List<ConnectivityResult> results;
  FakeConnectivity(this.results);

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => results;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeMapRepository extends MapRepository {
  final Future<Map<String, dynamic>> Function()? onPreviewRoute;
  final Future<Map<String, dynamic>> Function()? onRecalculateRoute;

  FakeMapRepository({this.onPreviewRoute, this.onRecalculateRoute});

  @override
  Future<Map<String, dynamic>> previewRoute({
    required int startLocation,
    required int destLocation,
    required String modeId,
  }) async {
    if (onPreviewRoute != null) {
      return onPreviewRoute!();
    }
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> recalculateRoute({
    required String routeId,
    required int currentLocation,
  }) async {
    if (onRecalculateRoute != null) {
      return onRecalculateRoute!();
    }
    throw UnimplementedError();
  }
}

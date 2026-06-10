import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hospital_app/features/map/data/map_repository.dart';
import 'package:hospital_app/features/map/data/models/flow_alert.dart';
import 'package:hospital_app/features/map/data/models/flow_cell.dart';
import 'package:hospital_app/features/map/data/models/flow_forecast_bucket.dart';
import 'package:hospital_app/features/map/data/services/flow_service.dart';
import 'package:hospital_app/features/map/data/services/map_cache_service.dart';

void main() {
  group('FlowService & MapRepository Overlay Parsing Tests', () {
    late Directory tempDir;
    late MapCacheService testCache;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('flow-service-test-');
      Hive.init(tempDir.path);
      testCache = MapCacheService();
    });

    tearDown(() async {
      await Hive.close();
      await tempDir.delete(recursive: true);
    });

    test('FlowService normalizes density values to 0..1 range', () async {
      final fakeRepo = FakeFlowMapRepository(
        onGetHeatmap: () async => const [
          FlowCell(location: 100, density: 12.0),
          FlowCell(location: 101, density: 3.0),
          FlowCell(location: 102, density: 0.0),
        ],
        onGetAlerts: () async => const [],
      );

      final service = FlowService(repository: fakeRepo, cache: testCache);
      final snapshot = await service.snapshot(mapId: 1);

      expect(snapshot.cells.length, 3);
      // Normalized: 12.0 / 12.0 = 1.0
      expect(snapshot.cells[0].density, 1.0);
      // Normalized: 3.0 / 12.0 = 0.25
      expect(snapshot.cells[1].density, 0.25);
      // Normalized: 0.0 / 12.0 = 0.0
      expect(snapshot.cells[2].density, 0.0);
      expect(snapshot.edgeStatuses, isEmpty);
    });

    test('FlowService handles zero-density cases gracefully', () async {
      final fakeRepo = FakeFlowMapRepository(
        onGetHeatmap: () async => const [
          FlowCell(location: 100, density: 0.0),
          FlowCell(location: 101, density: 0.0),
        ],
        onGetAlerts: () async => const [],
      );

      final service = FlowService(repository: fakeRepo, cache: testCache);
      final snapshot = await service.snapshot(mapId: 1);

      expect(snapshot.cells[0].density, 0.0);
      expect(snapshot.cells[1].density, 0.0);
    });

    test('FlowService handles empty heatmap cells gracefully', () async {
      final fakeRepo = FakeFlowMapRepository(
        onGetHeatmap: () async => const [],
        onGetAlerts: () async => const [],
      );

      final service = FlowService(repository: fakeRepo, cache: testCache);
      final snapshot = await service.snapshot(mapId: 1);

      expect(snapshot.cells, isEmpty);
    });

    test('MapRepository parses flow alerts stub successfully', () {
      final repository = MapRepository();
      final alerts = repository.parseFlowAlertsForTesting(const {
        'result': true,
      });
      expect(alerts, isEmpty);
    });

    test('MapRepository parses real flow alerts successfully', () {
      final repository = MapRepository();
      final alertsJson = {
        'alerts': [
          {
            'id': 'a1',
            'message': 'Severe congestion in corridor A',
            'location': 120,
            'level': 'danger',
          },
          {
            'id': 'a2',
            'message': 'Caution: Wet floor near elevator',
            'location': 155,
            'level': 'warning',
          },
        ],
      };
      final alerts = repository.parseFlowAlertsForTesting(alertsJson);
      expect(alerts.length, 2);
      expect(alerts[0].id, 'a1');
      expect(alerts[0].message, 'Severe congestion in corridor A');
      expect(alerts[0].location, 120);
      expect(alerts[0].level, 'danger');

      expect(alerts[1].id, 'a2');
      expect(alerts[1].level, 'warning');
    });

    test('MapRepository parses hourly forecast buckets', () {
      final repository = MapRepository();

      final buckets = repository.parseFlowForecastBucketsForTesting(const {
        'data': [
          {'hour': 8, 'count': 12},
          {'hour': 9, 'count': 0},
        ],
      });

      expect(buckets, const [
        FlowForecastBucket(hour: 8, count: 12),
        FlowForecastBucket(hour: 9, count: 0),
      ]);
      expect(repository.parseFlowForecastBucketsForTesting(null), isEmpty);
      expect(
        repository.parseFlowForecastBucketsForTesting(const {'data': null}),
        isEmpty,
      );
    });
  });
}

class FakeFlowMapRepository extends MapRepository {
  final Future<List<FlowCell>> Function()? onGetHeatmap;
  final Future<List<FlowAlert>> Function()? onGetAlerts;

  FakeFlowMapRepository({this.onGetHeatmap, this.onGetAlerts});

  @override
  Future<List<FlowCell>> getFlowHeatmap() async {
    if (onGetHeatmap != null) return onGetHeatmap!();
    return const [];
  }

  @override
  Future<List<FlowAlert>> getFlowAlerts() async {
    if (onGetAlerts != null) return onGetAlerts!();
    return const [];
  }
}

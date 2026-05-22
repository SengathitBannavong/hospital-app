import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hospital_app/features/map/data/map_repository.dart';
import 'package:hospital_app/features/map/data/models/map_obstacle.dart';
import 'package:hospital_app/features/map/data/services/report_queue.dart';

void main() {
  test('ReportQueue buffers obstacle reports in Hive', () async {
    final dir = await Directory.systemTemp.createTemp('report-queue-test-');
    Hive.init(dir.path);
    addTearDown(() async {
      await Hive.close();
      await dir.delete(recursive: true);
    });

    final queue = ReportQueue(repository: MapRepository());
    final obstacle = MapObstacle(
      id: 'local-1',
      gridLocation: 7,
      type: 'spill',
      note: 'Water',
      reportedAt: DateTime.utc(2026, 5, 22),
    );

    await queue.enqueueObstacle(obstacle);
    await queue.enqueueObstacle(obstacle);
    final queued = await queue.queuedObstacles();

    expect(queued, hasLength(1));
    expect(queued.single.gridLocation, 7);
    expect(queued.single.type, 'spill');
  });

  test('ReportQueue flush success clears queued reports', () async {
    final dir = await Directory.systemTemp.createTemp('report-flush-test-');
    Hive.init(dir.path);
    addTearDown(() async {
      await Hive.close();
      await dir.delete(recursive: true);
    });

    final repository = _ReportRepository();
    final queue = ReportQueue(
      repository: repository,
      isOnline: () async => true,
    );
    final obstacle = MapObstacle(
      id: 'local-2',
      gridLocation: 9,
      type: 'blockage',
      reportedAt: DateTime.utc(2026, 5, 22),
    );

    await queue.enqueueObstacle(obstacle);
    await queue.flush();

    expect(await queue.queuedObstacles(), isEmpty);
    expect(repository.reportedLocations, [9]);
  });
}

class _ReportRepository extends MapRepository {
  final reportedLocations = <int>[];

  @override
  Future<void> reportObstacle({
    required int gridLocation,
    required String type,
    String? note,
    String? routeId,
  }) async {
    reportedLocations.add(gridLocation);
  }
}

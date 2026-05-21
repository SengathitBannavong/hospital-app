import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/features/map/data/models/map_edge.dart';
import 'package:hospital_app/features/map/data/models/map_floor.dart';
import 'package:hospital_app/features/map/data/models/map_poi.dart';
import 'package:hospital_app/features/map/data/services/route_result_mapper.dart';
import 'package:hospital_app/features/map/data/services/routing_engine.dart';
import 'package:hospital_app/features/map/presentation/providers/map_provider.dart';

void main() {
  group('searchResultsProvider', () {
    test(
      'matches Vietnamese POI names when query is written without accents',
      () async {
        final container = ProviderContainer(
          overrides: [
            searchKeywordProvider.overrideWith((ref) => 'cong'),
            mapNodesProvider.overrideWith((ref, mapId) async {
              return [
                _poi(
                  id: 1,
                  code: 'ENT-01',
                  name: 'Cổng chính',
                  type: 'entrance',
                ),
                _poi(
                  id: 2,
                  code: 'RM-101',
                  name: 'Phòng khám Nội khoa',
                  type: 'room',
                ),
              ];
            }),
          ],
        );
        addTearDown(container.dispose);

        final results = await container.read(searchResultsProvider(1).future);

        expect(results, hasLength(1));
        expect(results.single.poiName, 'Cổng chính');
      },
    );

    test(
      'matches Vietnamese POI names when query is a partial unaccented word',
      () async {
        final container = ProviderContainer(
          overrides: [
            searchKeywordProvider.overrideWith((ref) => 'phong kham'),
            mapNodesProvider.overrideWith((ref, mapId) async {
              return [
                _poi(
                  id: 1,
                  code: 'ENT-01',
                  name: 'Cổng chính',
                  type: 'entrance',
                ),
                _poi(
                  id: 2,
                  code: 'RM-101',
                  name: 'Phòng khám Nội khoa',
                  type: 'room',
                ),
              ];
            }),
          ],
        );
        addTearDown(container.dispose);

        final results = await container.read(searchResultsProvider(1).future);

        expect(results, hasLength(1));
        expect(results.single.poiName, 'Phòng khám Nội khoa');
      },
    );

    test('does not match POI code or type when name does not match', () async {
      final container = ProviderContainer(
        overrides: [
          searchKeywordProvider.overrideWith((ref) => 'entrance'),
          mapNodesProvider.overrideWith((ref, mapId) async {
            return [
              _poi(id: 1, code: 'ENT-01', name: 'Cổng chính', type: 'entrance'),
            ];
          }),
        ],
      );
      addTearDown(container.dispose);

      final results = await container.read(searchResultsProvider(1).future);

      expect(results, isEmpty);
    });
  });

  _addNormalizedHarness();
}

MapPoi _poi({
  required int id,
  required String code,
  required String name,
  required String type,
  int? row,
  int? col,
}) {
  return MapPoi(
    poiId: id,
    mapId: 1,
    poiCode: code,
    poiName: name,
    poiType: type,
    gridRow: row ?? id,
    gridCol: col ?? id,
    gridLocation: id,
    isLandmark: false,
    isAccessible: true,
    wheelchairAccessible: false,
  );
}

void _addNormalizedHarness() {
  group('normalizedPoiNamesProvider', () {
    test('maps poiId -> normalized name', () async {
      final container = ProviderContainer(
        overrides: [
          mapNodesProvider.overrideWith(
            (ref, mapId) async => [
              _poi(id: 1, code: 'A', name: 'Cổng chính', type: 'entrance'),
              _poi(id: 2, code: 'B', name: 'Phòng Khám', type: 'room'),
            ],
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(mapNodesProvider(1).future);

      final map = container.read(normalizedPoiNamesProvider(1));
      expect(map[1], 'cong chinh');
      expect(map[2], 'phong kham');
    });
  });

  group('poiByCellProvider', () {
    test('keys by row*cols+col and skips out-of-bounds', () async {
      final container = ProviderContainer(
        overrides: [
          mapMetaProvider.overrideWith(
            (ref, mapId) async =>
                const MapFloor(mapId: 1, mapName: 'm', rows: 10, cols: 5),
          ),
          mapNodesProvider.overrideWith(
            (ref, mapId) async => [
              _poi(id: 1, code: 'A', name: 'a', type: 'room', row: 2, col: 3),
              _poi(id: 2, code: 'B', name: 'b', type: 'room', row: 99, col: 0),
            ],
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(mapMetaProvider(1).future);
      await container.read(mapNodesProvider(1).future);

      final byCell = container.read(poiByCellProvider(1));
      expect(byCell[2 * 5 + 3]?.poiId, 1);
      expect(byCell.length, 1);
    });
  });

  group('walkableCellsProvider', () {
    test('derives set from edge endpoints', () async {
      final container = ProviderContainer(
        overrides: [
          mapEdgesProvider.overrideWith(
            (ref, mapId) async => const [
              MapEdge(
                fromRow: 0,
                fromCol: 0,
                fromLocation: 0,
                toRow: 0,
                toCol: 1,
                toLocation: 1,
              ),
              MapEdge(
                fromRow: 0,
                fromCol: 1,
                fromLocation: 1,
                toRow: 0,
                toCol: 2,
                toLocation: 2,
              ),
            ],
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(mapEdgesProvider(1).future);

      final walkable = container.read(walkableCellsProvider(1));
      expect(walkable, {0, 1, 2});
    });
  });

  group('RouteResultMapper', () {
    const mapper = RouteResultMapper();

    test('sorts online preview steps and extracts grid_location path', () {
      final data = {
        'steps': [
          {'step_order': 2, 'grid_location': 20},
          {'step_order': 1, 'grid_location': 10},
          {'step_order': 3, 'grid_location': 30},
        ],
        'distance': 2,
        'estimated_time': 0.5,
        'mode_id': 'walking',
        'speed_factor': 4,
      };

      final result = mapper.fromPreviewJson(data);

      expect(result.path, [10, 20, 30]);
      expect(result.distance, 2);
      expect(result.estimatedTime, 0.5);
      expect(result.modeId, 'walking');
      expect(result.speedFactor, 4);
    });

    test('normalizes offline preview shape', () {
      final result = mapper.fromPreviewJson({
        'path': [1, 2, 3],
        'steps': [
          {'step_order': 1, 'location': 1, 'maneuver': 'start'},
          {'step_order': 2, 'location': 2, 'maneuver': 'straight'},
          {'step_order': 3, 'location': 3, 'maneuver': 'arrive'},
        ],
        'distance': 2,
        'estimated_time': 0.3,
        'mode_id': 'walking',
        'speed_factor': 6,
        'source': 'offline',
      });

      expect(result.path, [1, 2, 3]);
      expect(result.steps, hasLength(3));
    });

    test('null/empty returns an empty result', () {
      expect(mapper.fromPreviewJson(null).path, isEmpty);
      expect(mapper.fromPreviewJson(<dynamic>[]).path, isEmpty);
    });

    test('engine and mapped preview produce equivalent paths', () {
      final engineResult = RoutingEngine().route(
        startLocation: 0,
        destLocation: 2,
        modeId: 'walking',
        adjacency: const {
          0: [1],
          1: [0, 2],
          2: [1],
        },
        cols: 3,
      );

      final onlineResult = mapper.fromPreviewJson({
        'steps': [
          {'step_order': 1, 'grid_location': 0},
          {'step_order': 2, 'grid_location': 1},
          {'step_order': 3, 'grid_location': 2},
        ],
        'distance': 2,
        'estimated_time': 2 / 6,
        'mode_id': 'walking',
        'speed_factor': 6,
      });

      expect(engineResult.path, onlineResult.path);
    });
  });
}

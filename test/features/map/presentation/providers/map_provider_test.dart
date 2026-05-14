import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/features/map/data/models/map_poi.dart';
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
}

MapPoi _poi({
  required int id,
  required String code,
  required String name,
  required String type,
}) {
  return MapPoi(
    poiId: id,
    mapId: 1,
    poiCode: code,
    poiName: name,
    poiType: type,
    gridRow: id,
    gridCol: id,
    gridLocation: id,
    isLandmark: false,
    isAccessible: true,
    wheelchairAccessible: false,
  );
}

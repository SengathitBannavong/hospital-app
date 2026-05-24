import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/features/map/data/models/map_edge.dart';
import 'package:hospital_app/features/map/data/models/map_floor.dart';
import 'package:hospital_app/features/map/data/models/map_poi.dart';
import 'package:hospital_app/features/map/presentation/pages/map_page.dart';
import 'package:hospital_app/features/map/presentation/providers/map_provider.dart';

void main() {
  testWidgets('renders map canvas before map data providers complete', (
    tester,
  ) async {
    final slowFloors = Completer<List<MapFloor>>();
    final slowMeta = Completer<MapFloor>();
    final slowNodes = Completer<List<MapPoi>>();
    final slowEdges = Completer<List<MapEdge>>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          floorsProvider.overrideWith((ref) => slowFloors.future),
          mapMetaProvider.overrideWith((ref, mapId) => slowMeta.future),
          mapNodesProvider.overrideWith((ref, mapId) => slowNodes.future),
          mapEdgesProvider.overrideWith((ref, mapId) => slowEdges.future),
          mapConnectivityProvider.overrideWith((ref) async* {
            yield false;
          }),
          mapLastSyncedAtProvider.overrideWith((ref, mapId) async => null),
        ],
        child: const MaterialApp(home: MapPage()),
      ),
    );

    expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
  });

  testWidgets('defers edge provider until after first paint', (tester) async {
    var edgeReads = 0;
    final slowEdges = Completer<List<MapEdge>>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          floorsProvider.overrideWith(
            (ref) async => const [
              MapFloor(mapId: 1, mapName: 'Floor 1', rows: 33, cols: 57),
            ],
          ),
          mapMetaProvider.overrideWith(
            (ref, mapId) async => const MapFloor(
              mapId: 1,
              mapName: 'Floor 1',
              rows: 33,
              cols: 57,
            ),
          ),
          mapNodesProvider.overrideWith((ref, mapId) async => const <MapPoi>[]),
          mapEdgesProvider.overrideWith((ref, mapId) {
            edgeReads++;
            return slowEdges.future;
          }),
          mapConnectivityProvider.overrideWith((ref) async* {
            yield false;
          }),
          mapLastSyncedAtProvider.overrideWith((ref, mapId) async => null),
        ],
        child: const MaterialApp(home: MapPage()),
      ),
    );

    expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
    expect(edgeReads, 0);

    await tester.pump(const Duration(milliseconds: 75));

    expect(edgeReads, 1);
  });
}

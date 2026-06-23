import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/l10n/app_localizations.dart';
import 'package:hospital_app/features/map/data/map_repository.dart';
import 'package:hospital_app/features/map/data/models/map_edge.dart';
import 'package:hospital_app/features/map/data/models/map_floor.dart';
import 'package:hospital_app/features/map/data/models/map_poi.dart';
import 'package:hospital_app/features/map/data/models/route_clear_history.dart';
import 'package:hospital_app/features/map/data/models/route_history.dart';
import 'package:hospital_app/features/map/data/models/route_history_entry.dart';
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
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MapPage(),
        ),
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
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MapPage(),
        ),
      ),
    );

    expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
    expect(edgeReads, 0);

    await tester.pump(const Duration(milliseconds: 75));
    await tester.pump();

    expect(edgeReads, 1);
  });

  testWidgets('history FAB opens the route history sheet', (tester) async {
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
          mapEdgesProvider.overrideWith(
            (ref, mapId) async => const <MapEdge>[],
          ),
          mapConnectivityProvider.overrideWith((ref) async* {
            yield false;
          }),
          mapLastSyncedAtProvider.overrideWith((ref, mapId) async => null),
          routeHistoryProvider.overrideWith(
            (ref) async => const RouteHistory(routes: []),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(useMaterial3: false),
          home: const MapPage(),
        ),
      ),
    );

    await tester.pump();
    // Open the new expandable map action menu, then tap the history action.
    await tester.tap(find.byIcon(Icons.menu_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.history_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Route history'), findsOneWidget);
    expect(find.text('No completed routes yet'), findsOneWidget);
  });

  testWidgets('route history sheet displays at most 15 rows', (tester) async {
    final routes = List<RouteHistoryEntry>.generate(
      18,
      (index) => RouteHistoryEntry(
        id: 'r$index',
        destinationName: 'Destination $index',
        destLocation: index,
      ),
    );

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
          mapEdgesProvider.overrideWith(
            (ref, mapId) async => const <MapEdge>[],
          ),
          mapConnectivityProvider.overrideWith((ref) async* {
            yield false;
          }),
          mapLastSyncedAtProvider.overrideWith((ref, mapId) async => null),
          routeHistoryProvider.overrideWith(
            (ref) async => RouteHistory(routes: routes),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(useMaterial3: false),
          home: const MapPage(),
        ),
      ),
    );

    await tester.pump();
    await tester.tap(find.byIcon(Icons.menu_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.history_rounded));
    await tester.pumpAndSettle();

    final listView = tester.widget<ListView>(find.byType(ListView));
    expect(listView.childrenDelegate.estimatedChildCount, 29);
  });

  testWidgets(
    'route history rate action appears only with route id and opens rate page',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (_, _) => const MapPage()),
          GoRoute(
            path: '/route/rate/:route_id',
            builder: (_, state) => Scaffold(
              body: Text('rating ${state.pathParameters['route_id']}'),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);

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
            mapNodesProvider.overrideWith(
              (ref, mapId) async => const <MapPoi>[],
            ),
            mapEdgesProvider.overrideWith(
              (ref, mapId) async => const <MapEdge>[],
            ),
            mapConnectivityProvider.overrideWith((ref) async* {
              yield false;
            }),
            mapLastSyncedAtProvider.overrideWith((ref, mapId) async => null),
            routeHistoryProvider.overrideWith(
              (ref) async => const RouteHistory(
                routes: [
                  RouteHistoryEntry(
                    id: 'history-1',
                    routeId: 'server-route-1',
                    destinationName: 'Radiology',
                    destLocation: 12,
                  ),
                  RouteHistoryEntry(
                    id: 'history-2',
                    destinationName: 'Pharmacy',
                    destLocation: 14,
                  ),
                ],
              ),
            ),
          ],
          child: MaterialApp.router(
            locale: const Locale('vi'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData(useMaterial3: false),
            routerConfig: router,
          ),
        ),
      );

      await tester.pump();
      await tester.tap(find.byIcon(Icons.menu_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.history_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Radiology'), findsOneWidget);
      expect(find.text('Pharmacy'), findsOneWidget);
      expect(find.byTooltip('Đánh giá tuyến'), findsOneWidget);

      await tester.tap(find.byTooltip('Đánh giá tuyến'));
      await tester.pumpAndSettle();

      expect(find.text('rating server-route-1'), findsOneWidget);
      expect(find.text('Route history'), findsNothing);
    },
  );

  testWidgets('route history clear all calls repository and closes sheet', (
    tester,
  ) async {
    final repository = _FakeHistoryRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mapRepositoryProvider.overrideWithValue(repository),
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
          mapEdgesProvider.overrideWith(
            (ref, mapId) async => const <MapEdge>[],
          ),
          mapConnectivityProvider.overrideWith((ref) async* {
            yield false;
          }),
          mapLastSyncedAtProvider.overrideWith((ref, mapId) async => null),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(useMaterial3: false),
          home: const MapPage(),
        ),
      ),
    );


    await tester.pump();
    await tester.tap(find.byIcon(Icons.menu_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.history_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Route history'), findsOneWidget);
    await tester.tap(find.text('Clear all'));
    await tester.pumpAndSettle();

    expect(repository.clearCalls, 1);
    expect(find.text('Route history'), findsNothing);
    expect(
      find.byWidgetPredicate((widget) =>
          widget is Text &&
          (widget.data == 'Route history cleared' ||
              widget.data == 'Đã xóa lịch sử lộ trình')),
      findsOneWidget,
    );
  });
}

class _FakeHistoryRepository extends MapRepository {
  int clearCalls = 0;

  @override
  Future<RouteHistory> getRouteHistory({int limit = 15, int page = 1}) async {
    return const RouteHistory(
      routes: [
        RouteHistoryEntry(
          id: 'r1',
          destinationName: 'Radiology',
          destLocation: 12,
        ),
      ],
    );
  }

  @override
  Future<RouteClearHistory> clearRouteHistory() async {
    clearCalls++;
    return const RouteClearHistory(cleared: true);
  }
}

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/features/map/data/map_repository.dart';
import 'package:hospital_app/features/map/data/models/nav_state.dart';
import 'package:hospital_app/features/map/data/services/map_cache_service.dart';
import 'package:hospital_app/features/map/presentation/navigation/voice_service.dart';
import 'package:hospital_app/features/map/presentation/providers/map_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NavigationController route lifecycle', () {
    for (final entry in <({String name, dynamic body, String id})>[
      // Real backend shape (unwrapped): data.route.route_id.
      (
        name: 'route.route_id',
        body: {
          'route': {'route_id': 'route-001'},
          'paths': <dynamic>[],
        },
        id: 'route-001',
      ),
      (name: 'route_id', body: {'route_id': 'r-1'}, id: 'r-1'),
      (name: 'id', body: {'id': 42}, id: '42'),
      (
        name: 'data.route_id',
        body: {
          'data': {'route_id': 'nested-1'},
        },
        id: 'nested-1',
      ),
      (
        name: 'data.id',
        body: {
          'data': {'id': 77},
        },
        id: '77',
      ),
    ]) {
      test('start stores ${entry.name} and stop cancels it', () async {
        final repository = _LifecycleRepository(orderBody: entry.body);
        final container = _container(repository);
        addTearDown(container.dispose);

        final controller = container.read(navigationControllerProvider);

        expect(controller.start(), isTrue);
        await Future<void>.delayed(Duration.zero);
        controller.stop();
        await Future<void>.delayed(Duration.zero);

        expect(repository.orderCalls, 1);
        expect(repository.orderStartLocation, 10);
        expect(repository.orderDestLocation, 12);
        expect(repository.orderModeId, 'wheelchair');
        expect(repository.cancelledRouteIds, [entry.id]);
      });
    }

    test('stop does not cancel when order has no route id', () async {
      final repository = _LifecycleRepository(orderBody: {'status': 'ok'});
      final container = _container(repository);
      addTearDown(container.dispose);

      final controller = container.read(navigationControllerProvider);

      expect(controller.start(), isTrue);
      await Future<void>.delayed(Duration.zero);
      controller.stop();
      await Future<void>.delayed(Duration.zero);

      expect(repository.orderCalls, 1);
      expect(repository.cancelledRouteIds, isEmpty);
    });

    test(
      'stop before order resolves does not store a stale route id',
      () async {
        final orderCompleter = Completer<dynamic>();
        final repository = _LifecycleRepository(
          onOrder: () => orderCompleter.future,
        );
        final container = _container(repository);
        addTearDown(container.dispose);

        final controller = container.read(navigationControllerProvider);

        expect(controller.start(), isTrue);
        controller.stop();
        orderCompleter.complete({'route_id': 'late-id'});
        await Future<void>.delayed(Duration.zero);
        controller.stop();
        await Future<void>.delayed(Duration.zero);

        expect(repository.orderCalls, 1);
        expect(repository.cancelledRouteIds, isEmpty);
      },
    );

    testWidgets(
      'arrival forgets the route id so completion stop does not cancel',
      (tester) async {
        final repository = _LifecycleRepository(orderBody: {'route_id': 'r-1'});
        final container = _container(repository);

        // Pin the autoDispose controller (and routeResultProvider, read by
        // _setProgress) for the whole test so long pumps don't dispose them and
        // leave a pending autoDispose Timer under fakeAsync.
        final sub = container.listen(navigationControllerProvider, (_, _) {});
        container.listen(routeResultProvider, (_, _) {});
        final controller = sub.read();

        expect(controller.start(), isTrue);
        // Resolve the async order so a route_id is actually captured before
        // arrival — otherwise the test wouldn't prove arrival clears it.
        await tester.pump();
        expect(repository.orderCalls, 1);

        // Drive the simulated dot to the destination (2 cells at 4*0.5 = 2
        // cells/s => ~1s). First tick is ignored; the next covers the path.
        await tester.pump(const Duration(milliseconds: 1));
        await tester.pump(const Duration(seconds: 2));
        expect(container.read(navPhaseProvider), NavPhase.arrived);

        // The completion path (_completeRoute) calls stop(); a finished route
        // must NOT be cancelled.
        controller.stop();
        await tester.pump();

        expect(repository.cancelledRouteIds, isEmpty);

        // Intentionally leave the listeners open and the container undisposed:
        // closing a listener or disposing would make Riverpod's autoDispose
        // scheduler create a Timer that lingers past fakeAsync's pending-timer
        // check. Keeping everything pinned means no disposal is scheduled.
      },
    );

    test('start returns false and does not order without a path', () async {
      final repository = _LifecycleRepository(orderBody: {'route_id': 'r-1'});
      final container = _container(repository, path: const [10]);
      addTearDown(container.dispose);

      final controller = container.read(navigationControllerProvider);

      expect(controller.start(), isFalse);
      await Future<void>.delayed(Duration.zero);

      expect(repository.orderCalls, 0);
      expect(repository.cancelledRouteIds, isEmpty);
      expect(container.read(navPhaseProvider), NavPhase.idle);
    });
  });

  group('NavigationController pass_node reporting', () {
    testWidgets('reports the changing position while navigating', (
      tester,
    ) async {
      final repository = _LifecycleRepository(orderBody: {'route_id': 'r-1'});
      final container = _container(
        repository,
        path: const [10, 11, 12, 13, 14, 15, 16, 17, 18, 19],
      );
      // Pin autoDispose providers so long pumps don't schedule a dispose Timer.
      final sub = container.listen(navigationControllerProvider, (_, _) {});
      container.listen(routeResultProvider, (_, _) {});
      final controller = sub.read();
      container.read(navSpeedProvider.notifier).state = 0.25; // ~1 cell/s

      expect(controller.start(), isTrue);
      await tester.pump(); // resolve the async order -> route_id captured
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 2));

      expect(repository.passNodeCalls, isNotEmpty);
      expect(repository.passNodeCalls.every((c) => c.routeId == 'r-1'), isTrue);
      final locations = repository.passNodeCalls
          .map((c) => c.gridLocation)
          .toList();
      expect(locations.every((l) => l >= 10 && l <= 19), isTrue);
      // The dot moved across cells, so more than one distinct cell is reported.
      expect(locations.toSet().length, greaterThanOrEqualTo(2));

      controller.stop(); // cancels the periodic timer (no pending timer)
      await tester.pump();
    });

    testWidgets('dedupes an unchanged cell and stops after stop()', (
      tester,
    ) async {
      final repository = _LifecycleRepository(orderBody: {'route_id': 'r-1'});
      final container = _container(repository);
      final sub = container.listen(navigationControllerProvider, (_, _) {});
      container.listen(routeResultProvider, (_, _) {});
      final controller = sub.read();
      container.read(navSpeedProvider.notifier).state = 0.0; // stationary @ 10

      expect(controller.start(), isTrue);
      await tester.pump(); // resolve order
      await tester.pump(const Duration(seconds: 6)); // 3 ticks, same cell

      expect(repository.passNodeCalls, hasLength(1));
      expect(repository.passNodeCalls.single.routeId, 'r-1');
      expect(repository.passNodeCalls.single.gridLocation, 10);

      controller.stop();
      await tester.pump(const Duration(seconds: 6)); // timer cancelled
      expect(repository.passNodeCalls, hasLength(1));
    });

    testWidgets('does not report when order returns no route_id', (
      tester,
    ) async {
      final repository = _LifecycleRepository(orderBody: {'status': 'ok'});
      final container = _container(repository);
      final sub = container.listen(navigationControllerProvider, (_, _) {});
      container.listen(routeResultProvider, (_, _) {});
      final controller = sub.read();
      container.read(navSpeedProvider.notifier).state = 0.0;

      expect(controller.start(), isTrue);
      await tester.pump();
      await tester.pump(const Duration(seconds: 6));

      expect(repository.passNodeCalls, isEmpty);

      controller.stop();
      await tester.pump();
    });
  });
}

ProviderContainer _container(
  _LifecycleRepository repository, {
  List<int> path = const [10, 11, 12],
}) {
  return ProviderContainer(
    overrides: [
      mapRepositoryProvider.overrideWithValue(repository),
      mapCacheProvider.overrideWithValue(_NoopMapCacheService()),
      routeLocationsProvider.overrideWith((ref) => path),
      routeModeProvider.overrideWith((ref) => 'wheelchair'),
      voiceServiceProvider.overrideWith((ref) => _NoopVoiceService()),
      // Trivial route result so _setProgress doesn't kick off real route
      // computation; pinned in the ticker-driven test to avoid an autoDispose
      // disposal Timer under fakeAsync.
      routeResultProvider.overrideWith((ref) => null),
    ],
  );
}

class _LifecycleRepository extends MapRepository {
  _LifecycleRepository({this.orderBody, this.onOrder});

  final dynamic orderBody;
  final Future<dynamic> Function()? onOrder;
  int orderCalls = 0;
  int? orderStartLocation;
  int? orderDestLocation;
  String? orderModeId;
  final List<String> cancelledRouteIds = [];
  final List<({String routeId, int gridLocation})> passNodeCalls = [];

  @override
  Future<dynamic> orderRoute({
    required int startLocation,
    required int destLocation,
    required String modeId,
  }) async {
    orderCalls++;
    orderStartLocation = startLocation;
    orderDestLocation = destLocation;
    orderModeId = modeId;
    if (onOrder != null) {
      return onOrder!();
    }
    return orderBody;
  }

  @override
  Future<void> cancelRoute({required String routeId}) async {
    cancelledRouteIds.add(routeId);
  }

  @override
  Future<void> passNode({
    required String routeId,
    required int gridLocation,
  }) async {
    passNodeCalls.add((routeId: routeId, gridLocation: gridLocation));
  }
}

class _NoopVoiceService extends VoiceService {
  _NoopVoiceService()
    : super(
        player: CuePlayer(
          tts: _NoopTtsSpeaker(),
          clipPlayer: _NoopClipPlayer(),
        ),
      );
}

class _NoopMapCacheService extends MapCacheService {
  @override
  Future<bool> getVoiceMuted() async => false;
}

class _NoopTtsSpeaker implements TtsSpeaker {
  @override
  Future<void> speak(String text) async {}

  @override
  Future<void> stop() async {}
}

class _NoopClipPlayer implements LocalClipPlayer {
  @override
  Future<void> dispose() async {}

  @override
  Future<void> playAsset(String assetPath) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> unlockForWeb() async {}
}

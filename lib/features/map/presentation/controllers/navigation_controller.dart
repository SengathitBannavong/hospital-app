import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/features/map/data/models/nav_state.dart';
import 'package:hospital_app/features/map/data/models/route_result.dart';
import 'package:hospital_app/features/map/presentation/navigation/position_source.dart';
import 'package:hospital_app/features/map/presentation/navigation/step_tracker.dart';
import 'package:hospital_app/features/map/presentation/navigation/voice_service.dart';
import 'package:hospital_app/features/map/presentation/providers/map_provider.dart';

class NavDot {
  final int fromLocation;
  final int toLocation;
  final double t;

  const NavDot({
    required this.fromLocation,
    required this.toLocation,
    required this.t,
  });

  const NavDot.resting(int location)
    : fromLocation = location,
      toLocation = location,
      t = 0;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is NavDot &&
            other.fromLocation == fromLocation &&
            other.toLocation == toLocation &&
            other.t == t;
  }

  @override
  int get hashCode => Object.hash(fromLocation, toLocation, t);
}

/// Master switch for pass_node position reporting. While positions are
/// simulated this uploads the simulated trail; flip to `false` to silence it
/// (e.g. for production analytics) until real positioning lands. The pipeline
/// reads from [navCurrentLocationProvider], so swapping simulated -> real needs
/// no change here.
const bool kReportPassNode = true;

/// How often pass_node samples the current position while navigating.
const Duration kPassNodeInterval = Duration(seconds: 2);

class NavigationController {
  final Ref _ref;
  final VoiceService _voice;
  final StepTracker _stepTracker;
  late final Ticker _ticker;
  Duration? _lastElapsed;
  List<int> _path = const <int>[];
  double _travelled = 0;
  double _totalLength = 0;
  String _modeId = 'walking';
  double? _etaSeconds;
  String? _serverRouteId;
  int _routeOrderGeneration = 0;
  Timer? _passNodeTimer;
  int? _lastSentLocation;

  NavigationController(
    this._ref, {
    VoiceService? voice,
    StepTracker? stepTracker,
  }) : _voice = voice ?? VoiceService(),
       _stepTracker = stepTracker ?? const StepTracker() {
    _ticker = Ticker(_onTick);
  }

  int? get currentLocationApprox {
    final path = _path;
    if (path.isEmpty) {
      return _ref.read(userPositionProvider);
    }
    final progress = _ref.read(navProgressProvider);
    final index = (progress * (path.length - 1)).round();
    return path[index.clamp(0, path.length - 1)];
  }

  double get metersRemaining {
    return (_totalLength - _travelled).clamp(0.0, double.infinity).toDouble();
  }

  double get secondsRemaining {
    final speed = _speedCellsPerSecond;
    if (speed <= 0) return 0;
    return metersRemaining / speed;
  }

  bool start() {
    final path = _ref.read(routeLocationsProvider);
    final mode = _ref.read(routeModeProvider);
    if (path.length < 2) {
      stop();
      return false;
    }

    _path = List<int>.unmodifiable(path);
    _modeId = mode;
    _travelled = 0;
    _totalLength = (_path.length - 1).toDouble();
    final routeData = _ref.read(routeResultProvider).valueOrNull;
    _etaSeconds = _readEstimatedTime(routeData);
    _lastElapsed = null;
    unawaited(_voice.reset());
    // Enter the navigating phase before the first _setProgress so its cue is
    // allowed through the guard in _setProgress.
    _ref.read(navPhaseProvider.notifier).state = NavPhase.navigating;
    _setProgress(0);
    _ticker
      ..stop()
      ..start();
    _serverRouteId = null;
    final generation = ++_routeOrderGeneration;
    unawaited(_orderActiveRoute(generation));
    _startPassNodeReporting();
    return true;
  }

  void pause() {
    if (_ref.read(navPhaseProvider) != NavPhase.navigating) return;
    _ticker.stop();
    _lastElapsed = null;
    _stopPassNodeReporting();
    unawaited(_voice.pauseSpeaking());
    _ref.read(navPhaseProvider.notifier).state = NavPhase.paused;
  }

  void resume() {
    if (_ref.read(navPhaseProvider) != NavPhase.paused || _path.length < 2) {
      return;
    }
    _lastElapsed = null;
    _ref.read(navPhaseProvider.notifier).state = NavPhase.navigating;
    _ticker.start();
    _startPassNodeReporting();
  }

  void stop() {
    _stopPassNodeReporting();
    final activeId = _serverRouteId;
    _serverRouteId = null;
    _routeOrderGeneration++;
    if (activeId != null) {
      unawaited(
        _ref
            .read(mapRepositoryProvider)
            .cancelRoute(routeId: activeId)
            .catchError((_) {}),
      );
    }
    _ticker.stop();
    _lastElapsed = null;
    _path = const <int>[];
    _travelled = 0;
    _totalLength = 0;
    _etaSeconds = null;
    // Leave the navigating phase before resetting progress so _setProgress
    // stays silent — otherwise it would speak a cue off the now-stale route
    // (e.g. when the destination is changed or the route is cancelled).
    _ref.read(navPhaseProvider.notifier).state = NavPhase.idle;
    _setProgress(0);
    unawaited(_voice.reset());
  }

  void setSpeed(double multiplier) {
    _ref.read(navSpeedProvider.notifier).state = multiplier.clamp(0.25, 4.0);
    _ref.read(navSecondsRemainingProvider.notifier).state = secondsRemaining;
  }

  void dispose() {
    _stopPassNodeReporting();
    _ticker.dispose();
    unawaited(_voice.dispose());
  }

  // ── pass_node position reporting ──
  // Samples the current grid location every [kPassNodeInterval] while
  // navigating and reports it to the backend, deduped so an unchanged cell is
  // not resent. Best-effort: skipped when reporting is disabled, no active
  // server route_id exists yet, or the position has not changed. Failures
  // (including offline) are dropped — stale positions are never queued.
  void _startPassNodeReporting() {
    _stopPassNodeReporting();
    if (!kReportPassNode) return;
    _lastSentLocation = null;
    _passNodeTimer = Timer.periodic(
      kPassNodeInterval,
      (_) => _reportPassNode(),
    );
  }

  void _stopPassNodeReporting() {
    _passNodeTimer?.cancel();
    _passNodeTimer = null;
    _lastSentLocation = null;
  }

  void _reportPassNode() {
    final routeId = _serverRouteId;
    if (routeId == null) return; // order not resolved yet / offline at start
    final location = _ref.read(navCurrentLocationProvider);
    if (location == null || location == _lastSentLocation) return;
    _lastSentLocation = location;
    unawaited(
      _ref
          .read(mapRepositoryProvider)
          .passNode(routeId: routeId, gridLocation: location)
          .then((_) => debugPrint('[pass_node] ok ($routeId @ $location)'))
          .catchError(
            (Object e) => debugPrint('[pass_node] FAILED ($location): $e'),
          ),
    );
  }

  void _onTick(Duration elapsed) {
    final last = _lastElapsed;
    _lastElapsed = elapsed;
    if (last == null) return;

    final dt = (elapsed - last).inMicroseconds / Duration.microsecondsPerSecond;
    if (dt <= 0) return;

    _travelled += _speedCellsPerSecond * dt;
    final progress = (_travelled / _totalLength).clamp(0.0, 1.0).toDouble();
    _setProgress(progress);

    if (progress >= 1) {
      _ticker.stop();
      _lastElapsed = null;
      _travelled = _totalLength;
      _stopPassNodeReporting();
      // Route completed — forget the server route_id WITHOUT cancelling, and
      // invalidate any still-in-flight order. The completion stop() (via
      // _completeRoute) must NOT cancel a finished route; only an abandonment
      // (manual stop / clear / destination change) should cancel.
      _serverRouteId = null;
      _routeOrderGeneration++;
      // Announce arrival once and let the clip play out. Do NOT reset()/stop()
      // here — that would cut the clip off the instant it starts. The decider
      // is reset by the next start().
      final muted = _ref.read(voiceMutedProvider);
      unawaited(_voice.speakArrived(muted: muted));
      _ref.read(navPhaseProvider.notifier).state = NavPhase.arrived;
    }
  }

  void _setProgress(double progress) {
    _ref.read(navProgressProvider.notifier).state = progress;
    final currentLocation = currentLocationApprox;
    _ref.read(navCurrentLocationProvider.notifier).state = currentLocation;
    _ref.read(navMetersRemainingProvider.notifier).state = metersRemaining;
    _ref.read(navSecondsRemainingProvider.notifier).state = secondsRemaining;
    final routeResult = _ref.read(routeResultProvider).valueOrNull;
    final state = _stepTracker.track(
      position: SimulatedPositionSource(
        currentLocation: currentLocation,
        progress: progress,
      ),
      routeResult: routeResult,
    );
    // Only speak while actively navigating. start()/stop() also call
    // _setProgress to reset the progress providers, and those must not emit
    // cues — otherwise selecting/changing a destination would trigger voice.
    if (_ref.read(navPhaseProvider) == NavPhase.navigating) {
      unawaited(
        _voice.speakFor(state: state, muted: _ref.read(voiceMutedProvider)),
      );
    }
  }

  double get _speedCellsPerSecond {
    final mult = _ref.read(navSpeedProvider);
    final eta = _etaSeconds;
    // Match the backend ETA: cover the whole path in `eta` seconds at base
    // speed so the dot's travel time equals the displayed estimate. Fall back
    // to the mode speed table when ETA is missing (e.g. offline).
    if (eta != null && eta > 0 && _totalLength > 0) {
      return (_totalLength / eta) * mult;
    }
    return baseSpeedFor(_modeId) * mult;
  }

  double? _readEstimatedTime(RouteResult? data) {
    if (data == null) return null;
    final value = data.estimatedTime;
    return value > 0 ? value : null;
  }

  Future<void> _orderActiveRoute(int generation) async {
    final path = _path;
    if (path.length < 2) return;
    try {
      final response = await _ref
          .read(mapRepositoryProvider)
          .orderRoute(
            startLocation: path.first,
            destLocation: path.last,
            modeId: _modeId,
          );
      // A stop()/restart between firing and resolving supersedes this order.
      if (generation != _routeOrderGeneration) return;
      _serverRouteId = _extractRouteId(response);
    } catch (_) {
      // Offline / failed order -> no active route_id; cancel/etc. no-op.
    }
  }

  /// Pulls the route_id out of an order/get_active payload.
  ///
  /// Real backend shape (already unwrapped from the {code,message,data}
  /// envelope by MapRepository): `data.route.route_id`, i.e. here
  /// `body['route']['route_id']`. The other lookups are defensive fallbacks for
  /// flatter/double-wrapped shapes so a contract tweak doesn't silently break.
  String? _extractRouteId(dynamic body) {
    if (body is! Map) return null;
    final id =
        _routeIdFrom(body['route']) ?? // data.route.route_id (real shape)
        body['route_id'] ??
        body['id'] ??
        _routeIdFrom(body['data']) ?? // double-wrapped: data.route_id/id
        _routeIdFrom((body['data'] is Map) ? body['data']['route'] : null);
    return id?.toString();
  }

  Object? _routeIdFrom(dynamic node) {
    if (node is Map) return node['route_id'] ?? node['id'];
    return null;
  }
}

double baseSpeedFor(String modeId) {
  return switch (modeId) {
    'wheelchair' => 4,
    'stretcher' => 3,
    'hospital_cart' => 3,
    _ => 6,
  };
}

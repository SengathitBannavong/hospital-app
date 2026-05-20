import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/features/map/data/models/nav_state.dart';
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

class NavigationController {
  final Ref _ref;
  late final Ticker _ticker;
  Duration? _lastElapsed;
  List<int> _path = const <int>[];
  double _travelled = 0;
  double _totalLength = 0;
  String _modeId = 'walking';
  double? _etaSeconds;

  NavigationController(this._ref) {
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
    _setProgress(0);
    _ref.read(navPhaseProvider.notifier).state = NavPhase.navigating;
    _ticker
      ..stop()
      ..start();
    return true;
  }

  void pause() {
    if (_ref.read(navPhaseProvider) != NavPhase.navigating) return;
    _ticker.stop();
    _lastElapsed = null;
    _ref.read(navPhaseProvider.notifier).state = NavPhase.paused;
  }

  void resume() {
    if (_ref.read(navPhaseProvider) != NavPhase.paused || _path.length < 2) {
      return;
    }
    _lastElapsed = null;
    _ref.read(navPhaseProvider.notifier).state = NavPhase.navigating;
    _ticker.start();
  }

  void stop() {
    _ticker.stop();
    _lastElapsed = null;
    _path = const <int>[];
    _travelled = 0;
    _totalLength = 0;
    _etaSeconds = null;
    _setProgress(0);
    _ref.read(navPhaseProvider.notifier).state = NavPhase.idle;
  }

  void setSpeed(double multiplier) {
    _ref.read(navSpeedProvider.notifier).state = multiplier.clamp(0.25, 4.0);
    _ref.read(navSecondsRemainingProvider.notifier).state = secondsRemaining;
  }

  void dispose() {
    _ticker.dispose();
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
      _ref.read(navPhaseProvider.notifier).state = NavPhase.arrived;
    }
  }

  void _setProgress(double progress) {
    _ref.read(navProgressProvider.notifier).state = progress;
    _ref.read(navCurrentLocationProvider.notifier).state =
        currentLocationApprox;
    _ref.read(navMetersRemainingProvider.notifier).state = metersRemaining;
    _ref.read(navSecondsRemainingProvider.notifier).state = secondsRemaining;
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

  double? _readEstimatedTime(dynamic data) {
    if (data is! Map) return null;
    final value = data['estimated_time'];
    return value is num && value > 0 ? value.toDouble() : null;
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

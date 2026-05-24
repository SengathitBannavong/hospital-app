abstract class PositionSource {
  int? get currentLocation;
  double get progress;
}

class SimulatedPositionSource implements PositionSource {
  @override
  final int? currentLocation;

  @override
  final double progress;

  const SimulatedPositionSource({
    required this.currentLocation,
    required this.progress,
  });
}

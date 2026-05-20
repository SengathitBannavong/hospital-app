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

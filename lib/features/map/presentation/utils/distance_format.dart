/// Real-world conversion for the abstract grid the map is built on.
///
/// Distances produced by the backend `route/preview` and the offline
/// `RoutingEngine` are **grid-cell counts** (Chebyshev cell distance), not
/// meters. The backend does not yet publish a per-map meters-per-cell ratio, so
/// this is the single tunable assumption the whole UI shares: one grid cell is
/// estimated at ~1 m (a hospital floor of 33×57 cells maps to roughly 30×57 m).
///
/// When the backend confirms the real ratio, change this one constant (or feed
/// a per-floor value in here) and every distance label updates consistently.
const double kMetersPerCell = 1.0;

/// Converts a grid-cell distance into meters using [kMetersPerCell].
double cellsToMeters(num cells) => cells.toDouble() * kMetersPerCell;

/// Formats a grid-cell distance as a human-readable real-world distance.
String formatDistanceFromCells(num cells) {
  final meters = cellsToMeters(cells);
  if (meters >= 1000) {
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }
  return '${meters.toStringAsFixed(0)} m';
}

/// Formats a grid-cell distance with full words, for text-to-speech.
String spokenDistanceFromCells(num cells) {
  final meters = cellsToMeters(cells);
  if (meters >= 1000) {
    return '${(meters / 1000).toStringAsFixed(1)} kilometers';
  }
  return '${meters.toStringAsFixed(0)} meters';
}

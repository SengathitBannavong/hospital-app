import 'dart:math' as math;

class RouteStep {
  final int location;
  final String maneuver;
  final double distance;

  const RouteStep({
    required this.location,
    required this.maneuver,
    required this.distance,
  });

  Map<String, dynamic> toJson(int order) {
    return {
      'step_order': order,
      'grid_location': location,
      'location': location,
      'maneuver': maneuver,
      'distance': distance,
    };
  }
}

class RouteResult {
  final List<int> path;
  final List<RouteStep> steps;
  final double distance;
  final double estimatedTime;
  final String modeId;
  final double speedFactor;

  const RouteResult({
    required this.path,
    required this.steps,
    required this.distance,
    required this.estimatedTime,
    required this.modeId,
    required this.speedFactor,
  });

  Map<String, dynamic> toPreviewJson() {
    return {
      'path': path,
      'steps': [
        for (var i = 0; i < steps.length; i++) steps[i].toJson(i + 1),
      ],
      'distance': distance,
      'estimated_time': estimatedTime,
      'mode_id': modeId,
      'speed_factor': speedFactor,
      'source': 'offline',
    };
  }
}

class EdgeStatus {
  final int fromLocation;
  final int toLocation;
  final double congestion;
  final bool blocked;

  const EdgeStatus({
    required this.fromLocation,
    required this.toLocation,
    this.congestion = 0,
    this.blocked = false,
  });
}

class RoutingEngine {
  RouteResult route({
    required int startLocation,
    required int destLocation,
    required String modeId,
    required Map<int, List<int>> adjacency,
    required int cols,
    Map<String, EdgeStatus> edgeStatuses = const <String, EdgeStatus>{},
  }) {
    final path = _shortestPath(
      startLocation: startLocation,
      destLocation: destLocation,
      modeId: modeId,
      adjacency: adjacency,
      cols: cols,
      edgeStatuses: edgeStatuses,
    );

    if (path.isEmpty) {
      throw Exception('No offline route found for the selected points.');
    }

    final distance = _pathDistance(path, cols);
    final speedFactor = baseSpeedFor(modeId);
    return RouteResult(
      path: path,
      steps: _buildSteps(path, cols),
      distance: distance,
      estimatedTime: speedFactor <= 0 ? 0 : distance / speedFactor,
      modeId: modeId,
      speedFactor: speedFactor,
    );
  }

  List<int> _shortestPath({
    required int startLocation,
    required int destLocation,
    required String modeId,
    required Map<int, List<int>> adjacency,
    required int cols,
    required Map<String, EdgeStatus> edgeStatuses,
  }) {
    if (startLocation == destLocation) {
      return [startLocation];
    }

    final costs = <int, double>{startLocation: 0};
    final previous = <int, int>{};
    final queue = <_QueueEntry>[
      _QueueEntry(location: startLocation, priority: 0),
    ];

    while (queue.isNotEmpty) {
      queue.sort();
      final current = queue.removeAt(0);
      if (current.priority > (costs[current.location] ?? double.infinity)) {
        continue;
      }
      if (current.location == destLocation) {
        break;
      }

      for (final next in adjacency[current.location] ?? const <int>[]) {
        final edgeStatus = edgeStatuses[_edgeKey(current.location, next)];
        if (edgeStatus?.blocked ?? false) {
          continue;
        }

        final cost = _edgeCost(
          from: current.location,
          to: next,
          cols: cols,
          modeId: modeId,
          congestion: edgeStatus?.congestion ?? 0,
        );
        final nextCost = current.priority + cost;
        if (nextCost >= (costs[next] ?? double.infinity)) {
          continue;
        }

        costs[next] = nextCost;
        previous[next] = current.location;
        queue.add(_QueueEntry(location: next, priority: nextCost));
      }
    }

    if (!previous.containsKey(destLocation)) {
      return const <int>[];
    }

    final path = <int>[destLocation];
    var cursor = destLocation;
    while (cursor != startLocation) {
      cursor = previous[cursor]!;
      path.add(cursor);
    }
    return path.reversed.toList(growable: false);
  }

  double _edgeCost({
    required int from,
    required int to,
    required int cols,
    required String modeId,
    required double congestion,
  }) {
    final penalty = congestion.clamp(0, 1).toDouble();
    return _cellDistance(from, to, cols) * modeCostMultiplier(modeId) *
        (1 + penalty);
  }

  double _pathDistance(List<int> path, int cols) {
    var total = 0.0;
    for (var i = 0; i < path.length - 1; i++) {
      total += _cellDistance(path[i], path[i + 1], cols);
    }
    return total;
  }

  List<RouteStep> _buildSteps(List<int> path, int cols) {
    if (path.isEmpty) {
      return const <RouteStep>[];
    }
    if (path.length == 1) {
      return [
        RouteStep(location: path.first, maneuver: 'arrive', distance: 0),
      ];
    }

    final steps = <RouteStep>[
      RouteStep(location: path.first, maneuver: 'start', distance: 0),
    ];
    for (var i = 1; i < path.length - 1; i++) {
      steps.add(
        RouteStep(
          location: path[i],
          maneuver: _maneuver(path[i - 1], path[i], path[i + 1], cols),
          distance: _cellDistance(path[i], path[i + 1], cols),
        ),
      );
    }
    steps.add(
      RouteStep(location: path.last, maneuver: 'arrive', distance: 0),
    );
    return steps;
  }

  String _maneuver(int previous, int current, int next, int cols) {
    final a = _direction(previous, current, cols);
    final b = _direction(current, next, cols);
    if (a.dx == b.dx && a.dy == b.dy) return 'straight';
    if (a.dx == -b.dx && a.dy == -b.dy) return 'u_turn';
    final cross = a.dx * b.dy - a.dy * b.dx;
    return cross > 0 ? 'right' : 'left';
  }

  _Direction _direction(int from, int to, int cols) {
    final fromRow = from ~/ cols;
    final fromCol = from % cols;
    final toRow = to ~/ cols;
    final toCol = to % cols;
    return _Direction(dx: toCol - fromCol, dy: toRow - fromRow);
  }

  double _cellDistance(int from, int to, int cols) {
    if (cols <= 0) {
      return 1;
    }
    final fromRow = from ~/ cols;
    final fromCol = from % cols;
    final toRow = to ~/ cols;
    final toCol = to % cols;
    final distance = math
        .max((fromRow - toRow).abs(), (fromCol - toCol).abs())
        .toDouble();
    return distance < 1 ? 1 : distance;
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

double modeCostMultiplier(String modeId) {
  return switch (modeId) {
    'wheelchair' => 1.15,
    'stretcher' => 1.35,
    'hospital_cart' => 1.2,
    _ => 1,
  };
}

String edgeStatusKey(int fromLocation, int toLocation) {
  return _edgeKey(fromLocation, toLocation);
}

String _edgeKey(int a, int b) {
  final low = math.min(a, b);
  final high = math.max(a, b);
  return '$low:$high';
}

class _QueueEntry implements Comparable<_QueueEntry> {
  final int location;
  final double priority;

  const _QueueEntry({required this.location, required this.priority});

  @override
  int compareTo(_QueueEntry other) {
    return priority.compareTo(other.priority);
  }
}

class _Direction {
  final int dx;
  final int dy;

  const _Direction({required this.dx, required this.dy});
}

import 'package:hospital_app/features/map/data/models/route_result.dart';
import 'package:hospital_app/features/map/data/models/route_step.dart';
import 'package:hospital_app/features/map/data/services/route_modes.dart';

class RouteResultMapper {
  const RouteResultMapper();

  RouteResult fromPreviewJson(dynamic data) {
    if (data is! Map) {
      return _empty();
    }

    final json = Map<Object?, Object?>.from(data);
    final modeId = _readString(json['mode_id']) ?? 'walking';
    final speedFactor =
        _readDouble(json['speed_factor']) ?? baseSpeedFor(modeId);
    final path = _readPath(json);
    final distance = _readDouble(json['distance']) ?? _pathDistance(path);
    final estimatedTime =
        _readDouble(json['estimated_time']) ??
        (speedFactor <= 0 ? 0 : distance / speedFactor);

    return RouteResult(
      path: path,
      steps: _readSteps(data['steps'], path),
      distance: distance,
      estimatedTime: estimatedTime,
      modeId: modeId,
      speedFactor: speedFactor,
    );
  }

  RouteResult _empty() {
    const modeId = 'walking';
    final speedFactor = baseSpeedFor(modeId);
    return RouteResult(
      path: const <int>[],
      steps: const <RouteStep>[],
      distance: 0,
      estimatedTime: 0,
      modeId: modeId,
      speedFactor: speedFactor,
    );
  }

  List<int> _readPath(Map<Object?, Object?> data) {
    final steps = data['steps'];
    if (steps is List) {
      final stepPath = _locationsFromSteps(steps);
      if (stepPath.isNotEmpty) {
        return stepPath;
      }
    }

    const keys = ['path', 'path_locations', 'locations', 'nodes'];
    for (final key in keys) {
      final value = data[key];
      if (value is List) {
        final path = _readLocationsList(value);
        if (path.isNotEmpty) {
          return path;
        }
      }
    }

    return const <int>[];
  }

  List<RouteStep> _readSteps(Object? raw, List<int> path) {
    if (raw is! List) {
      return _stepsFromPath(path);
    }

    final records = raw.whereType<Map>().toList()
      ..sort((a, b) {
        final aOrder = a['step_order'];
        final bOrder = b['step_order'];
        if (aOrder is num && bOrder is num) {
          return aOrder.compareTo(bOrder);
        }
        return 0;
      });

    final steps = <RouteStep>[];
    for (var i = 0; i < records.length; i++) {
      final record = records[i];
      final location = _readInt(record['location'] ?? record['grid_location']);
      if (location == null) {
        continue;
      }
      steps.add(
        RouteStep(
          location: location,
          maneuver:
              _readManeuver(record['maneuver']) ??
              _defaultManeuver(i, records.length),
          instruction: _readString(record['instruction']),
          distance: _readDouble(record['distance']) ?? 0,
        ),
      );
    }

    return steps.isEmpty ? _stepsFromPath(path) : steps;
  }

  List<int> _locationsFromSteps(List<Object?> raw) {
    final steps = raw.whereType<Map>().toList()
      ..sort((a, b) {
        final aOrder = a['step_order'];
        final bOrder = b['step_order'];
        if (aOrder is num && bOrder is num) {
          return aOrder.compareTo(bOrder);
        }
        return 0;
      });
    return _readLocationsList(steps);
  }

  List<int> _readLocationsList(List<Object?> raw) {
    final locations = <int>[];
    for (final item in raw) {
      if (item is int) {
        locations.add(item);
      } else if (item is num) {
        locations.add(item.toInt());
      } else if (item is Map) {
        final location = _readInt(item['location'] ?? item['grid_location']);
        if (location != null) {
          locations.add(location);
        }
      }
    }
    return locations;
  }

  List<RouteStep> _stepsFromPath(List<int> path) {
    return [
      for (var i = 0; i < path.length; i++)
        RouteStep(
          location: path[i],
          maneuver: _defaultManeuver(i, path.length),
          distance: 0,
        ),
    ];
  }

  double _pathDistance(List<int> path) {
    if (path.length < 2) {
      return 0;
    }
    return (path.length - 1).toDouble();
  }

  StepManeuver _defaultManeuver(int index, int length) {
    if (index == 0) {
      return StepManeuver.start;
    }
    if (index == length - 1) {
      return StepManeuver.arrive;
    }
    return StepManeuver.straight;
  }

  StepManeuver? _readManeuver(Object? value) {
    final raw = _readString(value);
    if (raw == null) {
      return null;
    }
    return switch (raw) {
      'start' => StepManeuver.start,
      'straight' => StepManeuver.straight,
      'left' => StepManeuver.left,
      'right' => StepManeuver.right,
      'u_turn' || 'uTurn' => StepManeuver.uTurn,
      'floor_change' || 'floorChange' => StepManeuver.floorChange,
      'arrive' => StepManeuver.arrive,
      _ => null,
    };
  }

  String? _readString(Object? value) {
    return value is String && value.isNotEmpty ? value : null;
  }

  int? _readInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return null;
  }

  double? _readDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return null;
  }
}

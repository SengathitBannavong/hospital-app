import 'package:hospital_app/features/map/data/models/edge_status.dart';
import 'package:hospital_app/features/map/data/models/flow_alert.dart';
import 'package:hospital_app/features/map/data/models/flow_cell.dart';

class FlowSnapshot {
  final List<FlowCell> cells;
  final List<EdgeStatus> edgeStatuses;
  final List<FlowAlert> alerts;
  final DateTime updatedAt;
  final bool isStale;

  const FlowSnapshot({
    required this.cells,
    required this.edgeStatuses,
    required this.alerts,
    required this.updatedAt,
    this.isStale = false,
  });

  factory FlowSnapshot.empty() {
    return FlowSnapshot(
      cells: const <FlowCell>[],
      edgeStatuses: const <EdgeStatus>[],
      alerts: const <FlowAlert>[],
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  FlowSnapshot asStale() {
    return FlowSnapshot(
      cells: cells,
      edgeStatuses: edgeStatuses,
      alerts: alerts,
      updatedAt: updatedAt,
      isStale: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cells': cells.map((cell) => cell.toJson()).toList(),
      'edge_statuses': edgeStatuses.map((edge) => edge.toJson()).toList(),
      'alerts': alerts.map((alert) => alert.toJson()).toList(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory FlowSnapshot.fromJson(Map<String, dynamic> json) {
    return FlowSnapshot(
      cells: _list(json['cells'], FlowCell.fromJson),
      edgeStatuses: _list(json['edge_statuses'], EdgeStatus.fromJson),
      alerts: _list(json['alerts'], FlowAlert.fromJson),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      isStale: json['is_stale'] == true,
    );
  }

  static List<T> _list<T>(
    Object? raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (raw is! List) {
      return <T>[];
    }
    return raw
        .whereType<Map>()
        .map((item) => fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}

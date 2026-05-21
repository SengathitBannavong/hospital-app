import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/features/map/data/models/route_result.dart';

class MapRouteStatus extends StatelessWidget {
  final AsyncValue<RouteResult?> routeResult;
  final List<int> routeLocations;
  final bool hasStart;
  final bool hasDestination;

  const MapRouteStatus({
    super.key,
    required this.routeResult,
    required this.routeLocations,
    required this.hasStart,
    required this.hasDestination,
  });

  @override
  Widget build(BuildContext context) {
    return routeResult.when(
      data: (data) {
        if (!hasStart || !hasDestination) {
          return _StatusMessage(
            icon: Icons.info_outline_rounded,
            message: _missingRouteMessage(),
            color: context.colorScheme.onSurfaceVariant,
          );
        }
        if (data == null) {
          return _StatusMessage(
            icon: Icons.alt_route_rounded,
            message: 'Route preview is ready when both points are selected.',
            color: context.colorScheme.onSurfaceVariant,
          );
        }

        return _RouteSummary(data: data, routeLocations: routeLocations);
      },
      loading: () => _StatusMessage(
        icon: Icons.sync_rounded,
        message: 'Calculating route...',
        color: context.colorScheme.primary,
      ),
      error: (error, _) => _StatusMessage(
        icon: Icons.error_outline_rounded,
        message: 'Route error: ${error.toString()}',
        color: context.colorScheme.error,
      ),
    );
  }

  String _missingRouteMessage() {
    if (!hasStart && !hasDestination) {
      return 'Choose start and destination to preview route.';
    }
    if (!hasStart) {
      return 'Choose a start point to preview route.';
    }
    return 'Choose a destination to preview route.';
  }
}

class _RouteSummary extends StatelessWidget {
  final RouteResult data;
  final List<int> routeLocations;

  const _RouteSummary({required this.data, required this.routeLocations});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _MetricChip(
          icon: Icons.route_rounded,
          label: '${routeLocations.length} points',
        ),
        _MetricChip(
          icon: Icons.straighten_rounded,
          label: _formatGridDistance(data.distance),
        ),
        _MetricChip(
          icon: Icons.schedule_rounded,
          label: _formatGridEta(data.estimatedTime),
        ),
      ],
    );
  }

  String _formatGridDistance(num distance) {
    return '${distance.toStringAsFixed(0)} cells';
  }

  String _formatGridEta(num eta) {
    return '${eta.toStringAsFixed(1)} grid ETA';
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetricChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.primaryContainer,
        borderRadius: AppRadius.borderSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: context.colorScheme.primary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;

  const _StatusMessage({
    required this.icon,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            message,
            style: context.textTheme.bodyMedium?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/core/l10n/locale_controller.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/features/map/data/models/route_result.dart';
import 'package:hospital_app/features/map/presentation/utils/distance_format.dart';
import 'package:hospital_app/features/map/presentation/widgets/map_async_message.dart';

class MapRouteStatus extends StatelessWidget {
  final AsyncValue<RouteResult?> routeResult;
  final List<int> routeLocations;
  final bool hasStart;
  final bool hasDestination;
  final VoidCallback onRetry;

  const MapRouteStatus({
    super.key,
    required this.routeResult,
    required this.routeLocations,
    required this.hasStart,
    required this.hasDestination,
    required this.onRetry,
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
            message: context.l10n.routePreviewHint,
            color: context.colorScheme.onSurfaceVariant,
          );
        }

        return _RouteSummary(data: data, routeLocations: routeLocations);
      },
      loading: () => _StatusMessage(
        icon: Icons.sync_rounded,
        message: context.l10n.routeCalculating,
        color: context.colorScheme.primary,
      ),
      error: (_, _) => MapAsyncMessage(
        icon: Icons.error_outline_rounded,
        title: context.l10n.routePreviewFailed,
        actionLabel: context.l10n.commonRetry,
        onAction: onRetry,
        compact: true,
      ),
    );
  }

  String _missingRouteMessage() {
    final l10n = appL10n;
    if (!hasStart && !hasDestination) {
      return l10n.routeChooseBoth;
    }
    if (!hasStart) {
      return l10n.routeChooseStart;
    }
    return l10n.routeChooseDest;
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
          label: context.l10n.routePointsCount(routeLocations.length),
        ),
        _MetricChip(
          icon: Icons.straighten_rounded,
          label: formatDistanceFromCells(data.distance),
        ),
        _MetricChip(
          icon: Icons.schedule_rounded,
          label: _formatEta(data.estimatedTime),
        ),
      ],
    );
  }
}

String _formatEta(num eta) {
  final l10n = appL10n;
  final seconds = eta.round().clamp(0, 1 << 31);
  if (seconds < 60) {
    return l10n.routeEtaSeconds(seconds);
  }
  final minutes = seconds / 60;
  if (minutes < 10) {
    return l10n.routeEtaMinutes(minutes.toStringAsFixed(1));
  }
  return l10n.routeEtaMinutes(minutes.round().toString());
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

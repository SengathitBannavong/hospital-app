import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/features/map/data/models/nav_state.dart';
import 'package:hospital_app/features/map/data/models/route_result.dart';
import 'package:hospital_app/features/map/presentation/providers/map_provider.dart';

class MapNavigationSheet extends ConsumerWidget {
  final String destinationName;
  final VoidCallback onDone;
  final VoidCallback onStop;
  final VoidCallback onCollapse;

  const MapNavigationSheet({
    super.key,
    required this.destinationName,
    required this.onDone,
    required this.onStop,
    required this.onCollapse,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(navPhaseProvider);
    final progress = ref.watch(navProgressProvider).clamp(0.0, 1.0).toDouble();
    final speed = ref.watch(navSpeedProvider);
    final routeResult = ref.watch(routeResultProvider);
    final fallbackCells = ref.watch(navMetersRemainingProvider);
    final fallbackEta = ref.watch(navSecondsRemainingProvider);
    final metrics = _remainingMetrics(
      routeResult: routeResult,
      progress: progress,
      speed: speed,
      fallbackCells: fallbackCells,
      fallbackEta: fallbackEta,
    );
    final paused = phase == NavPhase.paused;
    final arrived = phase == NavPhase.arrived;
    final controller = ref.read(navigationControllerProvider);

    return SizedBox(
      width: 280,
      child: Material(
        color: context.colorScheme.surface,
        elevation: 8,
        shadowColor: context.colorScheme.shadow,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    arrived
                        ? Icons.check_circle_rounded
                        : Icons.navigation_rounded,
                    color: arrived
                        ? context.colorScheme.secondary
                        : context.colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      arrived ? 'Arrived' : destinationName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onCollapse,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.close_fullscreen_rounded, size: 18),
                    tooltip: 'Hide',
                  ),
                ],
              ),
              if (!arrived) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _MetricChip(
                      icon: Icons.straighten_rounded,
                      label: _formatGridDistance(metrics.cells),
                    ),
                    _MetricChip(
                      icon: Icons.schedule_rounded,
                      label: _formatGridEta(metrics.eta),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: paused
                            ? controller.resume
                            : controller.pause,
                        icon: Icon(
                          paused
                              ? Icons.play_arrow_rounded
                              : Icons.pause_rounded,
                        ),
                        label: Text(paused ? 'Resume' : 'Pause'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: onStop,
                      icon: const Icon(Icons.stop_rounded),
                      label: const Text('Stop'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SegmentedButton<double>(
                  segments: const [
                    ButtonSegment<double>(value: 1, label: Text('×1')),
                    ButtonSegment<double>(value: 2, label: Text('×2')),
                  ],
                  selected: {speed == 2 ? 2.0 : 1.0},
                  onSelectionChanged: (selection) {
                    controller.setSpeed(selection.first);
                  },
                ),
              ] else ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  destinationName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onDone,
                    icon: const Icon(Icons.done_rounded),
                    label: const Text('Done'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RemainingMetrics {
  final double cells;
  final double eta;

  const _RemainingMetrics({required this.cells, required this.eta});
}

_RemainingMetrics _remainingMetrics({
  required AsyncValue<RouteResult?> routeResult,
  required double progress,
  required double speed,
  required double fallbackCells,
  required double fallbackEta,
}) {
  final result = routeResult.valueOrNull;
  if (result != null) {
    final remaining = (1 - progress).clamp(0.0, 1.0).toDouble();
    return _RemainingMetrics(
      cells: result.distance * remaining,
      eta: result.estimatedTime * remaining / speed,
    );
  }
  return _RemainingMetrics(cells: fallbackCells, eta: fallbackEta);
}

String _formatGridDistance(num distance) {
  return '${distance.toStringAsFixed(0)} cells';
}

String _formatGridEta(num eta) {
  return '${eta.toStringAsFixed(1)} grid ETA';
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

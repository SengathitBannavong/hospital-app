import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/features/map/data/models/nav_state.dart';
import 'package:hospital_app/features/map/data/models/route_result.dart';
import 'package:hospital_app/features/map/presentation/providers/map_provider.dart';
import 'package:hospital_app/features/map/presentation/utils/distance_format.dart';

class MapNavigationSheet extends ConsumerWidget {
  final String destinationName;
  final VoidCallback onStop;
  final VoidCallback onCollapse;

  const MapNavigationSheet({
    super.key,
    required this.destinationName,
    required this.onStop,
    required this.onCollapse,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(navPhaseProvider);
    final progress = ref.watch(navProgressProvider).clamp(0.0, 1.0).toDouble();
    final speed = ref.watch(navSpeedProvider);
    final routeResult = ref.watch(routeResultProvider);
    final fallbackMeters = ref.watch(navMetersRemainingProvider);
    final fallbackSeconds = ref.watch(navSecondsRemainingProvider);
    final metrics = _remainingMetrics(
      routeResult: routeResult,
      progress: progress,
      speed: speed,
      fallbackMeters: fallbackMeters,
      fallbackSeconds: fallbackSeconds,
    );
    final paused = phase == NavPhase.paused;
    final arrived = phase == NavPhase.arrived;
    final voiceMuted = ref.watch(voiceMutedProvider);
    final controller = ref.read(navigationControllerProvider);

    // Cap at 280 but shrink to fit narrow screens (leave room for margins) so
    // the controls never get squeezed enough to wrap.
    final maxWidth = MediaQuery.of(context).size.width - 32;
    final panelWidth = maxWidth < 280 ? maxWidth : 280.0;

    return SizedBox(
      width: panelWidth,
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
                  if (!arrived)
                    IconButton(
                      onPressed: () =>
                          ref.read(voiceMutedProvider.notifier).toggle(),
                      visualDensity: VisualDensity.compact,
                      tooltip: voiceMuted ? 'Unmute voice' : 'Mute voice',
                      icon: Icon(
                        voiceMuted
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        size: 20,
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
                      label: _formatDistance(metrics.meters),
                    ),
                    _MetricChip(
                      icon: Icons.schedule_rounded,
                      label: _formatSeconds(metrics.seconds),
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
                        label: Text(
                          paused ? 'Resume' : 'Pause',
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onStop,
                        icon: const Icon(Icons.stop_rounded),
                        label: const Text(
                          'Stop',
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SegmentedButton<double>(
                  segments: const [
                    ButtonSegment<double>(value: 0.5, label: Text('×0.5')),
                    ButtonSegment<double>(value: 1, label: Text('×1')),
                    ButtonSegment<double>(value: 2, label: Text('×2')),
                  ],
                  selected: {speed <= 0.5 ? 0.5 : (speed >= 2 ? 2.0 : 1.0)},
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
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RemainingMetrics {
  final double meters;
  final double seconds;

  const _RemainingMetrics({required this.meters, required this.seconds});
}

_RemainingMetrics _remainingMetrics({
  required AsyncValue<RouteResult?> routeResult,
  required double progress,
  required double speed,
  required double fallbackMeters,
  required double fallbackSeconds,
}) {
  // Prefer the route's own distance/ETA (backend `route/preview` values when
  // online, engine cell-based values offline); fall back to the controller's
  // mode-speed estimate only while the route is still loading.
  final route = routeResult.valueOrNull;
  if (route != null && route.path.isNotEmpty) {
    final remaining = (1 - progress).clamp(0.0, 1.0).toDouble();
    // `meters` holds grid-cell distance here; it is converted to real units at
    // display time in _formatDistance via formatDistanceFromCells.
    return _RemainingMetrics(
      meters: route.distance * remaining,
      seconds: speed > 0
          ? route.estimatedTime * remaining / speed
          : route.estimatedTime * remaining,
    );
  }
  return _RemainingMetrics(meters: fallbackMeters, seconds: fallbackSeconds);
}

String _formatDistance(num cells) => formatDistanceFromCells(cells);

String _formatSeconds(num seconds) {
  if (seconds < 60) {
    return '${seconds.toStringAsFixed(0)} sec';
  }
  return '${(seconds / 60).toStringAsFixed(0)} min';
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

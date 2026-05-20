import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/features/map/data/models/nav_state.dart';
import 'package:hospital_app/features/map/presentation/providers/map_provider.dart';

class MapNavigationSheet extends ConsumerWidget {
  final String destinationName;
  final VoidCallback onDone;
  final VoidCallback onStop;

  const MapNavigationSheet({
    super.key,
    required this.destinationName,
    required this.onDone,
    required this.onStop,
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
    final controller = ref.read(navigationControllerProvider);

    return Material(
      color: context.colorScheme.surface,
      elevation: 8,
      shadowColor: context.colorScheme.shadow,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
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
  final double meters;
  final double seconds;

  const _RemainingMetrics({required this.meters, required this.seconds});
}

_RemainingMetrics _remainingMetrics({
  required AsyncValue<dynamic> routeResult,
  required double progress,
  required double speed,
  required double fallbackMeters,
  required double fallbackSeconds,
}) {
  final data = routeResult.valueOrNull;
  final distance = _readNumber(data, 'distance');
  final estimatedTime = _readNumber(data, 'estimated_time');
  if (distance != null || estimatedTime != null) {
    final remaining = (1 - progress).clamp(0.0, 1.0).toDouble();
    return _RemainingMetrics(
      meters: distance == null
          ? fallbackMeters
          : (distance * remaining).toDouble(),
      seconds: estimatedTime == null
          ? fallbackSeconds
          : (estimatedTime * remaining / speed).toDouble(),
    );
  }
  return _RemainingMetrics(meters: fallbackMeters, seconds: fallbackSeconds);
}

num? _readNumber(dynamic data, String key) {
  if (data is! Map) {
    return null;
  }
  final value = data[key];
  return value is num ? value : null;
}

String _formatDistance(num distance) {
  if (distance >= 1000) {
    return '${(distance / 1000).toStringAsFixed(1)} km';
  }
  return '${distance.toStringAsFixed(0)} m';
}

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

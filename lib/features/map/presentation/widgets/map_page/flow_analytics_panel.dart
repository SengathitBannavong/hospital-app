part of '../../pages/map_page.dart';

class _FlowAnalyticsPanel extends StatelessWidget {
  final bool isStale;
  final bool heatmapActive;
  final bool edgeStatusActive;
  final bool bottlenecksActive;
  final bool forecastActive;
  final int forecastHours;
  final bool noLiveHeatmapData;
  final bool noLiveBottlenecksData;
  final bool noLiveForecastData;
  final List<FlowForecastBucket> forecastBuckets;
  final ValueChanged<bool> onHeatmapChanged;
  final ValueChanged<bool> onEdgeStatusChanged;
  final ValueChanged<bool> onBottlenecksChanged;
  final ValueChanged<bool> onForecastChanged;
  final ValueChanged<int> onForecastHoursChanged;

  const _FlowAnalyticsPanel({
    required this.isStale,
    required this.heatmapActive,
    required this.edgeStatusActive,
    required this.bottlenecksActive,
    required this.forecastActive,
    required this.forecastHours,
    required this.noLiveHeatmapData,
    required this.noLiveBottlenecksData,
    required this.noLiveForecastData,
    required this.forecastBuckets,
    required this.onHeatmapChanged,
    required this.onEdgeStatusChanged,
    required this.onBottlenecksChanged,
    required this.onForecastChanged,
    required this.onForecastHoursChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Material(
      color: scheme.surface,
      elevation: 3,
      shadowColor: scheme.shadow,
      borderRadius: AppRadius.borderMd,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isStale ? 'Flow Analytics · stale' : 'Flow Analytics',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.md),

            // 1. Heatmap / Density
            _AnalyticsRow(
              title: 'Density Heatmap',
              active: heatmapActive,
              onChanged: onHeatmapChanged,
            ),
            if (heatmapActive) ...[
              const SizedBox(height: AppSpacing.xs),
              if (noLiveHeatmapData)
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 12,
                      color: scheme.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'No live flow data',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: scheme.error,
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    const _LegendSwatch(color: Color(0xFFFFD166)),
                    const SizedBox(width: 4),
                    Text('0', style: context.textTheme.labelSmall),
                    const SizedBox(width: AppSpacing.sm),
                    const _LegendSwatch(color: Color(0xFFE63946)),
                    const SizedBox(width: 4),
                    Text('1 density', style: context.textTheme.labelSmall),
                  ],
                ),
              const SizedBox(height: AppSpacing.sm),
            ],

            // 2. Edge status / congestion
            _AnalyticsRow(
              title: 'Corridor Status',
              active: edgeStatusActive,
              onChanged: onEdgeStatusChanged,
            ),
            if (edgeStatusActive) ...[
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Container(
                    width: 14,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xCCE53935),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('Blocked', style: context.textTheme.labelSmall),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    width: 14,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xCCFF5722),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('Congested', style: context.textTheme.labelSmall),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
            ],

            // 3. Bottlenecks
            _AnalyticsRow(
              title: 'Top-N Bottlenecks',
              active: bottlenecksActive,
              onChanged: onBottlenecksChanged,
            ),
            if (bottlenecksActive) ...[
              const SizedBox(height: AppSpacing.xs),
              if (noLiveBottlenecksData)
                Text(
                  'No bottlenecks detected',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                )
              else
                Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD32F2F),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '1',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: const Color(0xFFFAFCFE),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Ranked hotspots',
                      style: context.textTheme.labelSmall,
                    ),
                  ],
                ),
              const SizedBox(height: AppSpacing.sm),
            ],

            // 4. Forecast
            _AnalyticsRow(
              title: 'Flow Forecast',
              active: forecastActive,
              onChanged: onForecastChanged,
            ),
            if (forecastActive) ...[
              const SizedBox(height: AppSpacing.xs),
              if (noLiveForecastData)
                Row(
                  children: [
                    Icon(
                      Icons.cloud_off_rounded,
                      size: 12,
                      color: scheme.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Forecast unavailable',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: scheme.error,
                      ),
                    ),
                  ],
                )
              else
                _HourlyForecastChart(buckets: forecastBuckets),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Lookback: $forecastHours hr${forecastHours > 1 ? 's' : ''}',
                style: context.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3.0,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6.0,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 12.0,
                  ),
                  activeTrackColor: scheme.primary,
                  inactiveTrackColor: scheme.primaryContainer.withValues(
                    alpha: 0.24,
                  ),
                  thumbColor: scheme.primary,
                ),
                child: Slider(
                  value: forecastHours.toDouble(),
                  min: 1.0,
                  max: 12.0,
                  divisions: 11,
                  onChanged: (val) => onForecastHoursChanged(val.toInt()),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HourlyForecastChart extends StatelessWidget {
  final List<FlowForecastBucket> buckets;

  const _HourlyForecastChart({required this.buckets});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    var maxCount = 0;
    for (final bucket in buckets) {
      if (bucket.count > maxCount) maxCount = bucket.count;
    }

    return SizedBox(
      height: 76,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final bucket in buckets) ...[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: maxCount == 0
                            ? 0
                            : (bucket.count / maxCount).clamp(0.0, 1.0),
                        child: Container(
                          width: 10,
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.72),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bucket.hour.toString().padLeft(2, '0'),
                    style: context.textTheme.labelSmall?.copyWith(
                      fontSize: 9,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (bucket != buckets.last) const SizedBox(width: 3),
          ],
        ],
      ),
    );
  }
}

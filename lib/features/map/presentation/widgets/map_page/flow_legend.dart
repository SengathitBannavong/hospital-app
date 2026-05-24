part of '../../pages/map_page.dart';

class _FlowLegend extends StatelessWidget {
  final bool isStale;
  final bool noData;

  const _FlowLegend({required this.isStale, this.noData = false});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Material(
      color: scheme.surface,
      elevation: 2,
      shadowColor: scheme.shadow,
      borderRadius: AppRadius.borderSm,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isStale ? 'Flow heatmap · stale' : 'Flow heatmap',
              style: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            if (noData)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 14,
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
                mainAxisSize: MainAxisSize.min,
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
          ],
        ),
      ),
    );
  }
}

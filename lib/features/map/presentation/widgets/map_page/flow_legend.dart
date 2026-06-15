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
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 6,
        ),
        child: noData
            ? Tooltip(
                message: context.l10n.flowNoLiveData,
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: scheme.error,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 8,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          MapTokens.debugTap.withValues(alpha: 0.7),
                          MapTokens.debugPoi.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    height: 44,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('1', style: context.textTheme.labelSmall),
                        Text('0', style: context.textTheme.labelSmall),
                      ],
                    ),
                  ),
                  if (isStale) ...[
                    const SizedBox(width: 4),
                    Tooltip(
                      message: context.l10n.flowStaleData,
                      child: Icon(
                        Icons.schedule_rounded,
                        size: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

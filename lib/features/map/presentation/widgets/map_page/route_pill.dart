part of '../../pages/map_page.dart';

class _RoutePill extends StatelessWidget {
  final String startName;
  final MapPoi? dest;
  final VoidCallback? onTap;
  final VoidCallback? onClear;

  const _RoutePill({
    required this.startName,
    required this.dest,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (dest == null) return const SizedBox.shrink();
    final scheme = context.colorScheme;
    final destName = dest?.poiName ?? 'Pick destination';

    return Semantics(
      container: true,
      button: onTap != null,
      label: 'Route from $startName to $destName. Tap to edit.',
      child: Material(
        color: scheme.surface,
        elevation: 2,
        shadowColor: scheme.shadow,
        borderRadius: AppRadius.borderFull,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderFull,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.xs,
              AppSpacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.my_location_rounded,
                  size: 14,
                  color: scheme.primary,
                ),
                const SizedBox(width: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 96),
                  child: Text(
                    startName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Icon(Icons.flag_rounded, size: 14, color: scheme.secondary),
                const SizedBox(width: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 96),
                  child: Text(
                    destName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                if (onClear != null)
                  IconButton(
                    iconSize: 18,
                    visualDensity: VisualDensity.compact,
                    onPressed: onClear,
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Ẩn',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

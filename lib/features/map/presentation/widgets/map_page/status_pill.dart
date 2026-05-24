part of '../../pages/map_page.dart';

class _StatusPill extends StatelessWidget {
  final _PillData data;
  final VoidCallback? onTap;

  const _StatusPill({required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.4,
      child: Material(
        color: data.background,
        elevation: 2,
        shadowColor: context.colorScheme.shadow,
        borderRadius: AppRadius.borderXl,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderXl,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(data.icon, size: 16, color: data.foreground),
                const SizedBox(width: AppSpacing.xs),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: Text(
                    data.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: data.foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Icon(Icons.refresh_rounded, size: 14, color: data.foreground),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

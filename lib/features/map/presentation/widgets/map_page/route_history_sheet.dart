part of '../../pages/map_page.dart';

class _RouteHistorySheet extends StatelessWidget {
  static const int _displayLimit = 15;

  final AsyncValue<RouteHistory> history;
  final VoidCallback onRetry;
  final void Function(RouteHistoryEntry entry) onRate;
  final Future<void> Function() onClearAll;
  final Future<void> Function(RouteHistoryEntry entry) onRenavigate;

  const _RouteHistorySheet({
    required this.history,
    required this.onRetry,
    required this.onRate,
    required this.onClearAll,
    required this.onRenavigate,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.72,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.mapActionRouteHistory,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: context.l10n.rhRefresh,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Flexible(
              child: history.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => MapAsyncMessage(
                  icon: Icons.cloud_off_rounded,
                  title: context.l10n.rhUnavailable,
                  actionLabel: context.l10n.commonRetry,
                  onAction: onRetry,
                ),
                data: (data) {
                  if (data.routes.isEmpty) {
                    return MapAsyncMessage(
                      icon: Icons.history_rounded,
                      title: context.l10n.rhEmpty,
                    );
                  }
                  final routes = data.routes
                      .take(_displayLimit)
                      .toList(growable: false);
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: routes.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final entry = routes[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: scheme.primaryContainer,
                          foregroundColor: scheme.onPrimaryContainer,
                          child: const Icon(Icons.alt_route_rounded),
                        ),
                        title: Text(
                          entry.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          [
                            if (entry.modeId != null) entry.modeId!,
                            _relativeTime(entry.createdAt),
                          ].join(' · '),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (entry.routeId != null)
                              IconButton(
                                icon: const Icon(Icons.star_rounded),
                                color: Colors.amber.shade700,
                                tooltip: context.l10n.rhRateRoute,
                                visualDensity: VisualDensity.compact,
                                onPressed: () => onRate(entry),
                              ),
                            const Icon(Icons.chevron_right_rounded),
                          ],
                        ),
                        onTap: () => onRenavigate(entry),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: history.valueOrNull?.routes.isEmpty ?? true
                    ? null
                    : onClearAll,
                icon: const Icon(Icons.delete_outline_rounded),
                label: Text(context.l10n.rhClearAll),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _relativeTime(DateTime? value) {
    final l10n = appL10n;
    if (value == null) {
      return l10n.timeUnknown;
    }
    final delta = DateTime.now().difference(value.toLocal());
    if (delta.inMinutes < 1) {
      return l10n.timeJustNow;
    }
    if (delta.inHours < 1) {
      return l10n.timeMinutesAgo(delta.inMinutes);
    }
    if (delta.inDays < 1) {
      return l10n.timeHoursAgo(delta.inHours);
    }
    if (delta.inDays < 30) {
      return l10n.timeDaysAgo(delta.inDays);
    }
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }
}

part of '../../pages/map_page.dart';

// ignore: unused_element
class _RouteHistorySheet extends StatelessWidget {
  final AsyncValue<RouteHistory> history;
  final VoidCallback onRetry;
  final Future<void> Function() onClearAll;
  final Future<void> Function(RouteHistoryEntry entry) onRenavigate;

  const _RouteHistorySheet({
    required this.history,
    required this.onRetry,
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
                    'Route history',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Refresh history',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Flexible(
              child: history.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => MapAsyncMessage(
                  icon: Icons.cloud_off_rounded,
                  title: 'History unavailable',
                  actionLabel: 'Retry',
                  onAction: onRetry,
                ),
                data: (data) {
                  if (data.routes.isEmpty) {
                    return const MapAsyncMessage(
                      icon: Icons.history_rounded,
                      title: 'No completed routes yet',
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: data.routes.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final entry = data.routes[index];
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
                        trailing: const Icon(Icons.chevron_right_rounded),
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
                label: const Text('Clear all'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _relativeTime(DateTime? value) {
    if (value == null) {
      return 'Unknown time';
    }
    final delta = DateTime.now().difference(value.toLocal());
    if (delta.inMinutes < 1) {
      return 'Just now';
    }
    if (delta.inHours < 1) {
      return '${delta.inMinutes} min ago';
    }
    if (delta.inDays < 1) {
      return '${delta.inHours} hr ago';
    }
    if (delta.inDays < 30) {
      return '${delta.inDays} d ago';
    }
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }
}

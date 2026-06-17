import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/core/l10n/locale_controller.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/features/map/data/models/search_history.dart';

/// Shown in the search overlay when the box is open but empty: the user's
/// recent searches from the backend, each tappable to re-run it, with a clear
/// action. Renders nothing while loading, on error, or when the history is
/// empty — recent searches are a convenience, never an obstacle.
class MapRecentSearchesPanel extends StatelessWidget {
  final AsyncValue<SearchHistory> history;
  final ValueChanged<SearchHistoryEntry> onSelect;
  final VoidCallback onClear;

  const MapRecentSearchesPanel({
    super.key,
    required this.history,
    required this.onSelect,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final entries = history.valueOrNull?.items ?? const <SearchHistoryEntry>[];
    if (entries.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      elevation: 1,
      shadowColor: scheme.shadow,
      borderRadius: AppRadius.borderXl,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.xs,
              0,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    context.l10n.mapRecentSearches,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onClear,
                  child: Text(context.l10n.mapRecentSearchesClear),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              itemCount: entries.length,
              separatorBuilder: (_, _) =>
                  Divider(height: 1, color: Theme.of(context).dividerColor),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.north_west_rounded,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                  title: Text(
                    entry.displayLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  onTap: () => onSelect(entry),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

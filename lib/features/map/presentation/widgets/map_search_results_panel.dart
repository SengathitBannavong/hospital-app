import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/features/map/data/models/map_poi.dart';
import 'package:hospital_app/features/map/presentation/theme/map_tokens.dart';

class MapSearchResultsPanel extends StatelessWidget {
  final AsyncValue<List<MapPoi>> results;
  final String query;
  final List<MapPoi> suggestions;
  final ValueChanged<MapPoi> onSelect;
  final VoidCallback onRetry;

  const MapSearchResultsPanel({
    super.key,
    required this.results,
    required this.query,
    required this.suggestions,
    required this.onSelect,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 1,
      shadowColor: Theme.of(context).colorScheme.shadow,
      borderRadius: AppRadius.borderXl,
      clipBehavior: Clip.antiAlias,
      child: results.when(
        data: (items) {
          if (items.isEmpty) return _empty(context);
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            itemCount: items.length,
            separatorBuilder: (_, _) =>
                Divider(height: 1, color: Theme.of(context).dividerColor),
            itemBuilder: (context, index) {
              final poi = items[index];
              return _ResultTile(poi: poi, onTap: () => onSelect(poi));
            },
          );
        },
        loading: () => const _SkeletonList(),
        error: (error, _) => _error(context, error),
      ),
    );
  }

  Widget _empty(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'No matches for "$query"',
            style: context.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Try a shorter word, or pick a suggestion.',
            style: context.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          if (suggestions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final poi in suggestions)
                  ActionChip(
                    label: Text(poi.poiName),
                    onPressed: () => onSelect(poi),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _error(BuildContext context, Object error) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: scheme.error),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Search failed',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: scheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  error.toString(),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final MapPoi poi;
  final VoidCallback onTap;

  const _ResultTile({required this.poi, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = MapPoiPalette.colorFor(poi.poiType);
    return Semantics(
      button: true,
      label: '${poi.poiName}, ${MapPoiPalette.labelFor(poi.poiType)}',
      child: ListTile(
        leading: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
        title: Text(
          poi.poiName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${MapPoiPalette.labelFor(poi.poiType)} · ${poi.poiCode}',
          style: context.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        onTap: onTap,
        minVerticalPadding: AppSpacing.sm,
      ),
    );
  }
}

class _SkeletonList extends StatefulWidget {
  const _SkeletonList();

  @override
  State<_SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<_SkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final t = 0.35 + 0.25 * _controller.value;
                  final base = scheme.onSurface.withValues(alpha: t * 0.18);
                  return Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: base,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 10,
                              width: 180,
                              decoration: BoxDecoration(
                                color: base,
                                borderRadius: AppRadius.borderSm,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 8,
                              width: 120,
                              decoration: BoxDecoration(
                                color: base,
                                borderRadius: AppRadius.borderSm,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

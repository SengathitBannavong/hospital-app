import 'package:flutter/material.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/features/map/data/models/map_poi.dart';

class MapPoiMetadataPanel extends StatelessWidget {
  final MapPoi poi;
  final VoidCallback onClose;
  final VoidCallback onSetStart;
  final VoidCallback onSetDestination;

  const MapPoiMetadataPanel({
    super.key,
    required this.poi,
    required this.onClose,
    required this.onSetStart,
    required this.onSetDestination,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.surface,
      elevation: 8,
      shadowColor: context.colorScheme.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderLg,
        side: BorderSide(color: context.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    poi.poiName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${poi.poiType.toUpperCase()} • ${poi.poiCode}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _InfoChip(
                  icon: Icons.grid_on_rounded,
                  label: 'Row ${poi.gridRow}, Col ${poi.gridCol}',
                ),
                if (poi.openHours != null && poi.openHours!.isNotEmpty)
                  _InfoChip(
                    icon: Icons.access_time_rounded,
                    label: poi.openHours!,
                  ),
              ],
            ),
            if (poi.details != null && poi.details!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                poi.details!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onSetStart,
                    icon: const Icon(Icons.my_location_rounded),
                    label: const Text('Start'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onSetDestination,
                    icon: const Icon(Icons.flag_rounded),
                    label: const Text('Destination'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.borderSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: context.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

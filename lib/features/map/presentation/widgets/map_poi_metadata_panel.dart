import 'package:flutter/material.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/features/map/data/models/map_poi.dart';
import 'package:hospital_app/features/map/presentation/theme/map_tokens.dart';

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
    final scheme = context.colorScheme;
    final color = MapPoiPalette.colorFor(poi.poiType);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      poi.poiName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${MapPoiPalette.labelFor(poi.poiType)} · ${poi.poiCode}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Semantics(
                button: true,
                label: 'Close',
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Close',
                  ),
                ),
              ),
            ],
          ),
          if ((poi.details ?? '').isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              poi.details!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _InfoChip(
                icon: Icons.grid_on_rounded,
                label: 'R${poi.gridRow} · C${poi.gridCol}',
              ),
              if ((poi.openHours ?? '').isNotEmpty)
                _InfoChip(
                  icon: Icons.access_time_rounded,
                  label: poi.openHours!,
                ),
              if (poi.wheelchairAccessible)
                const _InfoChip(
                  icon: Icons.accessible_rounded,
                  label: 'Wheelchair',
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onSetStart,
                  icon: const Icon(Icons.my_location_rounded),
                  label: const Text('Set as start'),
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
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

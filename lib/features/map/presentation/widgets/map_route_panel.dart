import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/features/map/data/models/map_poi.dart';
import 'map_route_status.dart';

class MapRoutePanel extends StatelessWidget {
  final MapPoi? start;
  final MapPoi? dest;
  final String mode;
  final AsyncValue<dynamic> routeResult;
  final List<int> routeLocations;
  final VoidCallback onClear;
  final ValueChanged<String> onModeChanged;
  final VoidCallback onPickStart;
  final VoidCallback onPickDestination;

  const MapRoutePanel({
    super.key,
    required this.start,
    required this.dest,
    required this.mode,
    required this.routeResult,
    required this.routeLocations,
    required this.onClear,
    required this.onModeChanged,
    required this.onPickStart,
    required this.onPickDestination,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
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
            children: [
              Expanded(
                child: Text(
                  'Plan a route',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: (start == null && dest == null) ? null : onClear,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _RouteEndpointRow(
            icon: Icons.my_location_rounded,
            label: 'Start',
            value: start?.poiName ?? 'Pick a place',
            isSet: start != null,
            onPick: onPickStart,
            accent: scheme.primary,
          ),
          const SizedBox(height: AppSpacing.sm),
          _RouteEndpointRow(
            icon: Icons.flag_rounded,
            label: 'Destination',
            value: dest?.poiName ?? 'Pick a place',
            isSet: dest != null,
            onPick: onPickDestination,
            accent: scheme.secondary,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(
                'Mode',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              DropdownButton<String>(
                value: mode,
                underline: const SizedBox.shrink(),
                onChanged: (value) {
                  if (value != null) onModeChanged(value);
                },
                items: const [
                  DropdownMenuItem(value: 'walking', child: Text('Walking')),
                  DropdownMenuItem(
                    value: 'wheelchair',
                    child: Text('Wheelchair'),
                  ),
                  DropdownMenuItem(
                    value: 'stretcher',
                    child: Text('Stretcher'),
                  ),
                  DropdownMenuItem(
                    value: 'hospital_cart',
                    child: Text('Hospital cart'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          MapRouteStatus(
            routeResult: routeResult,
            routeLocations: routeLocations,
            hasStart: start != null,
            hasDestination: dest != null,
          ),
        ],
      ),
    );
  }
}

class _RouteEndpointRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isSet;
  final VoidCallback onPick;
  final Color accent;

  const _RouteEndpointRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isSet,
    required this.onPick,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Semantics(
      button: true,
      label: '$label: $value. Tap to change.',
      child: InkWell(
        onTap: onPick,
        borderRadius: AppRadius.borderMd,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: AppRadius.borderMd,
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 16, color: accent),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        letterSpacing: 0.4,
                      ),
                    ),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: isSet
                            ? scheme.onSurface
                            : scheme.onSurfaceVariant,
                        fontWeight: isSet ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

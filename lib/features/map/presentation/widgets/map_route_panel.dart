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
  final VoidCallback onHide;

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
    required this.onHide,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomSheetTheme = theme.bottomSheetTheme;

    return Material(
      color: bottomSheetTheme.backgroundColor ?? theme.colorScheme.surface,
      surfaceTintColor: bottomSheetTheme.surfaceTintColor,
      shape:
          bottomSheetTheme.shape ??
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
      elevation: bottomSheetTheme.elevation ?? 12,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          16 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Route',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onHide,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  tooltip: 'Hide route panel',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _RouteEndpointRow(
              icon: Icons.my_location_rounded,
              label: 'Start',
              value: start?.poiName ?? 'Not selected',
              isSet: start != null,
              onPick: onPickStart,
            ),
            const SizedBox(height: AppSpacing.xs),
            _RouteEndpointRow(
              icon: Icons.flag_rounded,
              label: 'Destination',
              value: dest?.poiName ?? 'Not selected',
              isSet: dest != null,
              onPick: onPickDestination,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Text('Mode:'),
                const SizedBox(width: AppSpacing.md),
                DropdownButton<String>(
                  value: mode,
                  onChanged: (value) {
                    if (value != null) {
                      onModeChanged(value);
                    }
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
                      child: Text('Hospital Cart'),
                    ),
                  ],
                ),
                const Spacer(),
                TextButton(onPressed: onClear, child: const Text('Clear')),
              ],
            ),
            const SizedBox(height: 8),
            MapRouteStatus(
              routeResult: routeResult,
              routeLocations: routeLocations,
              hasStart: start != null,
              hasDestination: dest != null,
            ),
          ],
        ),
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

  const _RouteEndpointRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isSet,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSet
        ? context.colorScheme.primary
        : context.colorScheme.onSurfaceVariant;

    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyMedium?.copyWith(
              color: isSet
                  ? context.colorScheme.onSurface
                  : context.colorScheme.onSurfaceVariant,
              fontWeight: isSet ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: onPick,
          icon: Icon(isSet ? Icons.swap_horiz_rounded : Icons.list_rounded),
          label: Text(isSet ? 'Change' : 'Select'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            foregroundColor: color,
          ),
        ),
      ],
    );
  }
}

class MapRoutePanelCollapsed extends StatelessWidget {
  final VoidCallback onShow;

  const MapRoutePanelCollapsed({super.key, required this.onShow});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomSheetTheme = theme.bottomSheetTheme;

    return Material(
      color: bottomSheetTheme.backgroundColor ?? theme.colorScheme.surface,
      surfaceTintColor: bottomSheetTheme.surfaceTintColor,
      shape:
          bottomSheetTheme.shape ??
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
      elevation: bottomSheetTheme.elevation ?? 12,
      child: InkWell(
        onTap: onShow,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.alt_route_rounded),
              SizedBox(width: 8),
              Text('Show route'),
            ],
          ),
        ),
      ),
    );
  }
}

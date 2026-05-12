import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                const Icon(Icons.place, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    start?.poiName ?? 'Select start point',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.flag, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dest?.poiName ?? 'Select destination',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: onHide,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  tooltip: 'Hide route panel',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Mode:'),
                const SizedBox(width: 12),
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
            ),
          ],
        ),
      ),
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

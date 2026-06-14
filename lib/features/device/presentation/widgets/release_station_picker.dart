import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/features/device/data/models/asset_station.dart';
import 'package:hospital_app/features/device/presentation/providers/asset_providers.dart';

/// Bottom sheet listing every station (with fullness); returns the chosen
/// station_id as a String, or null if cancelled. Full stations are disabled.
Future<String?> showReleaseStationPicker(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      final stations = ref.watch(assetStationsProvider);
      return SafeArea(
        child: Padding(
          padding: AppSpacing.pageWithTop,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Trả thiết bị tại trạm', style: ctx.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              stations.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    err.toString().replaceFirst('Exception: ', ''),
                    textAlign: TextAlign.center,
                  ),
                ),
                data: (list) {
                  if (list.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: Text('Không có trạm thiết bị nào.'),
                    );
                  }
                  return Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: list.length,
                      itemBuilder: (_, i) => _StationTile(
                        station: list[i],
                        onTap: (id) => Navigator.pop(ctx, id),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _StationTile extends StatelessWidget {
  const _StationTile({required this.station, required this.onTap});

  final AssetStation station;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final available = station.availableWheelchairs;
    final capacity = station.capacity;
    final isFull = capacity > 0 && available >= capacity;
    final subtitle = isFull
        ? '$available/$capacity (đầy)'
        : '$available/$capacity trống';

    return ListTile(
      enabled: !isFull,
      leading: Icon(
        Icons.local_parking_rounded,
        color: isFull
            ? context.colorScheme.onSurfaceVariant
            : context.colorScheme.primary,
      ),
      title: Text(station.stationName),
      subtitle: Text(subtitle),
      // The backend's release_asset resolves the station by `station_name`
      // (not the numeric PK), so send the name as `station_id`. See
      // context/asset_wheelchair_backend_gap.md.
      onTap: isFull ? null : () => onTap(station.stationName),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/l10n/locale_controller.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/features/device/data/models/asset_device.dart';
import 'package:hospital_app/features/device/presentation/providers/asset_providers.dart';
import 'package:hospital_app/features/map/data/models/map_poi.dart';
import 'package:hospital_app/features/map/presentation/widgets/poi_picker.dart';

class WheelchairSearchPage extends ConsumerStatefulWidget {
  const WheelchairSearchPage({super.key, this.initialPoi});

  /// When opened from a map POI, the search starts pre-filled with that POI so
  /// it immediately lists wheelchairs near it.
  final MapPoi? initialPoi;

  @override
  ConsumerState<WheelchairSearchPage> createState() =>
      _WheelchairSearchPageState();
}

class _WheelchairSearchPageState extends ConsumerState<WheelchairSearchPage> {
  MapPoi? _selectedPoi;

  @override
  void initState() {
    super.initState();
    _selectedPoi = widget.initialPoi;
  }

  Future<void> _pickPoi() async {
    final poi = await showPoiPicker(
      context,
      title: context.l10n.wsPickLocationTitle,
    );
    if (poi != null) setState(() => _selectedPoi = poi);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Text(context.l10n.homeActionFindWheelchair),
      ),
      body: Column(
        children: [
          Padding(
            padding: AppSpacing.pageWithTop,
            child: PoiPickerField(
              label: context.l10n.wsYourLocation,
              hint: context.l10n.wsYourLocationHint,
              selected: _selectedPoi,
              onTap: _pickPoi,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(child: _Results(nodeId: _selectedPoi?.poiCode)),
        ],
      ),
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({required this.nodeId});

  final String? nodeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (nodeId == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.accessible_forward_rounded,
              size: 56,
              color: context.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              context.l10n.wsEnterLocationPrompt,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final results = ref.watch(wheelchairSearchProvider(nodeId!));

    return results.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Padding(
          padding: AppSpacing.cardPaddingLarge,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 36),
              const SizedBox(height: AppSpacing.md),
              Text(
                err.toString().replaceFirst('Exception: ', ''),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () =>
                    ref.invalidate(wheelchairSearchProvider(nodeId!)),
                child: Text(context.l10n.commonRetry),
              ),
            ],
          ),
        ),
      ),
      data: (devices) {
        if (devices.isEmpty) {
          return Center(child: Text(context.l10n.wsNoWheelchairs));
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          itemCount: devices.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) => _DeviceCard(device: devices[index]),
        );
      },
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({required this.device});

  final AssetDevice device;

  @override
  Widget build(BuildContext context) {
    final statusColor = device.isAvailable ? Colors.green : Colors.red;
    final statusLabel = device.isAvailable
        ? context.l10n.wsAvailable
        : context.l10n.wsUnavailable;

    return Card(
      child: ListTile(
        contentPadding: AppSpacing.cardPadding,
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.12),
          child: Icon(Icons.accessible_rounded, color: statusColor),
        ),
        title: Text(device.assetId),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(statusLabel, style: TextStyle(color: statusColor)),
            if (device.batteryLevel != null)
              Text(context.l10n.wsBatteryPercent(device.batteryLevel!)),
            if (device.distance != null)
              Text(context.l10n.wsDistance(device.distance!)),
          ],
        ),
        trailing: device.isAvailable
            ? FilledButton.tonal(
                onPressed: () => context.push('/asset/book/${device.assetId}'),
                child: Text(context.l10n.wsBorrow),
              )
            : null,
      ),
    );
  }
}

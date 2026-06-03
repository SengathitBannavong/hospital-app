import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/features/device/data/models/asset_device.dart';
import 'package:hospital_app/features/device/presentation/providers/asset_providers.dart';
import 'package:hospital_app/features/map/data/models/map_poi.dart';
import 'package:hospital_app/features/map/presentation/widgets/poi_picker.dart';

class WheelchairSearchPage extends ConsumerStatefulWidget {
  const WheelchairSearchPage({super.key});

  @override
  ConsumerState<WheelchairSearchPage> createState() =>
      _WheelchairSearchPageState();
}

class _WheelchairSearchPageState extends ConsumerState<WheelchairSearchPage> {
  MapPoi? _selectedPoi;

  Future<void> _pickPoi() async {
    final poi = await showPoiPicker(context, title: 'Chọn vị trí của bạn');
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
        title: const Text('Tìm xe lăn'),
      ),
      body: Column(
        children: [
          Padding(
            padding: AppSpacing.pageWithTop,
            child: PoiPickerField(
              label: 'Vị trí của bạn',
              hint: 'Chọn vị trí để tìm xe lăn gần đó...',
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
              'Nhập mã vị trí để tìm xe lăn gần đó',
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
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
      data: (devices) {
        if (devices.isEmpty) {
          return const Center(
            child: Text('Không có xe lăn trống gần vị trí này.'),
          );
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
    final statusLabel = device.isAvailable ? 'Có sẵn' : 'Không khả dụng';

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
              Text('Pin: ${device.batteryLevel}%'),
            if (device.distance != null) Text('Cách ${device.distance}m'),
          ],
        ),
        trailing: device.isAvailable
            ? FilledButton.tonal(
                onPressed: () => context.push('/asset/book/${device.assetId}'),
                child: const Text('Mượn'),
              )
            : null,
      ),
    );
  }
}

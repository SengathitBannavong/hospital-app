import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/widgets/medical_info_card.dart';
import 'device_providers.dart';

class DevicePage extends ConsumerStatefulWidget {
  const DevicePage({super.key});

  @override
  ConsumerState<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends ConsumerState<DevicePage> {
  bool _isLoading = false;

  // Hàm xử lý đặt thiết bị (Booking Logic)
  Future<void> _handleBookAsset(String stationId) async {
    setState(() => _isLoading = true);
    try {
      // Ví dụ đặt thiết bị (Trong bản Demo có thể dùng asset_id cố định)
      await ref.read(deviceServiceProvider).bookAsset("ASSET-001");
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đặt thiết bị thành công!')),
        );
        // Làm mới danh sách trạm
        ref.invalidate(assetStationsProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xảy ra lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stationsAsync = ref.watch(assetStationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách thiết bị'),
      ),
      body: Stack(
        children: [
          stationsAsync.when(
            data: (stations) => ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: stations.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final station = stations[index];
                return MedicalInfoCard(
                  label: station.stationName,
                  value: 'Trống: ${station.availableWheelchairs} / ${station.capacity}',
                  icon: Icons.accessible,
                  onTap: station.availableWheelchairs > 0 
                      ? () => _handleBookAsset(station.stationId.toString())
                      : null,
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Không thể tải dữ liệu: $err'),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(assetStationsProvider),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

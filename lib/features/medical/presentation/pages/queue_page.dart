import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/hospital_theme.dart';
import '../../../map/data/models/map_poi.dart';
import '../../../map/presentation/widgets/poi_picker.dart';
import '../../data/models/room_open.dart';
import '../providers/medical_providers.dart';
import '../widgets/queue_item.dart';

class QueuePage extends ConsumerStatefulWidget {
  const QueuePage({super.key});

  @override
  ConsumerState<QueuePage> createState() => _QueuePageState();
}

class _QueuePageState extends ConsumerState<QueuePage> {
  MapPoi? _poi;

  int? get _poiId => _poi?.poiId;

  Future<void> _pickPoi() async {
    final poi = await showPoiPicker(context, title: 'Chọn phòng khám');
    if (poi != null) setState(() => _poi = poi);
  }

  Future<void> _refresh() async {
    final poiId = _poiId;
    if (poiId == null) return;
    ref
      ..invalidate(medicalQueueProvider(poiId))
      ..invalidate(medicalRoomOpenProvider(poiId));
    await Future.wait([
      ref.read(medicalQueueProvider(poiId).future),
      ref.read(medicalRoomOpenProvider(poiId).future),
    ]);
  }

  Widget _buildRoomOpenCard(BuildContext context, RoomOpen roomOpen) {
    final statusColor = roomOpen.isOpen
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;

    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              roomOpen.poiName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('Giờ mở cửa: ${roomOpen.openHours ?? 'Không rõ'}'),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(
                  roomOpen.isOpen ? Icons.lock_open : Icons.lock_outline,
                  size: 16,
                  color: statusColor,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  roomOpen.isOpen ? 'Đang mở' : 'Đang đóng',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: statusColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final poiId = _poiId;

    return Scaffold(
      appBar: AppBar(title: const Text('Hàng đợi')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: AppSpacing.pagePadding,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: AppSpacing.md),
            PoiPickerField(
              label: 'Phòng khám',
              hint: 'Chọn phòng khám...',
              selected: _poi,
              onTap: _pickPoi,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (poiId == null)
              const Text(
                'Hãy chọn phòng khám để xem trạng thái hàng đợi và giờ mở cửa.',
              )
            else ...[
              ref
                  .watch(medicalRoomOpenProvider(poiId))
                  .when(
                    data: (roomOpen) => roomOpen == null
                        ? const Text('Không có dữ liệu phòng')
                        : _buildRoomOpenCard(context, roomOpen),
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, _) => Text(
                      error.toString().replaceFirst('Exception: ', ''),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
              const SizedBox(height: AppSpacing.md),
              ref
                  .watch(medicalQueueProvider(poiId))
                  .when(
                    data: (queue) => queue == null
                        ? const Text('Không có dữ liệu hàng đợi')
                        : QueueItem(status: queue),
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, _) => Text(
                      error.toString().replaceFirst('Exception: ', ''),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
            ],
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

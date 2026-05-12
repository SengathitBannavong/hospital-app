import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/hospital_theme.dart';
import '../../data/models/room_open.dart';
import '../providers/medical_providers.dart';
import '../widgets/queue_item.dart';

class QueuePage extends ConsumerStatefulWidget {
  const QueuePage({super.key});

  @override
  ConsumerState<QueuePage> createState() => _QueuePageState();
}

class _QueuePageState extends ConsumerState<QueuePage> {
  final TextEditingController _poiController = TextEditingController();
  int? _poiId;

  @override
  void dispose() {
    _poiController.dispose();
    super.dispose();
  }

  void _submitPoiId() {
    final value = int.tryParse(_poiController.text.trim());
    if (value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập POI ID hợp lệ')),
      );
      return;
    }

    setState(() {
      _poiId = value;
    });
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
            Card(
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nhập POI ID phòng khám'),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _poiController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Ví dụ: 3'),
                      onSubmitted: (_) => _submitPoiId(),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ElevatedButton(
                      onPressed: _submitPoiId,
                      child: const Text('Xem hàng đợi'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (poiId == null)
              const Text(
                'Hãy nhập POI ID để xem trạng thái hàng đợi và giờ mở cửa.',
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

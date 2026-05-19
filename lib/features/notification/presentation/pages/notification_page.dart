import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/hospital_theme.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_card.dart';

class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationProvider);
    final unreadCount = notifications.where((item) => !item.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Thông báo ($unreadCount)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            tooltip: 'Đánh dấu tất cả đã đọc',
            onPressed: () {
              ref.read(notificationProvider.notifier).markAllAsRead();
            },
          ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(child: Text('Không có thông báo nào'))
          : ListView.separated(
              padding: AppSpacing.pageWithTop,
              itemCount: notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final item = notifications[index];

                return NotificationCard(
                  notification: item,
                  onTap: () {
                    ref.read(notificationProvider.notifier).markAsRead(item.id);
                  },
                  onDelete: () {
                    ref
                        .read(notificationProvider.notifier)
                        .deleteNotification(item.id);
                  },
                );
              },
            ),
    );
  }
}

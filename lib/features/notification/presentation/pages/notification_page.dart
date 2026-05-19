import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/hospital_theme.dart';
import '../../../../core/utils/app_toast.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_card.dart';

class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsState = ref.watch(notificationProvider);
    final unreadCount = notificationsState.maybeWhen(
      data: (items) => items.where((item) => !item.isRead).length,
      orElse: () => 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Thông báo ($unreadCount)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            tooltip: 'Đánh dấu tất cả đã đọc',
            onPressed: () async {
              try {
                await ref.read(notificationProvider.notifier).markAllAsRead();
              } catch (error) {
                AppToast.showError(_formatError(error));
              }
            },
          ),
        ],
      ),
      body: notificationsState.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => ref
                  .read(notificationProvider.notifier)
                  .fetchNotifications(keepPrevious: true),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: AppSpacing.pageWithTop,
                children: const [
                  SizedBox(height: AppSpacing.xxl),
                  Center(child: Text('Không có thông báo nào')),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref
                .read(notificationProvider.notifier)
                .fetchNotifications(keepPrevious: true),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppSpacing.pageWithTop,
              itemCount: notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final item = notifications[index];

                return NotificationCard(
                  notification: item,
                  onTap: () async {
                    try {
                      await ref
                          .read(notificationProvider.notifier)
                          .markAsRead(item.id);
                    } catch (error) {
                      AppToast.showError(_formatError(error));
                    }
                  },
                  onDelete: () async {
                    try {
                      await ref
                          .read(notificationProvider.notifier)
                          .deleteNotification(item.id);
                    } catch (error) {
                      AppToast.showError(_formatError(error));
                    }
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorState(ref, error),
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: AppSpacing.pageWithTop,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_off_rounded, size: 48),
            const SizedBox(height: AppSpacing.md),
            const Text('Không thể tải thông báo'),
            const SizedBox(height: AppSpacing.xs),
            Text(_formatError(error), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(notificationProvider.notifier).fetchNotifications();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}

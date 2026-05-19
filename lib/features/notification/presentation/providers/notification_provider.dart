import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/app_notification.dart';

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<AppNotification>>((ref) {
      return NotificationNotifier();
    });

class NotificationNotifier extends StateNotifier<List<AppNotification>> {
  NotificationNotifier()
    : super([
        AppNotification(
          id: 1,
          title: 'Lịch khám hôm nay',
          message: 'Bạn có lịch khám lúc 09:30 tại phòng A102.',
          time: '5 phút trước',
          isRead: false,
        ),
        AppNotification(
          id: 2,
          title: 'Kết quả xét nghiệm',
          message: 'Kết quả xét nghiệm của bạn đã sẵn sàng.',
          time: '1 giờ trước',
          isRead: false,
        ),
        AppNotification(
          id: 3,
          title: 'Thông báo hệ thống',
          message: 'Hệ thống bệnh viện đang hoạt động bình thường.',
          time: 'Hôm qua',
          isRead: true,
        ),
      ]);

  void markAsRead(int id) {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(isRead: true) else item,
    ];
  }

  void deleteNotification(int id) {
    state = state.where((item) => item.id != id).toList();
  }

  void markAllAsRead() {
    state = [for (final item in state) item.copyWith(isRead: true)];
  }
}

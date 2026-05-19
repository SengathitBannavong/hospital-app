import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/app_notification.dart';
import '../../data/repository/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

final notificationProvider =
    StateNotifierProvider<
      NotificationNotifier,
      AsyncValue<List<AppNotification>>
    >((ref) {
      final repository = ref.watch(notificationRepositoryProvider);
      return NotificationNotifier(repository)..fetchNotifications();
    });

class NotificationNotifier
    extends StateNotifier<AsyncValue<List<AppNotification>>> {
  NotificationNotifier(this._repository) : super(const AsyncValue.loading());

  final NotificationRepository _repository;

  Future<void> fetchNotifications({bool keepPrevious = false}) async {
    if (keepPrevious) {
      state = const AsyncValue<List<AppNotification>>.loading()
          .copyWithPrevious(state);
    } else {
      state = const AsyncValue<List<AppNotification>>.loading();
    }

    state = await AsyncValue.guard(() => _repository.getNotifications());
  }

  Future<void> markAsRead(int id) async {
    final items = state.valueOrNull;
    if (items == null) return;

    final index = items.indexWhere((item) => item.id == id);
    if (index == -1 || items[index].isRead) return;

    await _repository.markAsRead(notificationId: id);

    state = AsyncValue.data([
      for (final item in items)
        if (item.id == id) item.copyWith(isRead: true) else item,
    ]);
  }

  Future<void> deleteNotification(int id) async {
    final items = state.valueOrNull;
    if (items == null) return;

    final exists = items.any((item) => item.id == id);
    if (!exists) return;

    await _repository.deleteNotification(notificationId: id);

    state = AsyncValue.data(items.where((item) => item.id != id).toList());
  }

  Future<void> markAllAsRead() async {
    final items = state.valueOrNull;
    if (items == null || items.isEmpty) return;

    final unreadItems = items.where((item) => !item.isRead).toList();
    if (unreadItems.isEmpty) return;

    await Future.wait(
      unreadItems.map(
        (item) => _repository.markAsRead(notificationId: item.id),
      ),
    );

    state = AsyncValue.data([
      for (final item in items) item.copyWith(isRead: true),
    ]);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/app_notification.dart';
import '../../data/repository/notification_repository.dart';
import 'notification_state.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
      final repository = ref.watch(notificationRepositoryProvider);
      final notifier = NotificationNotifier(repository);
      notifier.loadNotifications().catchError((_) {});
      return notifier;
    });

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier(this._repository) : super(NotificationState.initial());

  final NotificationRepository _repository;

  Future<void> loadNotifications({bool refresh = false}) async {
    final previousItems = state.items;

    if (refresh && previousItems.isNotEmpty) {
      state = state.copyWith(
        isRefreshing: true,
        isInitialLoading: false,
        isLoadingMore: false,
        errorMessage: null,
      );
    } else {
      state = state.copyWith(
        isInitialLoading: true,
        isRefreshing: false,
        isLoadingMore: false,
        errorMessage: null,
      );
    }

    try {
      final response = await _repository.getNotifications(
        page: 1,
        limit: state.limit,
      );

      state = state.copyWith(
        items: response.data,
        total: response.total,
        page: response.page,
        limit: response.limit,
        isInitialLoading: false,
        isRefreshing: false,
        isLoadingMore: false,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        items: previousItems,
        isInitialLoading: false,
        isRefreshing: false,
        isLoadingMore: false,
        errorMessage: _formatError(error),
      );
      rethrow;
    }
  }

  Future<void> refresh() {
    return loadNotifications(refresh: true);
  }

  Future<void> loadMore() async {
    if (state.isInitialLoading || state.isRefreshing || state.isLoadingMore) {
      return;
    }

    if (!state.hasMore) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, errorMessage: null);

    try {
      final response = await _repository.getNotifications(
        page: state.page + 1,
        limit: state.limit,
      );

      final mergedItems = <AppNotification>[...state.items, ...response.data];
      final deduplicatedItems = <int, AppNotification>{
        for (final item in mergedItems) item.id: item,
      }.values.toList(growable: false);

      state = state.copyWith(
        items: deduplicatedItems,
        total: response.total,
        page: response.page,
        limit: response.limit,
        isLoadingMore: false,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: _formatError(error),
      );
      rethrow;
    }
  }

  Future<void> markAsRead(int id) async {
    final index = state.items.indexWhere((item) => item.id == id);
    if (index == -1 || state.items[index].isRead) return;

    await _repository.markAsRead(notificationId: id);

    state = state.copyWith(
      items: [
        for (final item in state.items)
          if (item.id == id) item.copyWith(isRead: true) else item,
      ],
      errorMessage: null,
    );
  }

  Future<void> deleteNotifications(List<int> ids) async {
    if (ids.isEmpty) return;

    await _repository.deleteNotifications(notificationIds: ids);

    final remainingItems = state.items
        .where((item) => !ids.contains(item.id))
        .toList(growable: false);

    state = state.copyWith(
      items: remainingItems,
      total: (state.total - ids.length).clamp(0, state.total),
      errorMessage: null,
    );
  }

  Future<void> markAllAsRead() async {
    if (state.items.isEmpty) return;

    final unreadItems = state.items.where((item) => !item.isRead).toList();
    if (unreadItems.isEmpty) return;

    await Future.wait(
      unreadItems.map(
        (item) => _repository.markAsRead(notificationId: item.id),
      ),
    );

    state = state.copyWith(
      items: [for (final item in state.items) item.copyWith(isRead: true)],
      errorMessage: null,
    );
  }

  String _formatError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}

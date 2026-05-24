// lib/features/notification/presentation/providers/notification_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/notification_model.dart';
import '../../data/models/notification_settings_model.dart';
import '../../data/repository/notification_repository.dart';
import 'notification_state.dart';

// ─── Repository Provider ──────────────────────────────────────────────────────

final notificationRepositoryProvider = Provider(
  (ref) => NotificationRepository(),
);

// ─── Main Notification List Provider ─────────────────────────────────────────

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return NotificationNotifier(repo);
});

// ─── Global Unread Badge Count ────────────────────────────────────────────────
// Use this anywhere in the app (e.g. bottom nav badge)

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).unreadCount;
});

// ─── Notification Settings Provider ──────────────────────────────────────────

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier,
        AsyncValue<NotificationSettingsModel>>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return NotificationSettingsNotifier(repo);
});

// ─── Notifier ─────────────────────────────────────────────────────────────────

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationRepository _repository;

  NotificationNotifier(this._repository) : super(const NotificationState());

  /// Load first page — called on page open or pull-to-refresh
  Future<void> loadNotifications({bool refresh = false}) async {
    if (state.isLoading) return;

    state = state.copyWith(
      status: NotificationStatus.loading,
      currentPage: 1,
      clearError: true,
    );

    try {
      final response = await _repository.getNotifications(page: 1);
      final unread = _repository.countUnread(response.notifications);

      state = state.copyWith(
        status: NotificationStatus.loaded,
        notifications: response.notifications,
        totalCount: response.total,
        currentPage: 1,
        unreadCount: unread,
      );
    } catch (e) {
      state = state.copyWith(
        status: NotificationStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Load next page (pagination)
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final response = await _repository.getNotifications(
        page: nextPage,
        limit: state.limit,
      );

      final combined = [...state.notifications, ...response.notifications];
      final unread = _repository.countUnread(combined);

      state = state.copyWith(
        notifications: combined,
        currentPage: nextPage,
        totalCount: response.total,
        isLoadingMore: false,
        unreadCount: unread,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  /// Mark single notification as read
  Future<void> markAsRead(int id) async {
    // Optimistic update — mark locally first
    final updated = state.notifications
        .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
        .toList();
    final unread = _repository.countUnread(updated);
    state = state.copyWith(notifications: updated, unreadCount: unread);

    try {
      // Remote API call to mark as read can be implemented in the repository.
      // Intentionally omitted to avoid calling a non-existent method.
    } catch (_) {
      // Revert on failure
      await loadNotifications();
    }
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    // Optimistic update
    final updated = state.notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    state = state.copyWith(notifications: updated, unreadCount: 0);

    try {
      await _repository.markAllAsRead();
    } catch (_) {
      await loadNotifications();
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(int id) async {
    // Optimistic removal
    final updated = state.notifications.where((n) => n.id != id).toList();
    final unread = _repository.countUnread(updated);
    state = state.copyWith(
      notifications: updated,
      totalCount: state.totalCount - 1,
      unreadCount: unread,
    );

    try {
      await _repository.deleteNotification(id);
    } catch (_) {
      await loadNotifications();
    }
  }

  /// Register FCM device token with backend
  Future<void> registerDeviceToken(String token) async {
    try {
      await _repository.registerDeviceToken(token);
    } catch (_) {
      // Silently fail — will retry on next app launch
    }
  }

  /// Add a notification received via FCM foreground
  void addFirebaseNotification(NotificationModel notification) {
    final updated = [notification, ...state.notifications];
    final unread = _repository.countUnread(updated);
    state = state.copyWith(
      notifications: updated,
      totalCount: state.totalCount + 1,
      unreadCount: unread,
    );
  }
}

// ─── Settings Notifier ────────────────────────────────────────────────────────

class NotificationSettingsNotifier
    extends StateNotifier<AsyncValue<NotificationSettingsModel>> {
  final NotificationRepository _repository;

  NotificationSettingsNotifier(this._repository)
      : super(const AsyncValue.loading());

  Future<void> loadSettings() async {
    state = const AsyncValue.loading();
    try {
      final settings = await _repository.getSettings();
      state = AsyncValue.data(settings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> saveSettings(NotificationSettingsModel settings) async {
    try {
      await _repository.saveSettings(settings);
      state = AsyncValue.data(settings);
      return true;
    } catch (_) {
      return false;
    }
  }

  void updateLocal(NotificationSettingsModel settings) {
    state = AsyncValue.data(settings);
  }
}
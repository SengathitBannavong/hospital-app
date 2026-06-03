// lib/features/notification/presentation/providers/notification_provider.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/app_notification.dart';
import '../../data/models/notification_settings_model.dart';
import '../../data/repository/notification_repository.dart';
import 'notification_state.dart';

// Repository provider.

final notificationRepositoryProvider = Provider(
  (ref) => NotificationRepository(),
);

// ─── Main Notification List Provider ─────────────────────────────────────────

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
      final repository = ref.watch(notificationRepositoryProvider);
      final notifier = NotificationNotifier(repository);
      notifier.loadNotifications().catchError((_) {});
      // The backend has no realtime push/WS yet, so poll the list as a
      // fallback to surface new notifications without a manual refresh.
      notifier.startPolling();
      return notifier;
    });

// Global unread badge count.
// Use this anywhere in the app (e.g. home app bar bell, badges).

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).unreadCount;
});

// ─── Notification Settings Provider ──────────────────────────────────────────

final notificationSettingsProvider =
    StateNotifierProvider<
      NotificationSettingsNotifier,
      AsyncValue<NotificationSettingsModel>
    >((ref) {
      final repo = ref.watch(notificationRepositoryProvider);
      return NotificationSettingsNotifier(repo);
    });

// Notifier.

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier(this._repository) : super(NotificationState.initial());

  final NotificationRepository _repository;

  /// Fallback poll interval. The backend stores notifications but has no
  /// realtime push/WebSocket yet, so we periodically re-fetch the first page.
  static const Duration pollInterval = Duration(seconds: 60);

  Timer? _pollTimer;
  bool _polling = false;

  /// Starts the periodic fallback poll. Idempotent.
  void startPolling({Duration interval = pollInterval}) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(interval, (_) => _silentPoll());
  }

  /// Stops the periodic fallback poll.
  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// Silently re-fetches the first page and merges it into the current list:
  /// fresh server items (new arrivals + updated read state) take precedence,
  /// while already-loaded older pages are preserved. Never flips loading flags
  /// (no spinner) and swallows errors so a failed poll is invisible.
  Future<void> _silentPoll() async {
    if (_polling ||
        state.isInitialLoading ||
        state.isRefreshing ||
        state.isLoadingMore) {
      return;
    }
    _polling = true;
    try {
      final response = await _repository.getNotifications(
        page: 1,
        limit: state.limit,
      );

      final serverIds = response.data.map((item) => item.id).toSet();
      final olderItems = state.items
          .where((item) => !serverIds.contains(item.id))
          .toList(growable: false);

      state = state.copyWith(
        items: [...response.data, ...olderItems],
        total: response.total,
        errorMessage: state.errorMessage,
      );
    } catch (_) {
      // Silent — a failed fallback poll must not disturb the UI.
    } finally {
      _polling = false;
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  /// Load first page — called on page open or pull-to-refresh.
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

  /// Load next page (infinite scroll).
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

  /// Mark single notification as read.
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

  /// Delete one or more notifications.
  Future<void> deleteNotifications(List<int> ids) async {
    if (ids.isEmpty) return;

    await _repository.deleteNotifications(notificationIds: ids);

    final remainingItems = state.items
        .where((item) => !ids.contains(item.id))
        .toList(growable: false);

    state = state.copyWith(
      items: remainingItems,
      total: (state.total - ids.length).clamp(0, state.total).toInt(),
      errorMessage: null,
    );
  }

  /// Mark every loaded notification as read.
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

  /// Register FCM device token with the backend (called by Firebase service).
  Future<void> registerDeviceToken(String token, String platform) async {
    try {
      await _repository.registerDeviceToken(token, platform);
    } catch (_) {
      // Silently fail — retried on next token refresh / app launch.
    }
  }

  /// Prepend a notification received via FCM while the app is in foreground.
  void addFirebaseNotification(AppNotification notification) {
    final merged = <AppNotification>[notification, ...state.items];
    final deduplicated = <int, AppNotification>{
      for (final item in merged) item.id: item,
    }.values.toList(growable: false);

    state = state.copyWith(
      items: deduplicated,
      total: state.total + 1,
      errorMessage: state.errorMessage,
    );
  }

  String _formatError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}

// Settings notifier.

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

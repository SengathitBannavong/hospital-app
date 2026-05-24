// lib/features/notification/presentation/providers/notification_state.dart

import '../../data/models/notification_model.dart';

enum NotificationStatus { initial, loading, loaded, error }

class NotificationState {
  final List<NotificationModel> notifications;
  final NotificationStatus status;
  final String? errorMessage;
  final int currentPage;
  final int totalCount;
  final int limit;
  final bool isLoadingMore;
  final int unreadCount;

  const NotificationState({
    this.notifications = const [],
    this.status = NotificationStatus.initial,
    this.errorMessage,
    this.currentPage = 1,
    this.totalCount = 0,
    this.limit = 20,
    this.isLoadingMore = false,
    this.unreadCount = 0,
  });

  bool get hasMore => (currentPage * limit) < totalCount;
  bool get isLoading => status == NotificationStatus.loading;

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    NotificationStatus? status,
    String? errorMessage,
    int? currentPage,
    int? totalCount,
    int? limit,
    bool? isLoadingMore,
    int? unreadCount,
    bool clearError = false,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      limit: limit ?? this.limit,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
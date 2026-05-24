import '../../data/models/app_notification.dart';

class NotificationState {
  const NotificationState({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.isInitialLoading,
    required this.isRefreshing,
    required this.isLoadingMore,
    required this.errorMessage,
  });

  factory NotificationState.initial({int limit = 20}) {
    return NotificationState(
      items: const <AppNotification>[],
      total: 0,
      page: 1,
      limit: limit,
      isInitialLoading: true,
      isRefreshing: false,
      isLoadingMore: false,
      errorMessage: null,
    );
  }

  final List<AppNotification> items;
  final int total;
  final int page;
  final int limit;
  final bool isInitialLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final String? errorMessage;

  bool get hasItems => items.isNotEmpty;
  bool get hasMore => items.length < total;
  bool get isEmpty => !isInitialLoading && items.isEmpty;

  NotificationState copyWith({
    List<AppNotification>? items,
    int? total,
    int? page,
    int? limit,
    bool? isInitialLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return NotificationState(
      items: items ?? this.items,
      total: total ?? this.total,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
    );
  }
}

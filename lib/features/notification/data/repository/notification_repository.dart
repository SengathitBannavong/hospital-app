import '../datasources/notification_remote_data_source.dart';
import '../models/notification_page_response.dart';

class NotificationRepository {
  NotificationRepository({NotificationRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? NotificationRemoteDataSource();

  final NotificationRemoteDataSource _remoteDataSource;

  Future<NotificationPageResponse> getNotifications({
    int page = 1,
    int limit = 20,
  }) {
    return _remoteDataSource.getNotifications(page: page, limit: limit);
  }

  Future<void> markAsRead({required int notificationId}) async {
    return _remoteDataSource.markAsRead(notificationId: notificationId);
  }

  Future<void> deleteNotifications({required List<int> notificationIds}) {
    return _remoteDataSource.deleteNotifications(
      notificationIds: notificationIds.map((id) => id.toString()).toList(),
    );
  }
}

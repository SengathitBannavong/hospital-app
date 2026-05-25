// lib/features/notification/data/repository/notification_repository.dart

import 'package:dio/dio.dart';
import 'package:hospital_app/core/network/api_client.dart';
import 'package:hospital_app/core/network/api_endpoints.dart';
import '../datasources/notification_remote_data_source.dart';
import '../models/notification_page_response.dart';
import '../models/notification_settings_model.dart';

class NotificationRepository {
  NotificationRepository({NotificationRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? NotificationRemoteDataSource();

  final NotificationRemoteDataSource _remoteDataSource;
  final Dio _dio = ApiClient.instance;

  // ── List / read / delete (paginated, via remote data source) ──────────────

  /// GET notification/get_list?page=&limit=
  Future<NotificationPageResponse> getNotifications({
    int page = 1,
    int limit = 20,
  }) {
    return _remoteDataSource.getNotifications(page: page, limit: limit);
  }

  /// POST notification/set_read { notif_id }
  Future<void> markAsRead({required int notificationId}) {
    return _remoteDataSource.markAsRead(notificationId: notificationId);
  }

  /// DELETE notification/delete { notif_id: [...] }
  Future<void> deleteNotifications({required List<int> notificationIds}) {
    return _remoteDataSource.deleteNotifications(
      notificationIds: notificationIds.map((id) => id.toString()).toList(),
    );
  }

  // ── Device token (Firebase push) ──────────────────────────────────────────

  /// POST user/set_devtoken
  Future<void> registerDeviceToken(String fcmToken, String platform) async {
    try {
      await _dio.post(
        ApiEndpoints.setDevToken,
        data: {'device_token': fcmToken, 'platform': platform},
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // ── Notification settings ─────────────────────────────────────────────────

  /// GET user/get_settings
  Future<NotificationSettingsModel> getSettings() async {
    try {
      final response = await _dio.get(ApiEndpoints.getSettings);
      return NotificationSettingsModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  /// POST user/set_settings
  Future<void> saveSettings(NotificationSettingsModel settings) async {
    try {
      await _dio.post(ApiEndpoints.setSettings, data: settings.toJson());
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  String _parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      return data['message']?.toString() ??
          data['error']?.toString() ??
          'An error occurred';
    }
    return e.message ?? 'An error occurred';
  }
}

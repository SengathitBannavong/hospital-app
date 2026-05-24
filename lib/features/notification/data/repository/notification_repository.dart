// lib/features/notification/data/repository/notification_repository.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hospital_app/core/network/api_client.dart';
import 'package:hospital_app/core/network/api_endpoints.dart';
import '../models/notification_model.dart';
import '../models/notification_list_response.dart';
import '../models/notification_settings_model.dart';

class NotificationRepository {
  final Dio _dio = ApiClient.instance;

  /// GET notification/get_list?page=1&limit=20
  Future<NotificationListResponse> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.notificationGetList,
        queryParameters: {'page': page, 'limit': limit},
      );
      debugPrint('NOTIFICATION RESPONSE: ${response.data}');
      return NotificationListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      debugPrint('NOTIFICATION ERROR: ${e.response?.data}');
      throw Exception(_parseError(e));
    }
  }

  /// POST notification/set_read  { notif_id: xxx }
  /// Backend repo uses notif_id as primary key
  Future<void> markAsRead(int notificationId) async {
    try {
      await _dio.post(
        ApiEndpoints.notificationSetRead,
        data: {'notif_id': notificationId},
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  /// Mark ALL as read
  Future<void> markAllAsRead() async {
    try {
      await _dio.post(
        ApiEndpoints.notificationSetRead,
        data: {'all': true},
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  /// DELETE notification/delete — JSON body { notif_id: xxx }
  Future<void> deleteNotification(int notificationId) async {
    try {
      await _dio.delete(
        ApiEndpoints.notificationDelete,
        data: {'notif_id': notificationId},
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  /// POST user/set_devtoken
  Future<void> registerDeviceToken(String fcmToken) async {
    try {
      await _dio.post(
        ApiEndpoints.setDevToken,
        data: {'token': fcmToken},
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

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
      await _dio.post(
        ApiEndpoints.setSettings,
        data: settings.toJson(),
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  /// Count unread from a loaded list
  int countUnread(List<NotificationModel> notifications) {
    return notifications.where((n) => !n.isRead).length;
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
import 'package:dio/dio.dart';
import 'package:hospital_app/core/network/api_client.dart';
import 'package:hospital_app/core/network/api_endpoints.dart';
import 'package:hospital_app/core/network/api_response_codes.dart';
import '../../../auth/data/models/auth_api_response.dart';
import '../models/app_notification.dart';

class NotificationRepository {
  Future<List<AppNotification>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.notificationGetList,
        queryParameters: {'page': page, 'limit': limit},
      );

      final apiResponse = AuthApiResponse<dynamic>.fromJson(
        response.data,
        (json) => json,
      );

      if (apiResponse.code == ApiResponseCodes.success) {
        final items = _extractNotificationList(apiResponse.data);
        return items.map(AppNotification.fromJson).toList();
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<void> markAsRead({required int notificationId}) async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.notificationSetRead,
        data: {'notif_id': notificationId},
      );

      final apiResponse = AuthApiResponse<dynamic>.fromJson(
        response.data,
        (json) => json,
      );

      if (apiResponse.code != ApiResponseCodes.success) {
        throw Exception(apiResponse.message);
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<void> deleteNotification({required int notificationId}) async {
    try {
      final response = await ApiClient.instance.delete(
        ApiEndpoints.notificationDelete,
        data: {'notif_id': notificationId},
      );

      final apiResponse = AuthApiResponse<dynamic>.fromJson(
        response.data,
        (json) => json,
      );

      if (apiResponse.code != ApiResponseCodes.success) {
        throw Exception(apiResponse.message);
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  List<Map<String, dynamic>> _extractNotificationList(Object? data) {
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }

    if (data is Map<String, dynamic>) {
      final candidates = [
        data['notifications'],
        data['items'],
        data['list'],
        data['data'],
      ];
      for (final candidate in candidates) {
        if (candidate is List) {
          return candidate.whereType<Map<String, dynamic>>().toList();
        }
      }
    }

    return [];
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      return e.response?.data['message'] ?? e.message ?? 'Unknown error';
    }
    return e.message ?? 'Unknown error';
  }
}

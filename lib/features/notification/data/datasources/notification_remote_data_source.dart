import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/api_response_codes.dart';
import '../../../../core/network/dio_exception_message.dart';
import '../models/delete_notification_request.dart';
import '../models/mark_notification_read_request.dart';
import '../models/notification_page_response.dart';

class NotificationRemoteDataSource {
  Future<NotificationPageResponse> getNotifications({
    required int page,
    required int limit,
  }) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.notificationGetList,
        queryParameters: {'page': page, 'limit': limit},
      );

      final apiResponse = ApiResponse<NotificationPageResponse>.fromJson(
        response.data as Map<String, dynamic>,
        (json) =>
            NotificationPageResponse.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.code == ApiResponseCodes.success &&
          apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw Exception(apiResponse.message);
    } on DioException catch (error) {
      throw Exception(extractDioExceptionMessage(error));
    }
  }

  Future<void> markAsRead({required int notificationId}) async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.notificationSetRead,
        data: MarkNotificationReadRequest(
          notificationId: notificationId,
        ).toJson(),
      );

      final apiResponse = ApiResponse<dynamic>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json,
      );

      if (apiResponse.code != ApiResponseCodes.success) {
        throw Exception(apiResponse.message);
      }
    } on DioException catch (error) {
      throw Exception(extractDioExceptionMessage(error));
    }
  }

  Future<void> deleteNotification({required int notificationId}) async {
    try {
      final response = await ApiClient.instance.delete(
        ApiEndpoints.notificationDelete,
        data: DeleteNotificationRequest(
          notificationId: notificationId,
        ).toJson(),
        options: Options(contentType: Headers.jsonContentType),
      );

      final apiResponse = ApiResponse<dynamic>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json,
      );

      if (apiResponse.code != ApiResponseCodes.success) {
        throw Exception(apiResponse.message);
      }
    } on DioException catch (error) {
      throw Exception(extractDioExceptionMessage(error));
    }
  }
}

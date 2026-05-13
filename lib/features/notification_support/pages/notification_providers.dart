import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/core/network/api_client.dart';
import 'package:hospital_app/core/network/api_endpoints.dart';
import 'package:hospital_app/core/network/api_response_codes.dart';
import 'package:hospital_app/core/network/models/api_response.dart';
import '../models/notification_item.dart';
import '../models/support_requests.dart';
import '../models/notification_action_requests.dart';

// Provider để lấy danh sách thông báo (Notifications)
// GET /api/notification/get_list
final notificationsProvider = FutureProvider<NotificationList>((ref) async {
  final response = await ApiClient.instance.get(ApiEndpoints.getNotifications);
  
  final apiResponse = ApiResponse<NotificationList>.fromJson(
    response.data,
    (json) => NotificationList.fromJson(json as Map<String, dynamic>),
  );

  if (apiResponse.code == ApiResponseCodes.success && apiResponse.data != null) {
    return apiResponse.data!;
  }
  throw Exception(apiResponse.message);
});

// Service cho các hành động Thông báo & Hỗ trợ
final notificationSupportServiceProvider = Provider((ref) => NotificationSupportService());

class NotificationSupportService {
  // Hàm đánh dấu đã đọc (Set Notification Read)
  // POST /api/notification/set_read
  Future<void> setRead(int notifId) async {
    final response = await ApiClient.instance.post(
      ApiEndpoints.setNotificationRead,
      data: NotificationActionRequest(notifId: notifId).toJson(),
    );
    
    final apiResponse = ApiResponse<dynamic>.fromJson(response.data, (json) => json);
    if (apiResponse.code != ApiResponseCodes.success) {
      throw Exception(apiResponse.message);
    }
  }

  // Hàm xóa thông báo (Delete Notification)
  // DELETE /api/notification/delete
  Future<void> deleteNotification(int notifId) async {
    final response = await ApiClient.instance.delete(
      ApiEndpoints.deleteNotification,
      data: NotificationActionRequest(notifId: notifId).toJson(),
    );
    
    final apiResponse = ApiResponse<dynamic>.fromJson(response.data, (json) => json);
    if (apiResponse.code != ApiResponseCodes.success) {
      throw Exception(apiResponse.message);
    }
  }

  // Hàm tạo yêu cầu SOS (Create SOS)
  // POST /api/sos/create
  Future<void> createSos({double? lat, double? lng, String? note}) async {
    final response = await ApiClient.instance.post(
      ApiEndpoints.createSos,
      data: SosRequest(lat: lat, lng: lng, note: note).toJson(),
    );
    
    final apiResponse = ApiResponse<dynamic>.fromJson(response.data, (json) => json);
    if (apiResponse.code != ApiResponseCodes.success) {
      throw Exception(apiResponse.message);
    }
  }

  // Hàm tạo phòng Chat (Create Chat Room)
  // POST /api/chat/create_room
  Future<void> createChatRoom(int? targetUserId) async {
    final response = await ApiClient.instance.post(
      ApiEndpoints.createChatRoom,
      data: ChatRoomRequest(targetUserId: targetUserId).toJson(),
    );
    
    final apiResponse = ApiResponse<dynamic>.fromJson(response.data, (json) => json);
    if (apiResponse.code != ApiResponseCodes.success) {
      throw Exception(apiResponse.message);
    }
  }
}

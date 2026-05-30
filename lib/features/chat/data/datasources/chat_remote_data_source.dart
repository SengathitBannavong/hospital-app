import 'package:dio/dio.dart';
import 'package:hospital_app/core/network/api_client.dart';
import 'package:hospital_app/core/network/api_endpoints.dart';
import 'package:hospital_app/core/network/api_response.dart';
import 'package:hospital_app/core/network/api_response_codes.dart';
import '../models/chat_room.dart';
import '../models/chat_message.dart';
import '../models/chat_participants.dart';

class ChatRemoteDataSource {
  final Dio _dio = ApiClient.instance;

  Future<List<ChatRoom>> getRooms({int page = 1, int limit = 50}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.chatGetRooms,
        queryParameters: {'page': page, 'limit': limit},
      );
      final apiResponse = ApiResponse<List<ChatRoom>>.fromJson(response.data, (
        json,
      ) {
        List<dynamic> toList(Object? raw) {
          if (raw is List) return raw;
          if (raw is Map<String, dynamic>) {
            final nested = raw['rooms'] ?? raw['data'];
            if (nested is List) return nested;
          }
          return const [];
        }

        return toList(
          json,
        ).whereType<Map<String, dynamic>>().map(ChatRoom.fromJson).toList();
      });
      if (apiResponse.code == ApiResponseCodes.success) {
        return apiResponse.data ?? [];
      }
      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // Backend: POST /chat/create_room
  // Body: { "staff_id": X, "user_id": Y?, "topic": "..."? }
  Future<void> createRoom({
    required int staffId,
    int? userId,
    String topic = '',
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.chatCreateRoom,
        data: <String, dynamic>{
          'staff_id': staffId,
          if (userId case final int userId) 'user_id': userId,
          if (topic.isNotEmpty) 'topic': topic,
        },
      );
      final apiResponse = ApiResponse<dynamic>.fromJson(
        response.data,
        (json) => json,
      );
      if (apiResponse.code != ApiResponseCodes.success) {
        throw Exception(apiResponse.message);
      }
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // Backend: GET /chat/get_messages?conversation_id=X&page=Y&limit=Z
  Future<List<ChatMessage>> getMessages({
    required int conversationId,
    int page = 1,
    int limit = 30,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.chatGetMessages,
        queryParameters: {
          'conversation_id': conversationId,
          'page': page,
          'limit': limit,
        },
      );
      final apiResponse = ApiResponse<List<ChatMessage>>.fromJson(
        response.data,
        (json) {
          List<dynamic> toList(Object? raw) {
            if (raw is List) return raw;
            if (raw is Map<String, dynamic>) {
              final nested = raw['messages'] ?? raw['data'];
              if (nested is List) return nested;
            }
            return const [];
          }

          return toList(json)
              .whereType<Map<String, dynamic>>()
              .map(ChatMessage.fromJson)
              .toList();
        },
      );
      if (apiResponse.code == ApiResponseCodes.success) {
        return apiResponse.data ?? [];
      }
      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // Backend: GET /chat/participants
  // Response data: { "patients": [...], "staffs": [...] }
  Future<ChatParticipants> getParticipants() async {
    try {
      final response = await _dio.get(ApiEndpoints.chatParticipants);
      final apiResponse = ApiResponse<ChatParticipants>.fromJson(
        response.data,
        (json) => ChatParticipants.fromJson(json as Map<String, dynamic>),
      );
      if (apiResponse.code == ApiResponseCodes.success &&
          apiResponse.data != null) {
        return apiResponse.data!;
      }
      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // Backend: POST /chat/send_message
  // Body: { "conversation_id": X, "type": "...", "text_content": "...",
  // "media_url": "..." }
  Future<ChatMessage> sendMessage({
    required int conversationId,
    String content = '',
    String type = 'text',
    String mediaUrl = '',
  }) async {
    if (content.trim().isEmpty && mediaUrl.trim().isEmpty) {
      throw Exception('Nội dung tin nhắn không được để trống');
    }

    try {
      final response = await _dio.post(
        ApiEndpoints.chatSendMessage,
        data: {
          'conversation_id': conversationId,
          'type': type,
          if (content.trim().isNotEmpty) 'text_content': content.trim(),
          if (mediaUrl.trim().isNotEmpty) 'media_url': mediaUrl.trim(),
        },
      );
      final apiResponse = ApiResponse<ChatMessage>.fromJson(
        response.data,
        (json) => ChatMessage.fromJson(json as Map<String, dynamic>),
      );
      if (apiResponse.code == ApiResponseCodes.success &&
          apiResponse.data != null) {
        return apiResponse.data!;
      }
      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // Backend: POST /chat/mark_read
  // Body: { "conversation_id": X }
  Future<void> markRead({required int conversationId}) async {
    try {
      await _dio.post(
        ApiEndpoints.chatMarkRead,
        data: {'conversation_id': conversationId},
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  // Backend: POST /chat/close_room
  // Body: { "conversation_id": X }
  Future<void> closeRoom({required int conversationId}) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.chatCloseRoom,
        data: {'conversation_id': conversationId},
      );
      final apiResponse = ApiResponse<dynamic>.fromJson(
        response.data,
        (json) => json,
      );
      if (apiResponse.code != ApiResponseCodes.success) {
        throw Exception(apiResponse.message);
      }
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  String _parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      return data['message']?.toString() ??
          data['error']?.toString() ??
          'Lỗi kết nối';
    }
    return e.message ?? 'Lỗi kết nối';
  }
}

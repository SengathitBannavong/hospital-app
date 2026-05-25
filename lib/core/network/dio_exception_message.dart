import 'package:dio/dio.dart';

String extractDioExceptionMessage(DioException error) {
  final responseData = error.response?.data;

  if (responseData is Map<String, dynamic>) {
    final message = responseData['message'];
    if (message != null && message.toString().isNotEmpty) {
      return message.toString();
    }

    final errorMessage = responseData['error'];
    if (errorMessage != null && errorMessage.toString().isNotEmpty) {
      return errorMessage.toString();
    }
  }

  return error.message ?? 'Unknown error';
}

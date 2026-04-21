import 'package:dio/dio.dart';
import 'package:hospital_app/core/network/api_response_codes.dart';
import 'package:hospital_app/core/utils/app_toast.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage = _mapDioExceptionToMessage(err);

    // Handle global status code actions
    final statusCode = err.response?.statusCode;
    if (statusCode == ApiResponseCodes.httpUnauthorized) {
      AppToast.showWarning("Unauthorized - 401: Trigger logout logic");
    } else if (statusCode == ApiResponseCodes.httpForbidden) {
      AppToast.showWarning("Forbidden - 403: Handle permission issues");
    } else if (statusCode == ApiResponseCodes.httpInternalServerError) {
      AppToast.showWarning(
        "Internal Server Error - 500: Display a general error message",
      );
    }

    // Could wrap the error in a custom Exception class before passing it along
    return handler.next(err.copyWith(message: errorMessage));
  }

  String _mapDioExceptionToMessage(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout with server';
      case DioExceptionType.sendTimeout:
        return 'Send timeout in connection with server';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout in connection with server';
      case DioExceptionType.badResponse:
        return _mapStatusCodeToMessage(dioException.response?.statusCode);
      case DioExceptionType.cancel:
        return 'Request to server was cancelled';
      case DioExceptionType.connectionError:
        return 'No internet connection';
      case DioExceptionType.unknown:
        return 'Unexpected error occurred';
      default:
        return 'Something went wrong';
    }
  }

  String _mapStatusCodeToMessage(int? statusCode) {
    if (statusCode == ApiResponseCodes.httpBadRequest) {
      return 'Bad request';
    } else if (statusCode == ApiResponseCodes.httpUnauthorized) {
      return 'Unauthorized access';
    } else if (statusCode == ApiResponseCodes.httpForbidden) {
      return 'Access forbidden';
    } else if (statusCode == ApiResponseCodes.httpNotFound) {
      return 'Resource not found';
    } else if (statusCode == ApiResponseCodes.httpInternalServerError) {
      return 'Internal server error';
    } else {
      return 'Received invalid status code: $statusCode';
    }
  }
}

import 'package:dio/dio.dart';
import 'package:hospital_app/core/utils/app_toast.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage = _mapDioExceptionToMessage(err);

    // Handle global status code actions
    if (err.response?.statusCode == 401) {
      AppToast.showWarning("Unauthorized - 401: Trigger logout logic");
    } else if (err.response?.statusCode == 403) {
      AppToast.showWarning("Forbidden - 403: Handle permission issues");
    } else if (err.response?.statusCode == 500) {
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
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized access';
      case 403:
        return 'Access forbidden';
      case 404:
        return 'Resource not found';
      case 500:
        return 'Internal server error';
      default:
        return 'Received invalid status code: $statusCode';
    }
  }
}

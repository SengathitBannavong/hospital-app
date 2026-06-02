import 'dart:async';

import 'package:dio/dio.dart';
import 'package:hospital_app/core/network/api_response_codes.dart';
import 'package:hospital_app/core/network/session_manager.dart';
import 'package:hospital_app/core/network/token_repository.dart';
import 'package:hospital_app/core/utils/app_toast.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage =
        _extractServerMessage(err) ?? _mapDioExceptionToMessage(err);

    // Handle global status code actions
    final statusCode = err.response?.statusCode;
    if (_isSessionRejected(err)) {
      // The token was rejected — most often because the account logged in from
      // another device (server invalidates the old session), or the token
      // expired. Force a logout so the user is bounced back to login.
      unawaited(_handleSessionRejected(err));
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

  // A rejected token shows up either as HTTP 401, or as one of the custom
  // session/token codes in the {code,message,data} body.
  bool _isSessionRejected(DioException err) {
    if (err.response?.statusCode == ApiResponseCodes.httpUnauthorized) {
      return true;
    }
    final code = _extractBodyCode(err);
    return code == ApiResponseCodes.invalidToken ||
        code == ApiResponseCodes.tokenInvalid ||
        code == ApiResponseCodes.tokenExpired ||
        code == ApiResponseCodes.userNotAuthenticated;
  }

  Future<void> _handleSessionRejected(DioException err) async {
    // Only force a logout if we actually held a session, so a 401 during the
    // login request itself (bad credentials) doesn't show a misleading message.
    if (!await TokenRepository.hasToken()) return;
    final loggedOut = await SessionManager.forceLogout();
    if (loggedOut) {
      AppToast.showWarning(
        _extractServerMessage(err) ??
            'Phiên đăng nhập đã kết thúc. Vui lòng đăng nhập lại.',
      );
    }
  }

  int? _extractBodyCode(DioException err) {
    final data = err.response?.data;
    if (data is Map) {
      final code = data['code'];
      if (code is int) return code;
      return int.tryParse(code?.toString() ?? '');
    }
    return null;
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

  String? _extractServerMessage(DioException dioException) {
    final data = dioException.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }
    return null;
  }
}

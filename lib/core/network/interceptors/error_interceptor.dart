import 'dart:async';

import 'package:dio/dio.dart';
import 'package:hospital_app/core/l10n/locale_controller.dart';
import 'package:hospital_app/core/network/api_response_codes.dart';
import 'package:hospital_app/core/network/session_manager.dart';
import 'package:hospital_app/core/network/token_repository.dart';
import 'package:hospital_app/core/utils/app_toast.dart';

class ErrorInterceptor extends Interceptor {
  // Token/session-rejection codes carried in the {code,message,data} body.
  // 3009 = account logged in on another device (only one active JWT per user).
  static const _sessionRejectedCodes = <int>{
    ApiResponseCodes.invalidToken,
    ApiResponseCodes.tokenInvalid,
    ApiResponseCodes.tokenExpired,
    ApiResponseCodes.userNotAuthenticated,
    ApiResponseCodes.accountLoggedInElsewhere,
  };

  // This backend wraps most responses as HTTP 200 + {code,...}, so a rejected
  // token (e.g. 3009) arrives as a *success* HTTP response with an error code —
  // it never reaches onError. Inspect every response body for a session code.
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final code = _bodyCode(response.data);
    if (code != null && _sessionRejectedCodes.contains(code)) {
      unawaited(_handleSessionRejected(code, _bodyMessage(response.data)));
    }
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage =
        _extractServerMessage(err) ?? _mapDioExceptionToMessage(err);

    // Handle global status code actions
    final statusCode = err.response?.statusCode;
    final bodyCode = _bodyCode(err.response?.data);
    if (statusCode == ApiResponseCodes.httpUnauthorized ||
        (bodyCode != null && _sessionRejectedCodes.contains(bodyCode))) {
      // The token was rejected — most often because the account logged in from
      // another device (server invalidates the old session), or the token
      // expired. Force a logout so the user is bounced back to login.
      unawaited(_handleSessionRejected(bodyCode, _extractServerMessage(err)));
    } else if (statusCode == ApiResponseCodes.httpForbidden) {
      AppToast.showWarning(appL10n.errAccessDenied);
    } else if (statusCode == ApiResponseCodes.httpInternalServerError) {
      AppToast.showWarning(appL10n.errServer);
    }

    // Could wrap the error in a custom Exception class before passing it along
    return handler.next(err.copyWith(message: errorMessage));
  }

  Future<void> _handleSessionRejected(int? code, String? serverMessage) async {
    // Only force a logout if we actually held a session, so a 401 during the
    // login request itself (bad credentials) doesn't show a misleading message.
    if (!await TokenRepository.hasToken()) return;
    final loggedOut = await SessionManager.forceLogout();
    if (loggedOut) {
      AppToast.showWarning(_sessionMessage(code, serverMessage));
    }
  }

  String _sessionMessage(int? code, String? serverMessage) {
    if (code == ApiResponseCodes.accountLoggedInElsewhere) {
      return appL10n.errAccountElsewhere;
    }
    return serverMessage ?? appL10n.errSessionEnded;
  }

  int? _bodyCode(dynamic data) {
    if (data is Map) {
      final code = data['code'];
      if (code is int) return code;
      return int.tryParse(code?.toString() ?? '');
    }
    return null;
  }

  String? _bodyMessage(dynamic data) {
    if (data is Map) {
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) return message;
    }
    return null;
  }

  String _mapDioExceptionToMessage(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return appL10n.errTimeout;
      case DioExceptionType.badResponse:
        return _mapStatusCodeToMessage(dioException.response?.statusCode);
      case DioExceptionType.cancel:
        return appL10n.errCancelled;
      case DioExceptionType.connectionError:
        return appL10n.errNoNetwork;
      case DioExceptionType.unknown:
        return appL10n.assetGenericError;
      default:
        return appL10n.assetGenericError;
    }
  }

  String _mapStatusCodeToMessage(int? statusCode) {
    if (statusCode == ApiResponseCodes.httpBadRequest) {
      return appL10n.errBadRequest;
    } else if (statusCode == ApiResponseCodes.httpUnauthorized) {
      return appL10n.errSessionEnded;
    } else if (statusCode == ApiResponseCodes.httpForbidden) {
      return appL10n.errAccessDenied;
    } else if (statusCode == ApiResponseCodes.httpNotFound) {
      return appL10n.errDataNotFound;
    } else if (statusCode == ApiResponseCodes.httpInternalServerError) {
      return appL10n.errServer;
    } else {
      return appL10n.assetGenericError;
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

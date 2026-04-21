import 'package:dio/dio.dart';
import 'package:hospital_app/core/network/api_client.dart';
import 'package:hospital_app/core/network/api_endpoints.dart';
import 'package:hospital_app/core/network/api_response_codes.dart';
import '../domain/models/auth_api_response.dart';
import '../domain/models/auth_user.dart';
import '../domain/models/otp_response.dart';

class AuthRepository {
  // Login with phone and password
  Future<AuthUser> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.login,
        data: {'phone_number': phoneNumber, 'password': password},
      );

      final apiResponse = AuthApiResponse<AuthUser>.fromJson(
        response.data,
        (json) => AuthUser.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.code == ApiResponseCodes.success && apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  // Signup triggers OTP
  Future<OtpResponse> signup({
    required String phoneNumber,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.signup,
        data: {
          'phone_number': phoneNumber,
          'password': password,
          'full_name': fullName,
        },
      );

      final apiResponse = AuthApiResponse<OtpResponse>.fromJson(
        response.data,
        (json) => OtpResponse.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.code == ApiResponseCodes.success && apiResponse.data != null) {
        return apiResponse.data!;
      }
      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  // Verify OTP for Signup or Reset Password
  Future<void> verifyOtp({
    required String phoneNumber,
    required String otp,
    String? otpType,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.verifyOtp,
        data: {
          'phone_number': phoneNumber,
          'otp': otp,
          if (otpType != null) 'otp_type': otpType,
        },
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

  // Resend OTP verification code
  Future<void> resendOtp({
    required String phoneNumber,
    String? otpType,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.resendOtp,
        data: {
          'phone_number': phoneNumber,
          if (otpType != null) 'otp_type': otpType,
        },
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

  // Request password reset OTP
  Future<OtpResponse> forgotPassword(String phoneNumber) async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.forgotPassword,
        data: {'phone_number': phoneNumber},
      );

      final apiResponse = AuthApiResponse<OtpResponse>.fromJson(
        response.data,
        (json) => OtpResponse.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.code == ApiResponseCodes.success && apiResponse.data != null) {
        return apiResponse.data!;
      }
      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  // Reset password with OTP
  Future<void> resetPassword({
    required String phoneNumber,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.resetPassword,
        data: {
          'phone_number': phoneNumber,
          'otp': otp,
          'new_password': newPassword,
        },
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

  // Helper to extract error message from DioException
  String _extractErrorMessage(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      return e.response?.data['message'] ?? e.message ?? 'Unknown error';
    }
    return e.message ?? 'Unknown error';
  }
}

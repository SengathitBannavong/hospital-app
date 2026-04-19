import 'package:dio/dio.dart';
import 'package:hospital_app/core/network/api_client.dart';
import 'package:hospital_app/core/network/api_endpoints.dart';

import 'mock_auth_credentials.dart';

class AuthRepository {
  Future<String> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.login,
        data: {'phone_number': phoneNumber, 'password': password},
      );

      final token = _extractToken(response.data);
      if (token != null && token.isNotEmpty) {
        return token;
      }

      if (_isMockLogin(phoneNumber, password)) {
        return MockAuthCredentials.jwtToken;
      }

      throw Exception('Login response did not include a token.');
    } on DioException catch (error) {
      if (_isMockLogin(phoneNumber, password)) {
        return MockAuthCredentials.jwtToken;
      }

      final responseMessage = _extractErrorMessage(error.response?.data);
      throw Exception(
        responseMessage ?? error.message ?? 'Login request failed.',
      );
    }
  }

  bool _isMockLogin(String phoneNumber, String password) {
    return phoneNumber == MockAuthCredentials.phoneNumber &&
        password == MockAuthCredentials.password;
  }

  String? _extractToken(dynamic data) {
    if (data is Map<String, dynamic>) {
      const tokenKeys = [
        'token',
        'access_token',
        'jwt',
        'jwt_token',
        'auth_token',
      ];

      for (final key in tokenKeys) {
        final value = data[key];
        if (value is String && value.isNotEmpty) {
          return value;
        }
      }
    }

    return null;
  }

  String? _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    if (data is String && data.isNotEmpty) {
      return data;
    }

    return null;
  }
}

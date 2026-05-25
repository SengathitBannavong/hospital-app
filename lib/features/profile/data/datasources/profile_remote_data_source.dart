import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/api_response_codes.dart';
import '../../../../core/network/dio_exception_message.dart';
import '../models/profile_update_request.dart';
import '../models/user_profile.dart';

class ProfileRemoteDataSource {
  Future<UserProfile> getProfile() async {
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.getProfile);

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.code == ApiResponseCodes.success &&
          apiResponse.data != null) {
        return UserProfile.fromJson(apiResponse.data!);
      }

      throw Exception(apiResponse.message);
    } on DioException catch (error) {
      throw Exception(extractDioExceptionMessage(error));
    }
  }

  Future<UserProfile> updateProfile(ProfileUpdateRequest request) async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.setProfile,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.code == ApiResponseCodes.success &&
          apiResponse.data != null) {
        return UserProfile.fromJson(apiResponse.data!);
      }

      throw Exception(apiResponse.message);
    } on DioException catch (error) {
      throw Exception(extractDioExceptionMessage(error));
    }
  }
}

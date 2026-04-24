import 'package:dio/dio.dart';
import 'package:hospital_app/core/network/api_client.dart';
import 'package:hospital_app/core/network/api_endpoints.dart';
import 'package:hospital_app/core/network/api_response_codes.dart';
import '../../../auth/domain/models/auth_api_response.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepository implements IProfileRepository {
  @override
  Future<UserProfile> getProfile() async {
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.getProfile);

      final apiResponse = AuthApiResponse<UserProfile>.fromJson(
        response.data,
        (json) => UserProfile.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.code == ApiResponseCodes.success &&
          apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  @override
  Future<UserProfile> updateProfile({
    String? fullName,
    String? dob,
    int? gender,
    String? avatarPath,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'full_name': fullName,
        'dob': dob,
        'gender': gender,
      };

      if (avatarPath != null) {
        data['avatar'] = await MultipartFile.fromFile(avatarPath);
      }

      final response = await ApiClient.instance.post(
        ApiEndpoints.setProfile,
        data: FormData.fromMap(data),
      );

      final apiResponse = AuthApiResponse<UserProfile>.fromJson(
        response.data,
        (json) => UserProfile.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.code == ApiResponseCodes.success &&
          apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data is Map<String, dynamic>) {
      return e.response?.data['message'] ?? e.message ?? 'Unknown error';
    }
    return e.message ?? 'Unknown error';
  }
}

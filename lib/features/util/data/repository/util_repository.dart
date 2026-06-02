import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hospital_app/core/network/api_client.dart';
import 'package:hospital_app/core/network/api_endpoints.dart';
import 'package:hospital_app/core/network/api_response_codes.dart';
import 'package:hospital_app/features/auth/data/models/auth_api_response.dart';
import 'package:hospital_app/features/util/data/models/about_info.dart';
import 'package:hospital_app/features/util/data/models/contact_info.dart';
import 'package:hospital_app/features/util/data/models/faq_item.dart';
import 'package:hospital_app/features/util/data/models/feedback_summary.dart';
import 'package:hospital_app/features/util/data/models/language_option.dart';
import 'package:hospital_app/features/util/data/models/upload_result.dart';
import 'package:hospital_app/features/util/data/models/util_feedback_response.dart';
import 'package:hospital_app/features/util/data/models/util_version_check.dart';
import 'package:hospital_app/features/util/data/models/weather.dart';

class UtilRepository {
  final Dio _dio = ApiClient.instance;

  Future<List<FaqItem>> getFaq({String? category}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.utilFaq,
        queryParameters: {
          if (category != null && category.isNotEmpty) 'category': category,
        },
      );
      final apiResponse = AuthApiResponse<List<FaqItem>>.fromJson(
        response.data,
        (json) => (json as List<dynamic>)
            .map((item) => FaqItem.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
      return _requireSuccess(apiResponse);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<FeedbackSummary> getFeedbackSummary() async {
    try {
      final response = await _dio.get(ApiEndpoints.utilFeedbackSummary);
      final apiResponse = AuthApiResponse<FeedbackSummary>.fromJson(
        response.data,
        (json) => FeedbackSummary.fromJson(json as Map<String, dynamic>),
      );
      return _requireSuccess(apiResponse);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<UtilVersionCheck> checkVersion({
    required String platform,
    required String code,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.utilCheckVersion,
        queryParameters: {'platform': platform, 'code': code},
      );
      final apiResponse = AuthApiResponse<UtilVersionCheck>.fromJson(
        response.data,
        (json) => UtilVersionCheck.fromJson(json as Map<String, dynamic>),
      );
      return _requireSuccess(apiResponse);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<List<LanguageOption>> getLanguages() async {
    try {
      final response = await _dio.get(ApiEndpoints.utilLanguages);
      final apiResponse = AuthApiResponse<List<LanguageOption>>.fromJson(
        response.data,
        (json) => (json as List<dynamic>)
            .map(
              (item) => LanguageOption.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
      );
      return _requireSuccess(apiResponse);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<AboutInfo> getAbout() async {
    try {
      final response = await _dio.get(ApiEndpoints.utilAbout);
      final apiResponse = AuthApiResponse<AboutInfo>.fromJson(
        response.data,
        (json) => AboutInfo.fromJson(json as Map<String, dynamic>),
      );
      return _requireSuccess(apiResponse);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<ContactInfo> getContact() async {
    try {
      final response = await _dio.get(ApiEndpoints.utilContact);
      final apiResponse = AuthApiResponse<ContactInfo>.fromJson(
        response.data,
        (json) => ContactInfo.fromJson(json as Map<String, dynamic>),
      );
      return _requireSuccess(apiResponse);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<Weather> getWeather() async {
    try {
      final response = await _dio.get(ApiEndpoints.utilWeather);
      final apiResponse = AuthApiResponse<Weather>.fromJson(
        response.data,
        (json) => Weather.fromJson(json as Map<String, dynamic>),
      );
      return _requireSuccess(apiResponse);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<UtilFeedbackResponse> sendFeedback({
    required int rating,
    required String comment,
    required List<String> images,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.utilFeedback,
        // Backend contract: `images` is a stringified JSON array, not a real
        // JSON array. Sending a real List<String> returns "request body
        // invalid".
        data: {
          'rating': rating,
          'comment': comment,
          'images': jsonEncode(images),
        },
      );
      final apiResponse = AuthApiResponse<UtilFeedbackResponse>.fromJson(
        response.data,
        (json) => UtilFeedbackResponse.fromJson(json as Map<String, dynamic>),
      );
      return _requireSuccess(apiResponse);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<UploadResult> uploadFile(MultipartFile file) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.utilUpload,
        data: FormData.fromMap({'file': file}),
      );
      final apiResponse = AuthApiResponse<UploadResult>.fromJson(
        response.data,
        (json) => UploadResult.fromJson(json as Map<String, dynamic>),
      );
      return _requireSuccess(apiResponse);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  T _requireSuccess<T>(AuthApiResponse<T> apiResponse) {
    if (apiResponse.code == ApiResponseCodes.success &&
        apiResponse.data != null) {
      return apiResponse.data as T;
    }
    throw Exception(apiResponse.message);
  }

  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ??
          data['error']?.toString() ??
          e.message ??
          'Đã xảy ra lỗi';
    }
    return e.message ?? 'Đã xảy ra lỗi';
  }
}

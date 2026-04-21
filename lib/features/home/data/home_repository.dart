import 'package:dio/dio.dart';
import 'package:hospital_app/core/network/api_client.dart';
import 'package:hospital_app/core/network/api_endpoints.dart';

class HomeRepository {
  Future<List<dynamic>> getTasks() async {
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.getTasks);

      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        return data['data'] as List<dynamic>;
      }

      return [];
    } on DioException catch (error) {
      throw Exception(
        error.response?.data?['message'] ??
            error.message ??
            'Failed to fetch tasks.',
      );
    }
  }
}

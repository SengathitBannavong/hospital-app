import 'package:dio/dio.dart';
import 'package:hospital_app/core/network/api_client.dart';
import 'package:hospital_app/core/network/api_endpoints.dart';

class HomeRepository {
  Future<List<dynamic>> getTasks() async {
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.getTasks);

      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        return _dedupeTasks(data['data'] as List<dynamic>);
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

  /// Drops duplicate appointments so the home badge count stays stable.
  ///
  /// The backend `sync_now` is non-idempotent and appends fresh rows on every
  /// sync; duplicates share content (poi + task) but have distinct
  /// `treatment_id`s, so we key on the content signature. Mirrors the dedupe
  /// in `MedicalRepository.getTasks` so the badge and the task list agree.
  List<dynamic> _dedupeTasks(List<dynamic> tasks) {
    final seen = <String>{};
    final unique = <dynamic>[];
    for (final task in tasks) {
      if (task is Map) {
        final key =
            '${task['poi_id']}|${task['task_type']}|${task['task_name']}';
        if (!seen.add(key)) {
          continue;
        }
      }
      unique.add(task);
    }
    return unique;
  }
}

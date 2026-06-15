import 'package:dio/dio.dart';
import 'package:hospital_app/core/l10n/locale_controller.dart';
import 'package:hospital_app/core/network/api_client.dart';
import 'package:hospital_app/core/network/api_endpoints.dart';
import 'package:hospital_app/core/network/api_response_codes.dart';
import 'package:hospital_app/features/auth/data/models/auth_api_response.dart';

class StaffRepository {
  final Dio _dio = ApiClient.instance;

  Future<void> requestStaff({
    required String nodeId,
    String? assetId,
    String? note,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.staffRequestStaff,
        data: {
          'node_id': nodeId,
          if (assetId != null && assetId.isNotEmpty) 'asset_id': assetId,
          if (note != null && note.isNotEmpty) 'note': note,
        },
      );
      final api = AuthApiResponse<dynamic>.fromJson(
        response.data,
        (json) => json,
      );
      if (api.code != ApiResponseCodes.success) {
        throw Exception(api.message);
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        throw Exception(
          data['message']?.toString() ?? e.message ?? appL10n.commonErrorShort,
        );
      }
      throw Exception(e.message ?? appL10n.commonErrorShort);
    }
  }
}

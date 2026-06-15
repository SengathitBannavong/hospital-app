// lib/features/sos/data/repository/sos_repository.dart

import 'package:dio/dio.dart';
import 'package:hospital_app/core/l10n/locale_controller.dart';
import 'package:hospital_app/core/network/api_client.dart';
import 'package:hospital_app/core/network/api_endpoints.dart';
import '../models/sos_detail.dart';

class SosRepository {
  final Dio _dio = ApiClient.instance;

  Future<bool> createSos() async {
    try {
      await _dio.post(ApiEndpoints.sosCreate);
      return true;
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  Future<SosDetail?> getSosDetail() async {
    try {
      final response = await _dio.get(ApiEndpoints.sosGetDetail);
      final data = response.data;
      if (data == null) return null;
      final payload = (data is Map && data.containsKey('data'))
          ? data['data'] as Map<String, dynamic>?
          : data as Map<String, dynamic>?;
      if (payload == null || payload.isEmpty) return null;
      return SosDetail.fromJson(payload);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw Exception(_parseError(e));
    }
  }

  String _parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      return data['message']?.toString() ??
          data['error']?.toString() ??
          appL10n.commonErrorShort;
    }
    return e.message ?? appL10n.commonErrorShort;
  }
}

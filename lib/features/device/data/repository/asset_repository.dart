import 'package:dio/dio.dart';
import 'package:hospital_app/core/network/api_client.dart';
import 'package:hospital_app/core/network/api_endpoints.dart';
import 'package:hospital_app/core/network/api_response_codes.dart';
import 'package:hospital_app/features/auth/data/models/auth_api_response.dart';
import '../models/asset_device.dart';
import '../models/asset_station.dart';
import '../models/asset_track.dart';

class AssetRepository {
  final Dio _dio = ApiClient.instance;

  // Shown when track_asset rejects with accessDenied (1009). The backend does
  // not expose booked_by/user_id/is_mine, so 1009 is the only ownership signal:
  // the asset is in use by another user, or the caller may not track it.
  static const _trackAccessDeniedMessage =
      'Thiết bị này đang được người dùng khác sử dụng, '
      'hoặc bạn không có quyền theo dõi thiết bị này.';

  Future<List<AssetStation>> getStations() async {
    try {
      final response = await _dio.get(ApiEndpoints.assetStations);
      final api = AuthApiResponse<List<AssetStation>>.fromJson(
        response.data,
        (json) => _parseList(json, AssetStation.fromJson),
      );
      return _requireSuccess(api);
    } on DioException catch (e) {
      throw Exception(_error(e));
    }
  }

  Future<List<AssetDevice>> findWheelchairs({
    required String nodeId,
    int radius = 200,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.assetFindWheelchairs,
        queryParameters: {'node_id': nodeId, 'radius': radius},
      );
      final api = AuthApiResponse<List<AssetDevice>>.fromJson(
        response.data,
        (json) => _parseList(json, AssetDevice.fromJson),
      );
      return _requireSuccess(api);
    } on DioException catch (e) {
      throw Exception(_error(e));
    }
  }

  Future<AssetTrack> getAssetHealth(String assetId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.assetHealth,
        queryParameters: {'asset_id': assetId},
      );
      final api = AuthApiResponse<AssetTrack>.fromJson(
        response.data,
        (json) => _parseSingleOrList(json, AssetTrack.fromJson),
      );
      return _requireSuccess(api);
    } on DioException catch (e) {
      throw Exception(_error(e));
    }
  }

  Future<AssetTrack> trackAsset(String assetId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.assetTrack,
        queryParameters: {'asset_id': assetId},
      );
      final api = AuthApiResponse<AssetTrack>.fromJson(
        response.data,
        (json) => _parseSingleOrList(json, AssetTrack.fromJson),
      );
      // track_asset enforces ownership server-side.
      if (api.code == ApiResponseCodes.accessDenied) {
        throw Exception(_trackAccessDeniedMessage);
      }
      return _requireSuccess(api);
    } on DioException catch (e) {
      if (_isAccessDenied(e)) {
        throw Exception(_trackAccessDeniedMessage);
      }
      throw Exception(_error(e));
    }
  }

  Future<void> bookAsset(String assetId) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.assetBook,
        data: {'asset_id': assetId},
      );
      final api = AuthApiResponse<dynamic>.fromJson(
        response.data,
        (json) => json,
      );
      if (api.code != ApiResponseCodes.success) {
        throw Exception(api.message);
      }
    } on DioException catch (e) {
      throw Exception(_error(e));
    }
  }

  Future<void> releaseAsset({
    required String assetId,
    required String stationId,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.assetRelease,
        data: {'asset_id': assetId, 'station_id': stationId},
      );
      final api = AuthApiResponse<dynamic>.fromJson(
        response.data,
        (json) => json,
      );
      if (api.code != ApiResponseCodes.success) {
        throw Exception(api.message);
      }
    } on DioException catch (e) {
      throw Exception(_error(e));
    }
  }

  Future<void> reportBrokenAsset({
    required String assetId,
    required String reason,
    String? imageUrl,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.assetReportBroken,
        data: {'asset_id': assetId, 'reason': reason, 'image_url': ?imageUrl},
      );
      final api = AuthApiResponse<dynamic>.fromJson(
        response.data,
        (json) => json,
      );
      if (api.code != ApiResponseCodes.success) {
        throw Exception(api.message);
      }
    } on DioException catch (e) {
      throw Exception(_error(e));
    }
  }

  // ── helpers ──

  List<T> _parseList<T>(
    dynamic json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (json is List) {
      return json
          .whereType<Map>()
          .map((e) => fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return const [];
  }

  T _parseSingleOrList<T>(
    dynamic json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (json is List && json.isNotEmpty && json.first is Map) {
      return fromJson(Map<String, dynamic>.from(json.first as Map));
    }
    if (json is Map) {
      return fromJson(Map<String, dynamic>.from(json));
    }
    throw Exception('Unexpected response format');
  }

  T _requireSuccess<T>(AuthApiResponse<T> api) {
    if (api.code == ApiResponseCodes.success && api.data != null) {
      return api.data as T;
    }
    throw Exception(api.message);
  }

  String _error(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ?? e.message ?? 'Đã xảy ra lỗi';
    }
    return e.message ?? 'Đã xảy ra lỗi';
  }

  // True when the error body carries the custom accessDenied (1009) code,
  // e.g. when the backend returns it over a non-2xx HTTP status.
  bool _isAccessDenied(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final code = data['code'];
      if (code is int) return code == ApiResponseCodes.accessDenied;
      return int.tryParse(code?.toString() ?? '') ==
          ApiResponseCodes.accessDenied;
    }
    return false;
  }
}

import 'package:dio/dio.dart';
import 'package:hospital_app/core/l10n/locale_controller.dart';
import 'package:hospital_app/core/network/api_client.dart';
import 'package:hospital_app/core/network/api_endpoints.dart';
import 'package:hospital_app/core/network/api_error_messages.dart';
import 'package:hospital_app/core/network/api_response_codes.dart';
import 'package:hospital_app/features/auth/data/models/auth_api_response.dart';
import '../models/active_booking.dart';
import '../models/asset_device.dart';
import '../models/asset_station.dart';
import '../models/asset_track.dart';

/// Thrown by [AssetRepository.bookAsset] when the backend rejects the booking
/// because the user already holds one (code 1010). Distinct so the UI can offer
/// to recover the existing booking instead of just showing an error.
class AlreadyBookingException implements Exception {
  const AlreadyBookingException(this.message);
  final String message;

  @override
  String toString() => 'Exception: $message';
}

class AssetRepository {
  final Dio _dio = ApiClient.instance;

  // Shown when track_asset rejects with accessDenied (1009). The backend does
  // not expose booked_by/user_id/is_mine, so 1009 is the only ownership signal:
  // the asset is in use by another user, or the caller may not track it.
  static String get _trackAccessDeniedMessage =>
      appL10n.assetInUseOrNoPermission;

  /// The caller's current booking from the authoritative
  /// `GET /api/asset/my_booking`, or `null` when they hold none. This replaces
  /// the old in-use discovery heuristic: the backend now answers "which
  /// wheelchair am I holding?" directly, so recovery is exact.
  Future<ActiveBooking?> getMyBooking() async {
    try {
      final response = await _dio.get(ApiEndpoints.assetMyBooking);
      final api = AuthApiResponse<dynamic>.fromJson(
        response.data,
        (json) => json,
      );
      if (api.code != ApiResponseCodes.success) {
        throw Exception(friendlyMessage(api.code, api.message));
      }
      final data = api.data;
      Map<String, dynamic>? map;
      if (data is List && data.isNotEmpty && data.first is Map) {
        map = Map<String, dynamic>.from(data.first as Map);
      } else if (data is Map) {
        map = Map<String, dynamic>.from(data);
      }
      if (map == null) return null;
      final booking = ActiveBooking.fromJson(map);
      return booking.assetId.isEmpty ? null : booking;
    } on DioException catch (e) {
      throw Exception(_error(e));
    }
  }

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

  /// Best-effort discovery of wheelchairs currently `in_use` — used to recover
  /// a booking the local store doesn't know about (fresh install, another
  /// device). The backend exposes no "my bookings" endpoint and no ownership
  /// field, so this infers the catalog from `find_wheelchairs` (which lists
  /// only *available* assets): the ids missing from that list, within the
  /// observed `WL-001..WL-{maxDeviceId}` range, are the in-use ones, confirmed
  /// via `asset_health`. Callers must still confirm which one is the user's.
  Future<List<String>> discoverInUseAssets({String nodeId = 'ENT-01'}) async {
    final available = await findWheelchairs(nodeId: nodeId, radius: 1000000);
    final availableIds = available.map((d) => d.assetId).toSet();
    var maxDeviceId = 0;
    for (final d in available) {
      final id = d.deviceId ?? 0;
      if (id > maxDeviceId) maxDeviceId = id;
    }
    if (maxDeviceId == 0) return const [];

    final candidates = <String>[];
    for (var i = 1; i <= maxDeviceId; i++) {
      final id = 'WL-${i.toString().padLeft(3, '0')}';
      if (!availableIds.contains(id)) candidates.add(id);
    }

    final inUse = <String>[];
    for (final id in candidates) {
      try {
        final health = await getAssetHealth(id);
        if (health.status.toLowerCase() == 'in_use') inUse.add(id);
      } catch (_) {
        // Ignore assets that error out (e.g. not found); they aren't ours.
      }
    }
    return inUse;
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

  Future<ActiveBooking> bookAsset(String assetId) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.assetBook,
        data: {'asset_id': assetId},
      );
      final api = AuthApiResponse<dynamic>.fromJson(
        response.data,
        (json) => json,
      );
      if (api.code == ApiResponseCodes.limitExceeded) {
        // Backend says the user already holds a booking. If our local store
        // doesn't know about it (fresh install / another phone), the caller can
        // offer recovery — so signal this case distinctly.
        throw AlreadyBookingException(friendlyMessage(api.code, api.message));
      }
      if (api.code != ApiResponseCodes.success) {
        throw Exception(friendlyMessage(api.code, api.message));
      }
      return _parseBooking(api.data, assetId);
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
        throw Exception(friendlyMessage(api.code, api.message));
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
        throw Exception(friendlyMessage(api.code, api.message));
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

  ActiveBooking _parseBooking(dynamic data, String fallbackAssetId) {
    Map<String, dynamic>? map;
    if (data is List && data.isNotEmpty && data.first is Map) {
      map = Map<String, dynamic>.from(data.first as Map);
    } else if (data is Map) {
      map = Map<String, dynamic>.from(data);
    }
    if (map != null) {
      final booking = ActiveBooking.fromJson(map);
      if (booking.assetId.isNotEmpty) return booking;
      return ActiveBooking(
        assetId: fallbackAssetId,
        bookingId: booking.bookingId,
      );
    }
    return ActiveBooking(assetId: fallbackAssetId);
  }

  T _requireSuccess<T>(AuthApiResponse<T> api) {
    if (api.code == ApiResponseCodes.success && api.data != null) {
      return api.data as T;
    }
    throw Exception(friendlyMessage(api.code, api.message));
  }

  String _error(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      return friendlyMessage(_bodyCode(data), data['message']?.toString());
    }
    return e.message ?? appL10n.assetGenericError;
  }

  int? _bodyCode(dynamic data) {
    if (data is Map) {
      final code = data['code'];
      if (code is int) return code;
      return int.tryParse(code?.toString() ?? '');
    }
    return null;
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

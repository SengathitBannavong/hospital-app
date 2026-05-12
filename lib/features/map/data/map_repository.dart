import 'package:dio/dio.dart';
import 'package:hospital_app/core/network/api_client.dart';
import 'package:hospital_app/core/network/api_endpoints.dart';
import 'package:hospital_app/core/network/api_response_codes.dart';
import '../../auth/data/models/auth_api_response.dart';
import 'models/map_department.dart';
import 'models/map_edges_response.dart';
import 'models/map_floor.dart';
import 'models/map_poi.dart';
import 'models/map_sync_full.dart';
import 'models/route_clear_history.dart';
import 'models/route_history.dart';
import 'models/route_mode.dart';

class MapRepository {
  Future<List<MapFloor>> getFloors() async {
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.getFloors);

      final apiResponse = AuthApiResponse<List<MapFloor>>.fromJson(
        response.data,
        (json) => (json as List<dynamic>)
            .map((item) => MapFloor.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

      if (apiResponse.code == ApiResponseCodes.success) {
        return apiResponse.data ?? [];
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<List<MapPoi>> getNodes({required int mapId}) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.getNodes,
        queryParameters: {'map_id': mapId},
      );

      final apiResponse = AuthApiResponse<List<MapPoi>>.fromJson(
        response.data,
        (json) => (json as List<dynamic>)
            .map((item) => MapPoi.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

      if (apiResponse.code == ApiResponseCodes.success) {
        return apiResponse.data ?? [];
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<MapEdgesResponse> getEdges({required int mapId}) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.getEdges,
        queryParameters: {'map_id': mapId},
      );

      final apiResponse = AuthApiResponse<MapEdgesResponse>.fromJson(
        response.data,
        (json) => MapEdgesResponse.fromJson(json as Map<String, dynamic>),
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

  Future<MapFloor> getMeta({required int mapId}) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.getMeta,
        queryParameters: {'map_id': mapId},
      );

      final apiResponse = AuthApiResponse<MapFloor>.fromJson(
        response.data,
        (json) => MapFloor.fromJson(json as Map<String, dynamic>),
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

  Future<List<MapDepartment>> getDepartments() async {
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.getDepts);

      final apiResponse = AuthApiResponse<List<MapDepartment>>.fromJson(
        response.data,
        (json) => (json as List<dynamic>)
            .map((item) => MapDepartment.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

      if (apiResponse.code == ApiResponseCodes.success) {
        return apiResponse.data ?? [];
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<List<MapPoi>> searchLocation({
    required String keyword,
    required int mapId,
  }) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.searchLocation,
        queryParameters: {'keyword': keyword, 'map_id': mapId},
      );

      final apiResponse = AuthApiResponse<List<MapPoi>>.fromJson(
        response.data,
        (json) => (json as List<dynamic>)
            .map((item) => MapPoi.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

      if (apiResponse.code == ApiResponseCodes.success) {
        return apiResponse.data ?? [];
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<List<MapPoi>> getLandmarks({required int mapId}) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.getLandmarks,
        queryParameters: {'map_id': mapId},
      );

      final apiResponse = AuthApiResponse<List<MapPoi>>.fromJson(
        response.data,
        (json) => (json as List<dynamic>)
            .map((item) => MapPoi.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

      if (apiResponse.code == ApiResponseCodes.success) {
        return apiResponse.data ?? [];
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<MapSyncFull> syncFull({required int mapId}) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.syncFull,
        queryParameters: {'map_id': mapId},
      );

      final apiResponse = AuthApiResponse<MapSyncFull>.fromJson(
        response.data,
        (json) => MapSyncFull.fromJson(json as Map<String, dynamic>),
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

  Future<List<RouteMode>> getRouteModes() async {
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.routeGetModes);

      final apiResponse = AuthApiResponse<List<RouteMode>>.fromJson(
        response.data,
        (json) => (json as List<dynamic>)
            .map((item) => RouteMode.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

      if (apiResponse.code == ApiResponseCodes.success) {
        return apiResponse.data ?? [];
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<dynamic> previewRoute({
    required int startLocation,
    required int destLocation,
    required String modeId,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.routePreview,
        data: {
          'start_location': startLocation,
          'dest_location': destLocation,
          'mode_id': modeId,
        },
      );

      final apiResponse = AuthApiResponse<dynamic>.fromJson(
        response.data,
        (json) => json,
      );

      if (apiResponse.code == ApiResponseCodes.success) {
        return apiResponse.data;
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<dynamic> orderRoute({
    required int startLocation,
    required int destLocation,
    required String modeId,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.routeOrder,
        data: {
          'start_location': startLocation,
          'dest_location': destLocation,
          'mode_id': modeId,
        },
      );

      final apiResponse = AuthApiResponse<dynamic>.fromJson(
        response.data,
        (json) => json,
      );

      if (apiResponse.code == ApiResponseCodes.success) {
        return apiResponse.data;
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<dynamic> orderRouteMulti({
    required int startLocation,
    required List<int> targetLocations,
    required String modeId,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.routeOrderMulti,
        data: {
          'start_location': startLocation,
          'target_locations': targetLocations,
          'mode_id': modeId,
        },
      );

      final apiResponse = AuthApiResponse<dynamic>.fromJson(
        response.data,
        (json) => json,
      );

      if (apiResponse.code == ApiResponseCodes.success) {
        return apiResponse.data;
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<dynamic> orderRouteUnordered({
    required int startLocation,
    required List<int> targetLocations,
    required String modeId,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.routeOrderUnordered,
        data: {
          'start_location': startLocation,
          'target_locations': targetLocations,
          'mode_id': modeId,
        },
      );

      final apiResponse = AuthApiResponse<dynamic>.fromJson(
        response.data,
        (json) => json,
      );

      if (apiResponse.code == ApiResponseCodes.success) {
        return apiResponse.data;
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<RouteHistory> getRouteHistory() async {
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.routeHistory);

      final apiResponse = AuthApiResponse<RouteHistory>.fromJson(
        response.data,
        (json) => RouteHistory.fromJson(json as Map<String, dynamic>),
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

  Future<RouteClearHistory> clearRouteHistory() async {
    try {
      final response = await ApiClient.instance.delete(
        ApiEndpoints.routeClearHistory,
      );

      final apiResponse = AuthApiResponse<RouteClearHistory>.fromJson(
        response.data,
        (json) => RouteClearHistory.fromJson(json as Map<String, dynamic>),
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

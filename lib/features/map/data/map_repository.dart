import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:hospital_app/core/network/api_client.dart';
import 'package:hospital_app/core/network/api_endpoints.dart';
import 'package:hospital_app/core/network/api_response_codes.dart';
import '../../auth/data/models/auth_api_response.dart';
import 'models/edge_status.dart';
import 'models/flow_alert.dart';
import 'models/flow_cell.dart';
import 'models/map_department.dart';
import 'models/map_edges_response.dart';
import 'models/map_floor.dart';
import 'models/map_obstacle.dart';
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

  Future<dynamic> recalculateRoute({
    required String routeId,
    required int currentLocation,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.routeRecalculate,
        data: {'route_id': routeId, 'current_location': currentLocation},
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

  Future<List<FlowCell>> getFlowDensity({int? gridLocation}) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.flowGetDensity,
        queryParameters: {'grid_location': ?gridLocation},
      );

      final apiResponse = AuthApiResponse<List<FlowCell>>.fromJson(
        response.data,
        (json) => _parseFlowCells(json),
      );

      if (apiResponse.code == ApiResponseCodes.success) {
        return apiResponse.data ?? const <FlowCell>[];
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<List<FlowCell>> getFlowHeatmap() async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.flowGetHeatmap,
      );

      final apiResponse = AuthApiResponse<List<FlowCell>>.fromJson(
        response.data,
        (json) => _parseFlowCells(json),
      );

      if (apiResponse.code == ApiResponseCodes.success) {
        return apiResponse.data ?? const <FlowCell>[];
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<List<FlowCell>> getFlowBottlenecks({int limit = 10}) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.flowGetBottlenecks,
        queryParameters: {'limit': limit},
      );

      final apiResponse = AuthApiResponse<List<FlowCell>>.fromJson(
        response.data,
        (json) => _parseFlowCells(json),
      );

      if (apiResponse.code == ApiResponseCodes.success) {
        return apiResponse.data ?? const <FlowCell>[];
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<List<FlowCell>> getFlowForecast({int hours = 24}) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.flowGetForecast,
        queryParameters: {'hours': hours},
      );

      final apiResponse = AuthApiResponse<List<FlowCell>>.fromJson(
        response.data,
        (json) => _parseFlowCells(json),
      );

      if (apiResponse.code == ApiResponseCodes.success) {
        return apiResponse.data ?? const <FlowCell>[];
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<List<FlowAlert>> getFlowAlerts() async {
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.flowGetAlerts);

      final apiResponse = AuthApiResponse<List<FlowAlert>>.fromJson(
        response.data,
        (json) => _parseFlowAlerts(json),
      );

      if (apiResponse.code == ApiResponseCodes.success) {
        return apiResponse.data ?? const <FlowAlert>[];
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<List<EdgeStatus>> getFlowEdgeStatus() async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.flowEdgeStatus,
      );

      final apiResponse = AuthApiResponse<List<EdgeStatus>>.fromJson(
        response.data,
        (json) => _parseEdgeStatuses(json),
      );

      if (apiResponse.code == ApiResponseCodes.success) {
        return apiResponse.data ?? const <EdgeStatus>[];
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<String?> getVoiceKey() async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.sysGetVoiceKey,
      );

      final apiResponse = AuthApiResponse<String?>.fromJson(
        response.data,
        (json) => _parseVoiceKey(json),
      );

      if (apiResponse.code == ApiResponseCodes.success) {
        return apiResponse.data;
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<Map<String, String>> getVoiceFiles() async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.sysGetVoiceFiles,
      );

      final apiResponse = AuthApiResponse<Map<String, String>>.fromJson(
        response.data,
        (json) => _parseVoiceFiles(json),
      );

      if (apiResponse.code == ApiResponseCodes.success) {
        return apiResponse.data ?? const <String, String>{};
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<void> pingLocation({
    required int gridLocation,
    required int gridRow,
    required int gridCol,
    String? routeId,
  }) async {
    // TODO(Phase J backend:flow-ping): confirm payload fields, route_id usage,
    // and cadence before wiring simulated navigation to flow/ping_location.
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.flowPingLocation,
        data: {
          'grid_location': gridLocation,
          'grid_row': gridRow,
          'grid_col': gridCol,
          'route_id': ?routeId,
        },
      );

      final apiResponse = AuthApiResponse<dynamic>.fromJson(
        response.data,
        (json) => json,
      );

      if (apiResponse.code == ApiResponseCodes.success) {
        return;
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<void> reportObstacle({
    required int gridLocation,
    required String type,
    String? note,
    String? routeId,
  }) async {
    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.flowReportObstacle,
        data: {
          'grid_location': gridLocation,
          'report_type': type,
          if (note != null && note.isNotEmpty) 'description': note,
          'route_id': ?routeId,
        },
      );

      final apiResponse = AuthApiResponse<dynamic>.fromJson(
        response.data,
        (json) => json,
      );

      if (apiResponse.code == ApiResponseCodes.success) {
        return;
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<List<MapObstacle>> getObstacles({String? status}) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.flowGetObstacles,
        queryParameters: {'status': ?status},
      );

      final apiResponse = AuthApiResponse<List<MapObstacle>>.fromJson(
        response.data,
        (json) => _parseObstacles(json),
      );

      if (apiResponse.code == ApiResponseCodes.success) {
        return apiResponse.data ?? const <MapObstacle>[];
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

  List<FlowCell> _parseFlowCells(dynamic json) {
    final rows = _extractRows(json, keys: const ['cells', 'heatmap', 'data']);
    return rows.map(_flowCellFromRaw).whereType<FlowCell>().toList();
  }

  FlowCell? _flowCellFromRaw(Map<String, dynamic> json) {
    final location = _readInt(json['grid_location'] ?? json['location']);
    if (location == null) {
      return null;
    }
    final density = _readDouble(json['density'] ?? json['count']) ?? 0;
    return FlowCell(location: location, density: density);
  }

  List<EdgeStatus> _parseEdgeStatuses(dynamic json) {
    final rows = _extractRows(
      json,
      keys: const ['edge_statuses', 'edges', 'statuses', 'data'],
    );
    return rows.map(_edgeStatusFromRaw).whereType<EdgeStatus>().toList();
  }

  EdgeStatus? _edgeStatusFromRaw(Map<String, dynamic> json) {
    final from = _readInt(
      json['from_location'] ?? json['from'] ?? json['source_location'],
    );
    final to = _readInt(
      json['to_location'] ?? json['to'] ?? json['target_location'],
    );
    if (from == null || to == null) {
      return null;
    }
    return EdgeStatus(
      fromLocation: from,
      toLocation: to,
      congestion: _readDouble(json['congestion'] ?? json['density']) ?? 0,
      blocked: json['blocked'] == true || json['status'] == 'blocked',
    );
  }

  List<FlowAlert> _parseFlowAlerts(dynamic json) {
    final rows = _extractRows(json, keys: const ['alerts', 'items', 'data']);
    return rows.map(_flowAlertFromRaw).whereType<FlowAlert>().toList();
  }

  List<MapObstacle> _parseObstacles(dynamic json) {
    final rows = _extractRows(
      json,
      keys: const ['obstacles', 'reports', 'items', 'data'],
    );
    return rows.map(_obstacleFromRaw).whereType<MapObstacle>().toList();
  }

  MapObstacle? _obstacleFromRaw(Map<String, dynamic> json) {
    final location = _readInt(json['grid_location'] ?? json['location']);
    if (location == null) {
      return null;
    }
    final type =
        json['type']?.toString() ??
        json['report_type']?.toString() ??
        'obstacle';
    final reportedAt =
        DateTime.tryParse(
          json['reported_at']?.toString() ??
              json['created_at']?.toString() ??
              '',
        ) ??
        DateTime.now().toUtc();
    return MapObstacle(
      id:
          json['id']?.toString() ??
          'obstacle-$location-${reportedAt.toIso8601String()}',
      gridLocation: location,
      type: type,
      note: json['note']?.toString() ?? json['description']?.toString(),
      reportedAt: reportedAt,
    );
  }

  FlowAlert? _flowAlertFromRaw(Map<String, dynamic> json) {
    final message = json['message']?.toString() ?? json['title']?.toString();
    if (message == null || message.isEmpty) {
      return null;
    }
    return FlowAlert(
      id: json['id']?.toString() ?? message,
      message: message,
      location: _readInt(json['location'] ?? json['grid_location']),
      level:
          json['level']?.toString() ?? json['severity']?.toString() ?? 'info',
    );
  }

  List<Map<String, dynamic>> _extractRows(
    dynamic json, {
    required List<String> keys,
  }) {
    if (json is List) {
      return json
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    if (json is Map) {
      for (final key in keys) {
        final value = json[key];
        if (value is List) {
          return value
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      }
      if (_looksLikeRow(json)) {
        return [Map<String, dynamic>.from(json)];
      }
    }
    return const <Map<String, dynamic>>[];
  }

  bool _looksLikeRow(Map<dynamic, dynamic> json) {
    return json.containsKey('grid_location') ||
        json.containsKey('location') ||
        json.containsKey('from_location') ||
        json.containsKey('to_location') ||
        json.containsKey('message') ||
        json.containsKey('report_type');
  }

  int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  double? _readDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  String? _parseVoiceKey(dynamic json) {
    if (json is String && json.isNotEmpty) {
      return json;
    }
    if (json is Map) {
      for (final key in const ['voice_key', 'tts_key', 'key', 'api_key']) {
        final value = json[key]?.toString();
        if (value != null && value.isNotEmpty) {
          return value;
        }
      }
    }
    return null;
  }

  Map<String, String> _parseVoiceFiles(dynamic json) {
    if (json is Map) {
      final files = json['files'] ?? json['clip_urls'] ?? json['clips'] ?? json;
      if (files is Map) {
        return {
          for (final entry in files.entries)
            if (entry.value != null)
              entry.key.toString(): entry.value.toString(),
        };
      }
    }
    if (json is List) {
      final result = <String, String>{};
      for (final item in json.whereType<Map>()) {
        final key = item['key'] ?? item['maneuver'] ?? item['id'];
        final url = item['url'] ?? item['clip_url'] ?? item['file_url'];
        if (key != null && url != null) {
          result[key.toString()] = url.toString();
        }
      }
      return result;
    }
    return const <String, String>{};
  }

  @visibleForTesting
  List<FlowAlert> parseFlowAlertsForTesting(dynamic json) {
    return _parseFlowAlerts(json);
  }
}

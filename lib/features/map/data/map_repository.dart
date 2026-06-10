import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:hospital_app/core/network/api_client.dart';
import 'package:hospital_app/core/network/api_endpoints.dart';
import 'package:hospital_app/core/network/api_response_codes.dart';
import '../../auth/data/models/auth_api_response.dart';
import 'models/flow_alert.dart';
import 'models/flow_cell.dart';
import 'models/flow_forecast_bucket.dart';
import 'models/map_edges_response.dart';
import 'models/map_floor.dart';
import 'models/map_obstacle.dart';
import 'models/map_poi.dart';
import 'models/map_sync_full.dart';
import 'models/route_clear_history.dart';
import 'models/route_history.dart';
import 'models/route_mode.dart';

enum _MapHttpMethod { get, post, delete }

typedef _MapResponseDecoder<T> = T Function(dynamic json);

class MapRepository {
  Future<T?> _request<T>({
    required _MapHttpMethod method,
    required String endpoint,
    required _MapResponseDecoder<T> fromJson,
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool requireData = false,
  }) async {
    try {
      final response = switch (method) {
        _MapHttpMethod.get => await ApiClient.instance.get(
          endpoint,
          queryParameters: queryParameters,
        ),
        _MapHttpMethod.post => await ApiClient.instance.post(
          endpoint,
          data: data,
          queryParameters: queryParameters,
        ),
        _MapHttpMethod.delete => await ApiClient.instance.delete(
          endpoint,
          data: data,
          queryParameters: queryParameters,
        ),
      };

      final apiResponse = AuthApiResponse<T>.fromJson(response.data, fromJson);

      if (apiResponse.code == ApiResponseCodes.success) {
        if (requireData && apiResponse.data == null) {
          throw Exception(apiResponse.message);
        }
        return apiResponse.data;
      }

      throw Exception(apiResponse.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<List<MapFloor>> getFloors() async {
    final floors = await _request<List<MapFloor>>(
      method: _MapHttpMethod.get,
      endpoint: ApiEndpoints.getFloors,
      fromJson: (json) => (json as List<dynamic>)
          .map((item) => MapFloor.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
    return floors ?? [];
  }

  Future<List<MapPoi>> getNodes({required int mapId}) async {
    final nodes = await _request<List<MapPoi>>(
      method: _MapHttpMethod.get,
      endpoint: ApiEndpoints.getNodes,
      queryParameters: {'map_id': mapId},
      fromJson: (json) => (json as List<dynamic>)
          .map((item) => MapPoi.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
    return nodes ?? [];
  }

  Future<MapEdgesResponse> getEdges({required int mapId}) async {
    return (await _request<MapEdgesResponse>(
      method: _MapHttpMethod.get,
      endpoint: ApiEndpoints.getEdges,
      queryParameters: {'map_id': mapId},
      fromJson: (json) =>
          MapEdgesResponse.fromJson(json as Map<String, dynamic>),
      requireData: true,
    ))!;
  }

  Future<MapFloor> getMeta({required int mapId}) async {
    return (await _request<MapFloor>(
      method: _MapHttpMethod.get,
      endpoint: ApiEndpoints.getMeta,
      queryParameters: {'map_id': mapId},
      fromJson: (json) => MapFloor.fromJson(json as Map<String, dynamic>),
      requireData: true,
    ))!;
  }

  Future<List<MapPoi>> searchLocation({
    required String keyword,
    required int mapId,
  }) async {
    final pois = await _request<List<MapPoi>>(
      method: _MapHttpMethod.get,
      endpoint: ApiEndpoints.searchLocation,
      queryParameters: {'keyword': keyword, 'map_id': mapId},
      fromJson: (json) => (json as List<dynamic>)
          .map((item) => MapPoi.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
    return pois ?? [];
  }

  Future<MapSyncFull> syncFull({required int mapId}) async {
    return (await _request<MapSyncFull>(
      method: _MapHttpMethod.get,
      endpoint: ApiEndpoints.syncFull,
      queryParameters: {'map_id': mapId},
      fromJson: (json) => MapSyncFull.fromJson(json as Map<String, dynamic>),
      requireData: true,
    ))!;
  }

  Future<List<RouteMode>> getRouteModes() async {
    final modes = await _request<List<RouteMode>>(
      method: _MapHttpMethod.get,
      endpoint: ApiEndpoints.routeGetModes,
      fromJson: (json) => (json as List<dynamic>)
          .map((item) => RouteMode.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
    return modes ?? [];
  }

  Future<dynamic> previewRoute({
    required int startLocation,
    required int destLocation,
    required String modeId,
  }) async {
    return _request<dynamic>(
      method: _MapHttpMethod.post,
      endpoint: ApiEndpoints.routePreview,
      data: {
        'start_location': startLocation,
        'dest_location': destLocation,
        'mode_id': modeId,
      },
      fromJson: (json) => json,
    );
  }

  Future<dynamic> orderRoute({
    required int startLocation,
    required int destLocation,
    required String modeId,
  }) async {
    return _request<dynamic>(
      method: _MapHttpMethod.post,
      endpoint: ApiEndpoints.routeOrder,
      data: {
        'start_location': startLocation,
        'dest_location': destLocation,
        'mode_id': modeId,
      },
      fromJson: (json) => json,
    );
  }

  Future<dynamic> recalculateRoute({
    required String routeId,
    required int currentLocation,
  }) async {
    return _request<dynamic>(
      method: _MapHttpMethod.post,
      endpoint: ApiEndpoints.routeRecalculate,
      data: {'route_id': routeId, 'current_location': currentLocation},
      fromJson: (json) => json,
    );
  }

  Future<RouteHistory> getRouteHistory({int limit = 15, int page = 1}) async {
    return (await _request<RouteHistory>(
      method: _MapHttpMethod.get,
      endpoint: ApiEndpoints.routeHistory,
      queryParameters: {'limit': limit, 'page': page},
      fromJson: (json) => RouteHistory.fromJson(json as Map<String, dynamic>),
      requireData: true,
    ))!;
  }

  Future<RouteClearHistory> clearRouteHistory() async {
    return (await _request<RouteClearHistory>(
      method: _MapHttpMethod.delete,
      endpoint: ApiEndpoints.routeClearHistory,
      fromJson: (json) =>
          RouteClearHistory.fromJson(json as Map<String, dynamic>),
      requireData: true,
    ))!;
  }

  Future<void> rateRoute({
    required String routeId,
    required int rating,
    String? comment,
  }) async {
    await _request<dynamic>(
      method: _MapHttpMethod.post,
      endpoint: ApiEndpoints.routeRate,
      data: {
        'route_id': routeId,
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
      fromJson: (json) => json,
    );
  }

  Future<List<FlowCell>> getFlowDensity({int? gridLocation}) async {
    final cells = await _request<List<FlowCell>>(
      method: _MapHttpMethod.get,
      endpoint: ApiEndpoints.flowGetDensity,
      queryParameters: {'grid_location': ?gridLocation},
      fromJson: _parseFlowCells,
    );
    return cells ?? const <FlowCell>[];
  }

  Future<List<FlowCell>> getFlowHeatmap() async {
    final cells = await _request<List<FlowCell>>(
      method: _MapHttpMethod.get,
      endpoint: ApiEndpoints.flowGetHeatmap,
      fromJson: _parseFlowCells,
    );
    return cells ?? const <FlowCell>[];
  }

  Future<List<FlowCell>> getFlowBottlenecks({int limit = 10}) async {
    final cells = await _request<List<FlowCell>>(
      method: _MapHttpMethod.get,
      endpoint: ApiEndpoints.flowGetBottlenecks,
      queryParameters: {'limit': limit},
      fromJson: _parseFlowCells,
    );
    return cells ?? const <FlowCell>[];
  }

  Future<List<FlowForecastBucket>> getFlowForecast({int hours = 24}) async {
    final buckets = await _request<List<FlowForecastBucket>>(
      method: _MapHttpMethod.get,
      endpoint: ApiEndpoints.flowGetForecast,
      queryParameters: {'hours': hours},
      fromJson: _parseFlowForecastBuckets,
    );
    return buckets ?? const <FlowForecastBucket>[];
  }

  Future<List<FlowAlert>> getFlowAlerts() async {
    final alerts = await _request<List<FlowAlert>>(
      method: _MapHttpMethod.get,
      endpoint: ApiEndpoints.flowGetAlerts,
      fromJson: _parseFlowAlerts,
    );
    return alerts ?? const <FlowAlert>[];
  }

  Future<String?> getVoiceKey() async {
    return _request<String?>(
      method: _MapHttpMethod.get,
      endpoint: ApiEndpoints.sysGetVoiceKey,
      fromJson: _parseVoiceKey,
    );
  }

  Future<void> pingLocation({
    required int gridLocation,
    required int gridRow,
    required int gridCol,
    String? routeId,
  }) async {
    // TODO(Phase J backend:flow-ping): confirm payload fields, route_id usage,
    // and cadence before wiring simulated navigation to flow/ping_location.
    await _request<dynamic>(
      method: _MapHttpMethod.post,
      endpoint: ApiEndpoints.flowPingLocation,
      data: {
        'grid_location': gridLocation,
        'grid_row': gridRow,
        'grid_col': gridCol,
        'route_id': ?routeId,
      },
      fromJson: (json) => json,
    );
  }

  Future<void> reportObstacle({
    required int gridLocation,
    required String type,
    String? note,
    String? routeId,
  }) async {
    await _request<dynamic>(
      method: _MapHttpMethod.post,
      endpoint: ApiEndpoints.flowReportObstacle,
      data: {
        'grid_location': gridLocation,
        'report_type': type,
        if (note != null && note.isNotEmpty) 'description': note,
        'route_id': ?routeId,
      },
      fromJson: (json) => json,
    );
  }

  Future<List<MapObstacle>> getObstacles({String? status}) async {
    final obstacles = await _request<List<MapObstacle>>(
      method: _MapHttpMethod.get,
      endpoint: ApiEndpoints.flowGetObstacles,
      queryParameters: {'status': ?status},
      fromJson: _parseObstacles,
    );
    return obstacles ?? const <MapObstacle>[];
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

  List<FlowForecastBucket> _parseFlowForecastBuckets(dynamic json) {
    final rows = _extractRows(json, keys: const ['data', 'forecast', 'items']);
    return rows
        .map(_flowForecastBucketFromRaw)
        .whereType<FlowForecastBucket>()
        .toList();
  }

  FlowForecastBucket? _flowForecastBucketFromRaw(Map<String, dynamic> json) {
    final hour = _readInt(json['hour']);
    if (hour == null) {
      return null;
    }
    return FlowForecastBucket(hour: hour, count: _readInt(json['count']) ?? 0);
  }

  FlowCell? _flowCellFromRaw(Map<String, dynamic> json) {
    final location = _readInt(json['grid_location'] ?? json['location']);
    if (location == null) {
      return null;
    }
    final density = _readDouble(json['density'] ?? json['count']) ?? 0;
    return FlowCell(location: location, density: density);
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

  @visibleForTesting
  List<FlowAlert> parseFlowAlertsForTesting(dynamic json) {
    return _parseFlowAlerts(json);
  }

  @visibleForTesting
  List<FlowForecastBucket> parseFlowForecastBucketsForTesting(dynamic json) {
    return _parseFlowForecastBuckets(json);
  }
}

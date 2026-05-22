// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'route_history_entry.freezed.dart';
part 'route_history_entry.g.dart';

@freezed
class RouteHistoryEntry with _$RouteHistoryEntry {
  const RouteHistoryEntry._();

  const factory RouteHistoryEntry({
    String? id,
    @JsonKey(name: 'route_id') String? routeId,
    @JsonKey(name: 'poi_id') int? poiId,
    @JsonKey(name: 'destination_poi_id') int? destinationPoiId,
    @JsonKey(name: 'dest_poi_id') int? destPoiId,
    @JsonKey(name: 'grid_location') int? gridLocation,
    @JsonKey(name: 'dest_location') int? destLocation,
    @JsonKey(name: 'destination_name') String? destinationName,
    String? destination,
    @JsonKey(name: 'mode_id') String? modeId,
    @JsonKey(name: 'map_id') int? mapId,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _RouteHistoryEntry;

  factory RouteHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$RouteHistoryEntryFromJson(json);

  int? get resolvedPoiId => destinationPoiId ?? destPoiId ?? poiId;

  int? get resolvedLocation => destLocation ?? gridLocation;

  String get displayName {
    final direct = destinationName ?? destination;
    if (direct != null && direct.trim().isNotEmpty) {
      return direct.trim();
    }
    final location = resolvedLocation;
    if (location != null) {
      return 'Cell $location';
    }
    return 'Saved route';
  }
}

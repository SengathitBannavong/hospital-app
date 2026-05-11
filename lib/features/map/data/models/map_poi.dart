// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'map_poi.freezed.dart';
part 'map_poi.g.dart';

@freezed
class MapPoi with _$MapPoi {
  const factory MapPoi({
    @JsonKey(name: 'poi_id') required int poiId,
    @JsonKey(name: 'map_id') required int mapId,
    @JsonKey(name: 'ward_id') int? wardId,
    @JsonKey(name: 'poi_code') required String poiCode,
    @JsonKey(name: 'poi_name') required String poiName,
    @JsonKey(name: 'poi_type') required String poiType,
    @JsonKey(name: 'grid_row') required int gridRow,
    @JsonKey(name: 'grid_col') required int gridCol,
    @JsonKey(name: 'grid_location') required int gridLocation,
    @JsonKey(name: 'is_landmark') required bool isLandmark,
    @JsonKey(name: 'is_accessible') required bool isAccessible,
    @JsonKey(name: 'wheelchair_accessible') required bool wheelchairAccessible,
    @JsonKey(name: 'custom_weight') double? customWeight,
    int? capacity,
    String? details,
    @JsonKey(name: 'open_hours') String? openHours,
  }) = _MapPoi;

  factory MapPoi.fromJson(Map<String, dynamic> json) => _$MapPoiFromJson(json);
}

// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'map_edge.dart';
import 'map_floor.dart';
import 'map_poi.dart';

part 'map_sync_full.freezed.dart';
part 'map_sync_full.g.dart';

@freezed
class MapSyncFull with _$MapSyncFull {
  const factory MapSyncFull({
    @Default(<MapFloor>[]) @JsonKey(name: 'maps') List<MapFloor> maps,
    @Default(<MapPoi>[]) @JsonKey(name: 'pois') List<MapPoi> pois,
    @Default(<MapEdge>[]) @JsonKey(name: 'edges') List<MapEdge> edges,
  }) = _MapSyncFull;

  factory MapSyncFull.fromJson(Map<String, dynamic> json) =>
      _$MapSyncFullFromJson(json);
}

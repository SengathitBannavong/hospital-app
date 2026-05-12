// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'map_edge.dart';

part 'map_edges_response.freezed.dart';
part 'map_edges_response.g.dart';

@freezed
class MapEdgesResponse with _$MapEdgesResponse {
  const factory MapEdgesResponse({
    required List<MapEdge> edges,
    @JsonKey(name: 'map_id') required int mapId,
    required int total,
  }) = _MapEdgesResponse;

  factory MapEdgesResponse.fromJson(Map<String, dynamic> json) =>
      _$MapEdgesResponseFromJson(json);
}

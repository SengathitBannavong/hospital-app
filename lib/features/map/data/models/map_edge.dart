// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'map_edge.freezed.dart';
part 'map_edge.g.dart';

@freezed
class MapEdge with _$MapEdge {
  const factory MapEdge({
    @JsonKey(name: 'from_row') required int fromRow,
    @JsonKey(name: 'from_col') required int fromCol,
    @JsonKey(name: 'from_location') required int fromLocation,
    @JsonKey(name: 'to_row') required int toRow,
    @JsonKey(name: 'to_col') required int toCol,
    @JsonKey(name: 'to_location') required int toLocation,
  }) = _MapEdge;

  factory MapEdge.fromJson(Map<String, dynamic> json) =>
      _$MapEdgeFromJson(json);
}

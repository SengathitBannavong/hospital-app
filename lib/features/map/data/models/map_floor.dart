// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'map_floor.freezed.dart';
part 'map_floor.g.dart';

@freezed
class MapFloor with _$MapFloor {
  const factory MapFloor({
    @JsonKey(name: 'map_id') required int mapId,
    @JsonKey(name: 'map_name') required String mapName,
    required int rows,
    required int cols,
    @JsonKey(name: 'map_image_url') String? mapImageUrl,
  }) = _MapFloor;

  factory MapFloor.fromJson(Map<String, dynamic> json) =>
      _$MapFloorFromJson(json);
}

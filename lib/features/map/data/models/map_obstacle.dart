// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'map_obstacle.freezed.dart';
part 'map_obstacle.g.dart';

@freezed
class MapObstacle with _$MapObstacle {
  const factory MapObstacle({
    required String id,
    @JsonKey(name: 'grid_location') required int gridLocation,
    required String type,
    String? note,
    @JsonKey(name: 'reported_at') required DateTime reportedAt,
  }) = _MapObstacle;

  factory MapObstacle.fromJson(Map<String, dynamic> json) =>
      _$MapObstacleFromJson(json);
}

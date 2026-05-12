// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'route_mode.freezed.dart';
part 'route_mode.g.dart';

@freezed
class RouteMode with _$RouteMode {
  const factory RouteMode({
    @JsonKey(name: 'mode_id') required String modeId,
    @JsonKey(name: 'mode_name') required String modeName,
    @JsonKey(name: 'speed_factor') required double speedFactor,
  }) = _RouteMode;

  factory RouteMode.fromJson(Map<String, dynamic> json) =>
      _$RouteModeFromJson(json);
}

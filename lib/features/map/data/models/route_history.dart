// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'route_history_entry.dart';

part 'route_history.freezed.dart';
part 'route_history.g.dart';

@freezed
class RouteHistory with _$RouteHistory {
  const factory RouteHistory({
    @Default(20) int limit,
    @Default(1) int page,
    @Default(0) int total,
    @Default(<RouteHistoryEntry>[]) List<RouteHistoryEntry> routes,
  }) = _RouteHistory;

  factory RouteHistory.fromJson(Map<String, dynamic> json) =>
      _$RouteHistoryFromJson(json);
}

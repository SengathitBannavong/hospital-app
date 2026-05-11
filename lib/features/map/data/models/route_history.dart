// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'route_history.freezed.dart';
part 'route_history.g.dart';

@freezed
class RouteHistory with _$RouteHistory {
  const factory RouteHistory({
    required int limit,
    required int page,
    required int total,
    required List<dynamic> routes,
  }) = _RouteHistory;

  factory RouteHistory.fromJson(Map<String, dynamic> json) =>
      _$RouteHistoryFromJson(json);
}

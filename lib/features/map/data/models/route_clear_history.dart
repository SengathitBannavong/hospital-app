// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'route_clear_history.freezed.dart';
part 'route_clear_history.g.dart';

@freezed
class RouteClearHistory with _$RouteClearHistory {
  const factory RouteClearHistory({required bool cleared}) = _RouteClearHistory;

  factory RouteClearHistory.fromJson(Map<String, dynamic> json) =>
      _$RouteClearHistoryFromJson(json);
}

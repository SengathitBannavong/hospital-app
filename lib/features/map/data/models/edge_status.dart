// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'edge_status.freezed.dart';
part 'edge_status.g.dart';

@freezed
class EdgeStatus with _$EdgeStatus {
  const factory EdgeStatus({
    @JsonKey(name: 'from_location') required int fromLocation,
    @JsonKey(name: 'to_location') required int toLocation,
    @Default(0) double congestion,
    @Default(false) bool blocked,
  }) = _EdgeStatus;

  factory EdgeStatus.fromJson(Map<String, dynamic> json) =>
      _$EdgeStatusFromJson(json);
}

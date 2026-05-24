// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'flow_cell.freezed.dart';
part 'flow_cell.g.dart';

@freezed
class FlowCell with _$FlowCell {
  const factory FlowCell({
    @JsonKey(name: 'grid_location') required int location,
    @Default(0) double density,
  }) = _FlowCell;

  factory FlowCell.fromJson(Map<String, dynamic> json) =>
      _$FlowCellFromJson(json);
}

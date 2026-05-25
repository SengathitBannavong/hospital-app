// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'flow_alert.freezed.dart';
part 'flow_alert.g.dart';

@freezed
class FlowAlert with _$FlowAlert {
  const factory FlowAlert({
    required String id,
    required String message,
    int? location,
    @Default('info') String level,
  }) = _FlowAlert;

  factory FlowAlert.fromJson(Map<String, dynamic> json) =>
      _$FlowAlertFromJson(json);
}

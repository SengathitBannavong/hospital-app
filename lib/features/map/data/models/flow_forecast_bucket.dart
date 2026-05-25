// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'flow_forecast_bucket.freezed.dart';
part 'flow_forecast_bucket.g.dart';

@freezed
class FlowForecastBucket with _$FlowForecastBucket {
  const factory FlowForecastBucket({required int hour, @Default(0) int count}) =
      _FlowForecastBucket;

  factory FlowForecastBucket.fromJson(Map<String, dynamic> json) =>
      _$FlowForecastBucketFromJson(json);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flow_forecast_bucket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FlowForecastBucketImpl _$$FlowForecastBucketImplFromJson(
  Map<String, dynamic> json,
) => _$FlowForecastBucketImpl(
  hour: (json['hour'] as num).toInt(),
  count: (json['count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$FlowForecastBucketImplToJson(
  _$FlowForecastBucketImpl instance,
) => <String, dynamic>{'hour': instance.hour, 'count': instance.count};

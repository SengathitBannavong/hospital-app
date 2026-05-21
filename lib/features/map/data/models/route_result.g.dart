// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RouteResultImpl _$$RouteResultImplFromJson(Map<String, dynamic> json) =>
    _$RouteResultImpl(
      path: (json['path'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      steps: (json['steps'] as List<dynamic>)
          .map((e) => RouteStep.fromJson(e as Map<String, dynamic>))
          .toList(),
      distance: (json['distance'] as num).toDouble(),
      estimatedTime: (json['estimated_time'] as num).toDouble(),
      modeId: json['mode_id'] as String,
      speedFactor: (json['speed_factor'] as num).toDouble(),
    );

Map<String, dynamic> _$$RouteResultImplToJson(_$RouteResultImpl instance) =>
    <String, dynamic>{
      'path': instance.path,
      'steps': instance.steps,
      'distance': instance.distance,
      'estimated_time': instance.estimatedTime,
      'mode_id': instance.modeId,
      'speed_factor': instance.speedFactor,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_obstacle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MapObstacleImpl _$$MapObstacleImplFromJson(Map<String, dynamic> json) =>
    _$MapObstacleImpl(
      id: json['id'] as String,
      gridLocation: (json['grid_location'] as num).toInt(),
      type: json['type'] as String,
      note: json['note'] as String?,
      reportedAt: DateTime.parse(json['reported_at'] as String),
    );

Map<String, dynamic> _$$MapObstacleImplToJson(_$MapObstacleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'grid_location': instance.gridLocation,
      'type': instance.type,
      'note': instance.note,
      'reported_at': instance.reportedAt.toIso8601String(),
    };

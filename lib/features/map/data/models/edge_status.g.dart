// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edge_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EdgeStatusImpl _$$EdgeStatusImplFromJson(Map<String, dynamic> json) =>
    _$EdgeStatusImpl(
      fromLocation: (json['from_location'] as num).toInt(),
      toLocation: (json['to_location'] as num).toInt(),
      congestion: (json['congestion'] as num?)?.toDouble() ?? 0,
      blocked: json['blocked'] as bool? ?? false,
    );

Map<String, dynamic> _$$EdgeStatusImplToJson(_$EdgeStatusImpl instance) =>
    <String, dynamic>{
      'from_location': instance.fromLocation,
      'to_location': instance.toLocation,
      'congestion': instance.congestion,
      'blocked': instance.blocked,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flow_alert.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FlowAlertImpl _$$FlowAlertImplFromJson(Map<String, dynamic> json) =>
    _$FlowAlertImpl(
      id: json['id'] as String,
      message: json['message'] as String,
      location: (json['location'] as num?)?.toInt(),
      level: json['level'] as String? ?? 'info',
    );

Map<String, dynamic> _$$FlowAlertImplToJson(_$FlowAlertImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'location': instance.location,
      'level': instance.level,
    };

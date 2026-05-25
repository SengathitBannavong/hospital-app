// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_step.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RouteStepImpl _$$RouteStepImplFromJson(Map<String, dynamic> json) =>
    _$RouteStepImpl(
      location: (json['location'] as num).toInt(),
      maneuver: $enumDecode(_$StepManeuverEnumMap, json['maneuver']),
      instruction: json['instruction'] as String?,
      distance: (json['distance'] as num).toDouble(),
    );

Map<String, dynamic> _$$RouteStepImplToJson(_$RouteStepImpl instance) =>
    <String, dynamic>{
      'location': instance.location,
      'maneuver': _$StepManeuverEnumMap[instance.maneuver]!,
      'instruction': instance.instruction,
      'distance': instance.distance,
    };

const _$StepManeuverEnumMap = {
  StepManeuver.start: 'start',
  StepManeuver.straight: 'straight',
  StepManeuver.left: 'left',
  StepManeuver.right: 'right',
  StepManeuver.uTurn: 'uTurn',
  StepManeuver.floorChange: 'floorChange',
  StepManeuver.arrive: 'arrive',
};

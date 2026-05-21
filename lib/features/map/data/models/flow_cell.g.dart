// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flow_cell.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FlowCellImpl _$$FlowCellImplFromJson(Map<String, dynamic> json) =>
    _$FlowCellImpl(
      location: (json['grid_location'] as num).toInt(),
      density: (json['density'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$$FlowCellImplToJson(_$FlowCellImpl instance) =>
    <String, dynamic>{
      'grid_location': instance.location,
      'density': instance.density,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_sync_full.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MapSyncFullImpl _$$MapSyncFullImplFromJson(Map<String, dynamic> json) =>
    _$MapSyncFullImpl(
      maps:
          (json['maps'] as List<dynamic>?)
              ?.map((e) => MapFloor.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <MapFloor>[],
      pois:
          (json['pois'] as List<dynamic>?)
              ?.map((e) => MapPoi.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <MapPoi>[],
      edges:
          (json['edges'] as List<dynamic>?)
              ?.map((e) => MapEdge.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <MapEdge>[],
    );

Map<String, dynamic> _$$MapSyncFullImplToJson(_$MapSyncFullImpl instance) =>
    <String, dynamic>{
      'maps': instance.maps,
      'pois': instance.pois,
      'edges': instance.edges,
    };

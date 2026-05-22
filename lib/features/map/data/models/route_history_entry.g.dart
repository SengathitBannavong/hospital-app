// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_history_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RouteHistoryEntryImpl _$$RouteHistoryEntryImplFromJson(
  Map<String, dynamic> json,
) => _$RouteHistoryEntryImpl(
  id: json['id'] as String?,
  routeId: json['route_id'] as String?,
  poiId: (json['poi_id'] as num?)?.toInt(),
  destinationPoiId: (json['destination_poi_id'] as num?)?.toInt(),
  destPoiId: (json['dest_poi_id'] as num?)?.toInt(),
  gridLocation: (json['grid_location'] as num?)?.toInt(),
  destLocation: (json['dest_location'] as num?)?.toInt(),
  destinationName: json['destination_name'] as String?,
  destination: json['destination'] as String?,
  modeId: json['mode_id'] as String?,
  mapId: (json['map_id'] as num?)?.toInt(),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$RouteHistoryEntryImplToJson(
  _$RouteHistoryEntryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'route_id': instance.routeId,
  'poi_id': instance.poiId,
  'destination_poi_id': instance.destinationPoiId,
  'dest_poi_id': instance.destPoiId,
  'grid_location': instance.gridLocation,
  'dest_location': instance.destLocation,
  'destination_name': instance.destinationName,
  'destination': instance.destination,
  'mode_id': instance.modeId,
  'map_id': instance.mapId,
  'created_at': instance.createdAt?.toIso8601String(),
};

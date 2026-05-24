// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RouteHistoryImpl _$$RouteHistoryImplFromJson(Map<String, dynamic> json) =>
    _$RouteHistoryImpl(
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      page: (json['page'] as num?)?.toInt() ?? 1,
      total: (json['total'] as num?)?.toInt() ?? 0,
      routes:
          (json['routes'] as List<dynamic>?)
              ?.map(
                (e) => RouteHistoryEntry.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <RouteHistoryEntry>[],
    );

Map<String, dynamic> _$$RouteHistoryImplToJson(_$RouteHistoryImpl instance) =>
    <String, dynamic>{
      'limit': instance.limit,
      'page': instance.page,
      'total': instance.total,
      'routes': instance.routes,
    };

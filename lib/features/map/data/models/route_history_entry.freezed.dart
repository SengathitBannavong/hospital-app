// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'route_history_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RouteHistoryEntry _$RouteHistoryEntryFromJson(Map<String, dynamic> json) {
  return _RouteHistoryEntry.fromJson(json);
}

/// @nodoc
mixin _$RouteHistoryEntry {
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'route_id')
  String? get routeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'poi_id')
  int? get poiId => throw _privateConstructorUsedError;
  @JsonKey(name: 'destination_poi_id')
  int? get destinationPoiId => throw _privateConstructorUsedError;
  @JsonKey(name: 'dest_poi_id')
  int? get destPoiId => throw _privateConstructorUsedError;
  @JsonKey(name: 'grid_location')
  int? get gridLocation => throw _privateConstructorUsedError;
  @JsonKey(name: 'dest_location')
  int? get destLocation => throw _privateConstructorUsedError;
  @JsonKey(name: 'destination_name')
  String? get destinationName => throw _privateConstructorUsedError;
  String? get destination => throw _privateConstructorUsedError;
  @JsonKey(name: 'mode_id')
  String? get modeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'map_id')
  int? get mapId => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this RouteHistoryEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RouteHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RouteHistoryEntryCopyWith<RouteHistoryEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RouteHistoryEntryCopyWith<$Res> {
  factory $RouteHistoryEntryCopyWith(
    RouteHistoryEntry value,
    $Res Function(RouteHistoryEntry) then,
  ) = _$RouteHistoryEntryCopyWithImpl<$Res, RouteHistoryEntry>;
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'route_id') String? routeId,
    @JsonKey(name: 'poi_id') int? poiId,
    @JsonKey(name: 'destination_poi_id') int? destinationPoiId,
    @JsonKey(name: 'dest_poi_id') int? destPoiId,
    @JsonKey(name: 'grid_location') int? gridLocation,
    @JsonKey(name: 'dest_location') int? destLocation,
    @JsonKey(name: 'destination_name') String? destinationName,
    String? destination,
    @JsonKey(name: 'mode_id') String? modeId,
    @JsonKey(name: 'map_id') int? mapId,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class _$RouteHistoryEntryCopyWithImpl<$Res, $Val extends RouteHistoryEntry>
    implements $RouteHistoryEntryCopyWith<$Res> {
  _$RouteHistoryEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RouteHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? routeId = freezed,
    Object? poiId = freezed,
    Object? destinationPoiId = freezed,
    Object? destPoiId = freezed,
    Object? gridLocation = freezed,
    Object? destLocation = freezed,
    Object? destinationName = freezed,
    Object? destination = freezed,
    Object? modeId = freezed,
    Object? mapId = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            routeId: freezed == routeId
                ? _value.routeId
                : routeId // ignore: cast_nullable_to_non_nullable
                      as String?,
            poiId: freezed == poiId
                ? _value.poiId
                : poiId // ignore: cast_nullable_to_non_nullable
                      as int?,
            destinationPoiId: freezed == destinationPoiId
                ? _value.destinationPoiId
                : destinationPoiId // ignore: cast_nullable_to_non_nullable
                      as int?,
            destPoiId: freezed == destPoiId
                ? _value.destPoiId
                : destPoiId // ignore: cast_nullable_to_non_nullable
                      as int?,
            gridLocation: freezed == gridLocation
                ? _value.gridLocation
                : gridLocation // ignore: cast_nullable_to_non_nullable
                      as int?,
            destLocation: freezed == destLocation
                ? _value.destLocation
                : destLocation // ignore: cast_nullable_to_non_nullable
                      as int?,
            destinationName: freezed == destinationName
                ? _value.destinationName
                : destinationName // ignore: cast_nullable_to_non_nullable
                      as String?,
            destination: freezed == destination
                ? _value.destination
                : destination // ignore: cast_nullable_to_non_nullable
                      as String?,
            modeId: freezed == modeId
                ? _value.modeId
                : modeId // ignore: cast_nullable_to_non_nullable
                      as String?,
            mapId: freezed == mapId
                ? _value.mapId
                : mapId // ignore: cast_nullable_to_non_nullable
                      as int?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RouteHistoryEntryImplCopyWith<$Res>
    implements $RouteHistoryEntryCopyWith<$Res> {
  factory _$$RouteHistoryEntryImplCopyWith(
    _$RouteHistoryEntryImpl value,
    $Res Function(_$RouteHistoryEntryImpl) then,
  ) = __$$RouteHistoryEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    @JsonKey(name: 'route_id') String? routeId,
    @JsonKey(name: 'poi_id') int? poiId,
    @JsonKey(name: 'destination_poi_id') int? destinationPoiId,
    @JsonKey(name: 'dest_poi_id') int? destPoiId,
    @JsonKey(name: 'grid_location') int? gridLocation,
    @JsonKey(name: 'dest_location') int? destLocation,
    @JsonKey(name: 'destination_name') String? destinationName,
    String? destination,
    @JsonKey(name: 'mode_id') String? modeId,
    @JsonKey(name: 'map_id') int? mapId,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  });
}

/// @nodoc
class __$$RouteHistoryEntryImplCopyWithImpl<$Res>
    extends _$RouteHistoryEntryCopyWithImpl<$Res, _$RouteHistoryEntryImpl>
    implements _$$RouteHistoryEntryImplCopyWith<$Res> {
  __$$RouteHistoryEntryImplCopyWithImpl(
    _$RouteHistoryEntryImpl _value,
    $Res Function(_$RouteHistoryEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RouteHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? routeId = freezed,
    Object? poiId = freezed,
    Object? destinationPoiId = freezed,
    Object? destPoiId = freezed,
    Object? gridLocation = freezed,
    Object? destLocation = freezed,
    Object? destinationName = freezed,
    Object? destination = freezed,
    Object? modeId = freezed,
    Object? mapId = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$RouteHistoryEntryImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        routeId: freezed == routeId
            ? _value.routeId
            : routeId // ignore: cast_nullable_to_non_nullable
                  as String?,
        poiId: freezed == poiId
            ? _value.poiId
            : poiId // ignore: cast_nullable_to_non_nullable
                  as int?,
        destinationPoiId: freezed == destinationPoiId
            ? _value.destinationPoiId
            : destinationPoiId // ignore: cast_nullable_to_non_nullable
                  as int?,
        destPoiId: freezed == destPoiId
            ? _value.destPoiId
            : destPoiId // ignore: cast_nullable_to_non_nullable
                  as int?,
        gridLocation: freezed == gridLocation
            ? _value.gridLocation
            : gridLocation // ignore: cast_nullable_to_non_nullable
                  as int?,
        destLocation: freezed == destLocation
            ? _value.destLocation
            : destLocation // ignore: cast_nullable_to_non_nullable
                  as int?,
        destinationName: freezed == destinationName
            ? _value.destinationName
            : destinationName // ignore: cast_nullable_to_non_nullable
                  as String?,
        destination: freezed == destination
            ? _value.destination
            : destination // ignore: cast_nullable_to_non_nullable
                  as String?,
        modeId: freezed == modeId
            ? _value.modeId
            : modeId // ignore: cast_nullable_to_non_nullable
                  as String?,
        mapId: freezed == mapId
            ? _value.mapId
            : mapId // ignore: cast_nullable_to_non_nullable
                  as int?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RouteHistoryEntryImpl extends _RouteHistoryEntry {
  const _$RouteHistoryEntryImpl({
    this.id,
    @JsonKey(name: 'route_id') this.routeId,
    @JsonKey(name: 'poi_id') this.poiId,
    @JsonKey(name: 'destination_poi_id') this.destinationPoiId,
    @JsonKey(name: 'dest_poi_id') this.destPoiId,
    @JsonKey(name: 'grid_location') this.gridLocation,
    @JsonKey(name: 'dest_location') this.destLocation,
    @JsonKey(name: 'destination_name') this.destinationName,
    this.destination,
    @JsonKey(name: 'mode_id') this.modeId,
    @JsonKey(name: 'map_id') this.mapId,
    @JsonKey(name: 'created_at') this.createdAt,
  }) : super._();

  factory _$RouteHistoryEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$RouteHistoryEntryImplFromJson(json);

  @override
  final String? id;
  @override
  @JsonKey(name: 'route_id')
  final String? routeId;
  @override
  @JsonKey(name: 'poi_id')
  final int? poiId;
  @override
  @JsonKey(name: 'destination_poi_id')
  final int? destinationPoiId;
  @override
  @JsonKey(name: 'dest_poi_id')
  final int? destPoiId;
  @override
  @JsonKey(name: 'grid_location')
  final int? gridLocation;
  @override
  @JsonKey(name: 'dest_location')
  final int? destLocation;
  @override
  @JsonKey(name: 'destination_name')
  final String? destinationName;
  @override
  final String? destination;
  @override
  @JsonKey(name: 'mode_id')
  final String? modeId;
  @override
  @JsonKey(name: 'map_id')
  final int? mapId;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @override
  String toString() {
    return 'RouteHistoryEntry(id: $id, routeId: $routeId, poiId: $poiId, destinationPoiId: $destinationPoiId, destPoiId: $destPoiId, gridLocation: $gridLocation, destLocation: $destLocation, destinationName: $destinationName, destination: $destination, modeId: $modeId, mapId: $mapId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RouteHistoryEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.routeId, routeId) || other.routeId == routeId) &&
            (identical(other.poiId, poiId) || other.poiId == poiId) &&
            (identical(other.destinationPoiId, destinationPoiId) ||
                other.destinationPoiId == destinationPoiId) &&
            (identical(other.destPoiId, destPoiId) ||
                other.destPoiId == destPoiId) &&
            (identical(other.gridLocation, gridLocation) ||
                other.gridLocation == gridLocation) &&
            (identical(other.destLocation, destLocation) ||
                other.destLocation == destLocation) &&
            (identical(other.destinationName, destinationName) ||
                other.destinationName == destinationName) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            (identical(other.modeId, modeId) || other.modeId == modeId) &&
            (identical(other.mapId, mapId) || other.mapId == mapId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    routeId,
    poiId,
    destinationPoiId,
    destPoiId,
    gridLocation,
    destLocation,
    destinationName,
    destination,
    modeId,
    mapId,
    createdAt,
  );

  /// Create a copy of RouteHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RouteHistoryEntryImplCopyWith<_$RouteHistoryEntryImpl> get copyWith =>
      __$$RouteHistoryEntryImplCopyWithImpl<_$RouteHistoryEntryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RouteHistoryEntryImplToJson(this);
  }
}

abstract class _RouteHistoryEntry extends RouteHistoryEntry {
  const factory _RouteHistoryEntry({
    final String? id,
    @JsonKey(name: 'route_id') final String? routeId,
    @JsonKey(name: 'poi_id') final int? poiId,
    @JsonKey(name: 'destination_poi_id') final int? destinationPoiId,
    @JsonKey(name: 'dest_poi_id') final int? destPoiId,
    @JsonKey(name: 'grid_location') final int? gridLocation,
    @JsonKey(name: 'dest_location') final int? destLocation,
    @JsonKey(name: 'destination_name') final String? destinationName,
    final String? destination,
    @JsonKey(name: 'mode_id') final String? modeId,
    @JsonKey(name: 'map_id') final int? mapId,
    @JsonKey(name: 'created_at') final DateTime? createdAt,
  }) = _$RouteHistoryEntryImpl;
  const _RouteHistoryEntry._() : super._();

  factory _RouteHistoryEntry.fromJson(Map<String, dynamic> json) =
      _$RouteHistoryEntryImpl.fromJson;

  @override
  String? get id;
  @override
  @JsonKey(name: 'route_id')
  String? get routeId;
  @override
  @JsonKey(name: 'poi_id')
  int? get poiId;
  @override
  @JsonKey(name: 'destination_poi_id')
  int? get destinationPoiId;
  @override
  @JsonKey(name: 'dest_poi_id')
  int? get destPoiId;
  @override
  @JsonKey(name: 'grid_location')
  int? get gridLocation;
  @override
  @JsonKey(name: 'dest_location')
  int? get destLocation;
  @override
  @JsonKey(name: 'destination_name')
  String? get destinationName;
  @override
  String? get destination;
  @override
  @JsonKey(name: 'mode_id')
  String? get modeId;
  @override
  @JsonKey(name: 'map_id')
  int? get mapId;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;

  /// Create a copy of RouteHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RouteHistoryEntryImplCopyWith<_$RouteHistoryEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

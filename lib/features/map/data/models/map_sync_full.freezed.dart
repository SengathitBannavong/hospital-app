// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_sync_full.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MapSyncFull _$MapSyncFullFromJson(Map<String, dynamic> json) {
  return _MapSyncFull.fromJson(json);
}

/// @nodoc
mixin _$MapSyncFull {
  @JsonKey(name: 'maps')
  List<MapFloor> get maps => throw _privateConstructorUsedError;
  @JsonKey(name: 'pois')
  List<MapPoi> get pois => throw _privateConstructorUsedError;
  @JsonKey(name: 'edges')
  List<MapEdge> get edges => throw _privateConstructorUsedError;

  /// Serializes this MapSyncFull to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MapSyncFull
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MapSyncFullCopyWith<MapSyncFull> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MapSyncFullCopyWith<$Res> {
  factory $MapSyncFullCopyWith(
    MapSyncFull value,
    $Res Function(MapSyncFull) then,
  ) = _$MapSyncFullCopyWithImpl<$Res, MapSyncFull>;
  @useResult
  $Res call({
    @JsonKey(name: 'maps') List<MapFloor> maps,
    @JsonKey(name: 'pois') List<MapPoi> pois,
    @JsonKey(name: 'edges') List<MapEdge> edges,
  });
}

/// @nodoc
class _$MapSyncFullCopyWithImpl<$Res, $Val extends MapSyncFull>
    implements $MapSyncFullCopyWith<$Res> {
  _$MapSyncFullCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MapSyncFull
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? maps = null, Object? pois = null, Object? edges = null}) {
    return _then(
      _value.copyWith(
            maps: null == maps
                ? _value.maps
                : maps // ignore: cast_nullable_to_non_nullable
                      as List<MapFloor>,
            pois: null == pois
                ? _value.pois
                : pois // ignore: cast_nullable_to_non_nullable
                      as List<MapPoi>,
            edges: null == edges
                ? _value.edges
                : edges // ignore: cast_nullable_to_non_nullable
                      as List<MapEdge>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MapSyncFullImplCopyWith<$Res>
    implements $MapSyncFullCopyWith<$Res> {
  factory _$$MapSyncFullImplCopyWith(
    _$MapSyncFullImpl value,
    $Res Function(_$MapSyncFullImpl) then,
  ) = __$$MapSyncFullImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'maps') List<MapFloor> maps,
    @JsonKey(name: 'pois') List<MapPoi> pois,
    @JsonKey(name: 'edges') List<MapEdge> edges,
  });
}

/// @nodoc
class __$$MapSyncFullImplCopyWithImpl<$Res>
    extends _$MapSyncFullCopyWithImpl<$Res, _$MapSyncFullImpl>
    implements _$$MapSyncFullImplCopyWith<$Res> {
  __$$MapSyncFullImplCopyWithImpl(
    _$MapSyncFullImpl _value,
    $Res Function(_$MapSyncFullImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MapSyncFull
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? maps = null, Object? pois = null, Object? edges = null}) {
    return _then(
      _$MapSyncFullImpl(
        maps: null == maps
            ? _value._maps
            : maps // ignore: cast_nullable_to_non_nullable
                  as List<MapFloor>,
        pois: null == pois
            ? _value._pois
            : pois // ignore: cast_nullable_to_non_nullable
                  as List<MapPoi>,
        edges: null == edges
            ? _value._edges
            : edges // ignore: cast_nullable_to_non_nullable
                  as List<MapEdge>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MapSyncFullImpl implements _MapSyncFull {
  const _$MapSyncFullImpl({
    @JsonKey(name: 'maps') final List<MapFloor> maps = const <MapFloor>[],
    @JsonKey(name: 'pois') final List<MapPoi> pois = const <MapPoi>[],
    @JsonKey(name: 'edges') final List<MapEdge> edges = const <MapEdge>[],
  }) : _maps = maps,
       _pois = pois,
       _edges = edges;

  factory _$MapSyncFullImpl.fromJson(Map<String, dynamic> json) =>
      _$$MapSyncFullImplFromJson(json);

  final List<MapFloor> _maps;
  @override
  @JsonKey(name: 'maps')
  List<MapFloor> get maps {
    if (_maps is EqualUnmodifiableListView) return _maps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_maps);
  }

  final List<MapPoi> _pois;
  @override
  @JsonKey(name: 'pois')
  List<MapPoi> get pois {
    if (_pois is EqualUnmodifiableListView) return _pois;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pois);
  }

  final List<MapEdge> _edges;
  @override
  @JsonKey(name: 'edges')
  List<MapEdge> get edges {
    if (_edges is EqualUnmodifiableListView) return _edges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_edges);
  }

  @override
  String toString() {
    return 'MapSyncFull(maps: $maps, pois: $pois, edges: $edges)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MapSyncFullImpl &&
            const DeepCollectionEquality().equals(other._maps, _maps) &&
            const DeepCollectionEquality().equals(other._pois, _pois) &&
            const DeepCollectionEquality().equals(other._edges, _edges));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_maps),
    const DeepCollectionEquality().hash(_pois),
    const DeepCollectionEquality().hash(_edges),
  );

  /// Create a copy of MapSyncFull
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MapSyncFullImplCopyWith<_$MapSyncFullImpl> get copyWith =>
      __$$MapSyncFullImplCopyWithImpl<_$MapSyncFullImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MapSyncFullImplToJson(this);
  }
}

abstract class _MapSyncFull implements MapSyncFull {
  const factory _MapSyncFull({
    @JsonKey(name: 'maps') final List<MapFloor> maps,
    @JsonKey(name: 'pois') final List<MapPoi> pois,
    @JsonKey(name: 'edges') final List<MapEdge> edges,
  }) = _$MapSyncFullImpl;

  factory _MapSyncFull.fromJson(Map<String, dynamic> json) =
      _$MapSyncFullImpl.fromJson;

  @override
  @JsonKey(name: 'maps')
  List<MapFloor> get maps;
  @override
  @JsonKey(name: 'pois')
  List<MapPoi> get pois;
  @override
  @JsonKey(name: 'edges')
  List<MapEdge> get edges;

  /// Create a copy of MapSyncFull
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MapSyncFullImplCopyWith<_$MapSyncFullImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

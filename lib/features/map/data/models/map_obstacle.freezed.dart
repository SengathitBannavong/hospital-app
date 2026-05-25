// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_obstacle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MapObstacle _$MapObstacleFromJson(Map<String, dynamic> json) {
  return _MapObstacle.fromJson(json);
}

/// @nodoc
mixin _$MapObstacle {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'grid_location')
  int get gridLocation => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  @JsonKey(name: 'reported_at')
  DateTime get reportedAt => throw _privateConstructorUsedError;

  /// Serializes this MapObstacle to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MapObstacle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MapObstacleCopyWith<MapObstacle> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MapObstacleCopyWith<$Res> {
  factory $MapObstacleCopyWith(
    MapObstacle value,
    $Res Function(MapObstacle) then,
  ) = _$MapObstacleCopyWithImpl<$Res, MapObstacle>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'grid_location') int gridLocation,
    String type,
    String? note,
    @JsonKey(name: 'reported_at') DateTime reportedAt,
  });
}

/// @nodoc
class _$MapObstacleCopyWithImpl<$Res, $Val extends MapObstacle>
    implements $MapObstacleCopyWith<$Res> {
  _$MapObstacleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MapObstacle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? gridLocation = null,
    Object? type = null,
    Object? note = freezed,
    Object? reportedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            gridLocation: null == gridLocation
                ? _value.gridLocation
                : gridLocation // ignore: cast_nullable_to_non_nullable
                      as int,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
            reportedAt: null == reportedAt
                ? _value.reportedAt
                : reportedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MapObstacleImplCopyWith<$Res>
    implements $MapObstacleCopyWith<$Res> {
  factory _$$MapObstacleImplCopyWith(
    _$MapObstacleImpl value,
    $Res Function(_$MapObstacleImpl) then,
  ) = __$$MapObstacleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'grid_location') int gridLocation,
    String type,
    String? note,
    @JsonKey(name: 'reported_at') DateTime reportedAt,
  });
}

/// @nodoc
class __$$MapObstacleImplCopyWithImpl<$Res>
    extends _$MapObstacleCopyWithImpl<$Res, _$MapObstacleImpl>
    implements _$$MapObstacleImplCopyWith<$Res> {
  __$$MapObstacleImplCopyWithImpl(
    _$MapObstacleImpl _value,
    $Res Function(_$MapObstacleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MapObstacle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? gridLocation = null,
    Object? type = null,
    Object? note = freezed,
    Object? reportedAt = null,
  }) {
    return _then(
      _$MapObstacleImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        gridLocation: null == gridLocation
            ? _value.gridLocation
            : gridLocation // ignore: cast_nullable_to_non_nullable
                  as int,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
        reportedAt: null == reportedAt
            ? _value.reportedAt
            : reportedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MapObstacleImpl implements _MapObstacle {
  const _$MapObstacleImpl({
    required this.id,
    @JsonKey(name: 'grid_location') required this.gridLocation,
    required this.type,
    this.note,
    @JsonKey(name: 'reported_at') required this.reportedAt,
  });

  factory _$MapObstacleImpl.fromJson(Map<String, dynamic> json) =>
      _$$MapObstacleImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'grid_location')
  final int gridLocation;
  @override
  final String type;
  @override
  final String? note;
  @override
  @JsonKey(name: 'reported_at')
  final DateTime reportedAt;

  @override
  String toString() {
    return 'MapObstacle(id: $id, gridLocation: $gridLocation, type: $type, note: $note, reportedAt: $reportedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MapObstacleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.gridLocation, gridLocation) ||
                other.gridLocation == gridLocation) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.reportedAt, reportedAt) ||
                other.reportedAt == reportedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, gridLocation, type, note, reportedAt);

  /// Create a copy of MapObstacle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MapObstacleImplCopyWith<_$MapObstacleImpl> get copyWith =>
      __$$MapObstacleImplCopyWithImpl<_$MapObstacleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MapObstacleImplToJson(this);
  }
}

abstract class _MapObstacle implements MapObstacle {
  const factory _MapObstacle({
    required final String id,
    @JsonKey(name: 'grid_location') required final int gridLocation,
    required final String type,
    final String? note,
    @JsonKey(name: 'reported_at') required final DateTime reportedAt,
  }) = _$MapObstacleImpl;

  factory _MapObstacle.fromJson(Map<String, dynamic> json) =
      _$MapObstacleImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'grid_location')
  int get gridLocation;
  @override
  String get type;
  @override
  String? get note;
  @override
  @JsonKey(name: 'reported_at')
  DateTime get reportedAt;

  /// Create a copy of MapObstacle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MapObstacleImplCopyWith<_$MapObstacleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

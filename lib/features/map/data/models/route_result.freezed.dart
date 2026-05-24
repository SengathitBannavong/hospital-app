// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'route_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RouteResult _$RouteResultFromJson(Map<String, dynamic> json) {
  return _RouteResult.fromJson(json);
}

/// @nodoc
mixin _$RouteResult {
  List<int> get path => throw _privateConstructorUsedError;
  List<RouteStep> get steps => throw _privateConstructorUsedError;
  double get distance => throw _privateConstructorUsedError;
  @JsonKey(name: 'estimated_time')
  double get estimatedTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'mode_id')
  String get modeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'speed_factor')
  double get speedFactor => throw _privateConstructorUsedError;

  /// Serializes this RouteResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RouteResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RouteResultCopyWith<RouteResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RouteResultCopyWith<$Res> {
  factory $RouteResultCopyWith(
    RouteResult value,
    $Res Function(RouteResult) then,
  ) = _$RouteResultCopyWithImpl<$Res, RouteResult>;
  @useResult
  $Res call({
    List<int> path,
    List<RouteStep> steps,
    double distance,
    @JsonKey(name: 'estimated_time') double estimatedTime,
    @JsonKey(name: 'mode_id') String modeId,
    @JsonKey(name: 'speed_factor') double speedFactor,
  });
}

/// @nodoc
class _$RouteResultCopyWithImpl<$Res, $Val extends RouteResult>
    implements $RouteResultCopyWith<$Res> {
  _$RouteResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RouteResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? path = null,
    Object? steps = null,
    Object? distance = null,
    Object? estimatedTime = null,
    Object? modeId = null,
    Object? speedFactor = null,
  }) {
    return _then(
      _value.copyWith(
            path: null == path
                ? _value.path
                : path // ignore: cast_nullable_to_non_nullable
                      as List<int>,
            steps: null == steps
                ? _value.steps
                : steps // ignore: cast_nullable_to_non_nullable
                      as List<RouteStep>,
            distance: null == distance
                ? _value.distance
                : distance // ignore: cast_nullable_to_non_nullable
                      as double,
            estimatedTime: null == estimatedTime
                ? _value.estimatedTime
                : estimatedTime // ignore: cast_nullable_to_non_nullable
                      as double,
            modeId: null == modeId
                ? _value.modeId
                : modeId // ignore: cast_nullable_to_non_nullable
                      as String,
            speedFactor: null == speedFactor
                ? _value.speedFactor
                : speedFactor // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RouteResultImplCopyWith<$Res>
    implements $RouteResultCopyWith<$Res> {
  factory _$$RouteResultImplCopyWith(
    _$RouteResultImpl value,
    $Res Function(_$RouteResultImpl) then,
  ) = __$$RouteResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<int> path,
    List<RouteStep> steps,
    double distance,
    @JsonKey(name: 'estimated_time') double estimatedTime,
    @JsonKey(name: 'mode_id') String modeId,
    @JsonKey(name: 'speed_factor') double speedFactor,
  });
}

/// @nodoc
class __$$RouteResultImplCopyWithImpl<$Res>
    extends _$RouteResultCopyWithImpl<$Res, _$RouteResultImpl>
    implements _$$RouteResultImplCopyWith<$Res> {
  __$$RouteResultImplCopyWithImpl(
    _$RouteResultImpl _value,
    $Res Function(_$RouteResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RouteResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? path = null,
    Object? steps = null,
    Object? distance = null,
    Object? estimatedTime = null,
    Object? modeId = null,
    Object? speedFactor = null,
  }) {
    return _then(
      _$RouteResultImpl(
        path: null == path
            ? _value._path
            : path // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        steps: null == steps
            ? _value._steps
            : steps // ignore: cast_nullable_to_non_nullable
                  as List<RouteStep>,
        distance: null == distance
            ? _value.distance
            : distance // ignore: cast_nullable_to_non_nullable
                  as double,
        estimatedTime: null == estimatedTime
            ? _value.estimatedTime
            : estimatedTime // ignore: cast_nullable_to_non_nullable
                  as double,
        modeId: null == modeId
            ? _value.modeId
            : modeId // ignore: cast_nullable_to_non_nullable
                  as String,
        speedFactor: null == speedFactor
            ? _value.speedFactor
            : speedFactor // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RouteResultImpl implements _RouteResult {
  const _$RouteResultImpl({
    required final List<int> path,
    required final List<RouteStep> steps,
    required this.distance,
    @JsonKey(name: 'estimated_time') required this.estimatedTime,
    @JsonKey(name: 'mode_id') required this.modeId,
    @JsonKey(name: 'speed_factor') required this.speedFactor,
  }) : _path = path,
       _steps = steps;

  factory _$RouteResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$RouteResultImplFromJson(json);

  final List<int> _path;
  @override
  List<int> get path {
    if (_path is EqualUnmodifiableListView) return _path;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_path);
  }

  final List<RouteStep> _steps;
  @override
  List<RouteStep> get steps {
    if (_steps is EqualUnmodifiableListView) return _steps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_steps);
  }

  @override
  final double distance;
  @override
  @JsonKey(name: 'estimated_time')
  final double estimatedTime;
  @override
  @JsonKey(name: 'mode_id')
  final String modeId;
  @override
  @JsonKey(name: 'speed_factor')
  final double speedFactor;

  @override
  String toString() {
    return 'RouteResult(path: $path, steps: $steps, distance: $distance, estimatedTime: $estimatedTime, modeId: $modeId, speedFactor: $speedFactor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RouteResultImpl &&
            const DeepCollectionEquality().equals(other._path, _path) &&
            const DeepCollectionEquality().equals(other._steps, _steps) &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.estimatedTime, estimatedTime) ||
                other.estimatedTime == estimatedTime) &&
            (identical(other.modeId, modeId) || other.modeId == modeId) &&
            (identical(other.speedFactor, speedFactor) ||
                other.speedFactor == speedFactor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_path),
    const DeepCollectionEquality().hash(_steps),
    distance,
    estimatedTime,
    modeId,
    speedFactor,
  );

  /// Create a copy of RouteResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RouteResultImplCopyWith<_$RouteResultImpl> get copyWith =>
      __$$RouteResultImplCopyWithImpl<_$RouteResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RouteResultImplToJson(this);
  }
}

abstract class _RouteResult implements RouteResult {
  const factory _RouteResult({
    required final List<int> path,
    required final List<RouteStep> steps,
    required final double distance,
    @JsonKey(name: 'estimated_time') required final double estimatedTime,
    @JsonKey(name: 'mode_id') required final String modeId,
    @JsonKey(name: 'speed_factor') required final double speedFactor,
  }) = _$RouteResultImpl;

  factory _RouteResult.fromJson(Map<String, dynamic> json) =
      _$RouteResultImpl.fromJson;

  @override
  List<int> get path;
  @override
  List<RouteStep> get steps;
  @override
  double get distance;
  @override
  @JsonKey(name: 'estimated_time')
  double get estimatedTime;
  @override
  @JsonKey(name: 'mode_id')
  String get modeId;
  @override
  @JsonKey(name: 'speed_factor')
  double get speedFactor;

  /// Create a copy of RouteResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RouteResultImplCopyWith<_$RouteResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

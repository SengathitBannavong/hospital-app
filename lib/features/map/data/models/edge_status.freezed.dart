// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'edge_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

EdgeStatus _$EdgeStatusFromJson(Map<String, dynamic> json) {
  return _EdgeStatus.fromJson(json);
}

/// @nodoc
mixin _$EdgeStatus {
  @JsonKey(name: 'from_location')
  int get fromLocation => throw _privateConstructorUsedError;
  @JsonKey(name: 'to_location')
  int get toLocation => throw _privateConstructorUsedError;
  double get congestion => throw _privateConstructorUsedError;
  bool get blocked => throw _privateConstructorUsedError;

  /// Serializes this EdgeStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EdgeStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EdgeStatusCopyWith<EdgeStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EdgeStatusCopyWith<$Res> {
  factory $EdgeStatusCopyWith(
    EdgeStatus value,
    $Res Function(EdgeStatus) then,
  ) = _$EdgeStatusCopyWithImpl<$Res, EdgeStatus>;
  @useResult
  $Res call({
    @JsonKey(name: 'from_location') int fromLocation,
    @JsonKey(name: 'to_location') int toLocation,
    double congestion,
    bool blocked,
  });
}

/// @nodoc
class _$EdgeStatusCopyWithImpl<$Res, $Val extends EdgeStatus>
    implements $EdgeStatusCopyWith<$Res> {
  _$EdgeStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EdgeStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fromLocation = null,
    Object? toLocation = null,
    Object? congestion = null,
    Object? blocked = null,
  }) {
    return _then(
      _value.copyWith(
            fromLocation: null == fromLocation
                ? _value.fromLocation
                : fromLocation // ignore: cast_nullable_to_non_nullable
                      as int,
            toLocation: null == toLocation
                ? _value.toLocation
                : toLocation // ignore: cast_nullable_to_non_nullable
                      as int,
            congestion: null == congestion
                ? _value.congestion
                : congestion // ignore: cast_nullable_to_non_nullable
                      as double,
            blocked: null == blocked
                ? _value.blocked
                : blocked // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EdgeStatusImplCopyWith<$Res>
    implements $EdgeStatusCopyWith<$Res> {
  factory _$$EdgeStatusImplCopyWith(
    _$EdgeStatusImpl value,
    $Res Function(_$EdgeStatusImpl) then,
  ) = __$$EdgeStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'from_location') int fromLocation,
    @JsonKey(name: 'to_location') int toLocation,
    double congestion,
    bool blocked,
  });
}

/// @nodoc
class __$$EdgeStatusImplCopyWithImpl<$Res>
    extends _$EdgeStatusCopyWithImpl<$Res, _$EdgeStatusImpl>
    implements _$$EdgeStatusImplCopyWith<$Res> {
  __$$EdgeStatusImplCopyWithImpl(
    _$EdgeStatusImpl _value,
    $Res Function(_$EdgeStatusImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EdgeStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fromLocation = null,
    Object? toLocation = null,
    Object? congestion = null,
    Object? blocked = null,
  }) {
    return _then(
      _$EdgeStatusImpl(
        fromLocation: null == fromLocation
            ? _value.fromLocation
            : fromLocation // ignore: cast_nullable_to_non_nullable
                  as int,
        toLocation: null == toLocation
            ? _value.toLocation
            : toLocation // ignore: cast_nullable_to_non_nullable
                  as int,
        congestion: null == congestion
            ? _value.congestion
            : congestion // ignore: cast_nullable_to_non_nullable
                  as double,
        blocked: null == blocked
            ? _value.blocked
            : blocked // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EdgeStatusImpl implements _EdgeStatus {
  const _$EdgeStatusImpl({
    @JsonKey(name: 'from_location') required this.fromLocation,
    @JsonKey(name: 'to_location') required this.toLocation,
    this.congestion = 0,
    this.blocked = false,
  });

  factory _$EdgeStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$EdgeStatusImplFromJson(json);

  @override
  @JsonKey(name: 'from_location')
  final int fromLocation;
  @override
  @JsonKey(name: 'to_location')
  final int toLocation;
  @override
  @JsonKey()
  final double congestion;
  @override
  @JsonKey()
  final bool blocked;

  @override
  String toString() {
    return 'EdgeStatus(fromLocation: $fromLocation, toLocation: $toLocation, congestion: $congestion, blocked: $blocked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EdgeStatusImpl &&
            (identical(other.fromLocation, fromLocation) ||
                other.fromLocation == fromLocation) &&
            (identical(other.toLocation, toLocation) ||
                other.toLocation == toLocation) &&
            (identical(other.congestion, congestion) ||
                other.congestion == congestion) &&
            (identical(other.blocked, blocked) || other.blocked == blocked));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, fromLocation, toLocation, congestion, blocked);

  /// Create a copy of EdgeStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EdgeStatusImplCopyWith<_$EdgeStatusImpl> get copyWith =>
      __$$EdgeStatusImplCopyWithImpl<_$EdgeStatusImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EdgeStatusImplToJson(this);
  }
}

abstract class _EdgeStatus implements EdgeStatus {
  const factory _EdgeStatus({
    @JsonKey(name: 'from_location') required final int fromLocation,
    @JsonKey(name: 'to_location') required final int toLocation,
    final double congestion,
    final bool blocked,
  }) = _$EdgeStatusImpl;

  factory _EdgeStatus.fromJson(Map<String, dynamic> json) =
      _$EdgeStatusImpl.fromJson;

  @override
  @JsonKey(name: 'from_location')
  int get fromLocation;
  @override
  @JsonKey(name: 'to_location')
  int get toLocation;
  @override
  double get congestion;
  @override
  bool get blocked;

  /// Create a copy of EdgeStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EdgeStatusImplCopyWith<_$EdgeStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

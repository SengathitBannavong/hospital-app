// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flow_forecast_bucket.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FlowForecastBucket _$FlowForecastBucketFromJson(Map<String, dynamic> json) {
  return _FlowForecastBucket.fromJson(json);
}

/// @nodoc
mixin _$FlowForecastBucket {
  int get hour => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;

  /// Serializes this FlowForecastBucket to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FlowForecastBucket
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FlowForecastBucketCopyWith<FlowForecastBucket> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FlowForecastBucketCopyWith<$Res> {
  factory $FlowForecastBucketCopyWith(
    FlowForecastBucket value,
    $Res Function(FlowForecastBucket) then,
  ) = _$FlowForecastBucketCopyWithImpl<$Res, FlowForecastBucket>;
  @useResult
  $Res call({int hour, int count});
}

/// @nodoc
class _$FlowForecastBucketCopyWithImpl<$Res, $Val extends FlowForecastBucket>
    implements $FlowForecastBucketCopyWith<$Res> {
  _$FlowForecastBucketCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FlowForecastBucket
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? hour = null, Object? count = null}) {
    return _then(
      _value.copyWith(
            hour: null == hour
                ? _value.hour
                : hour // ignore: cast_nullable_to_non_nullable
                      as int,
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FlowForecastBucketImplCopyWith<$Res>
    implements $FlowForecastBucketCopyWith<$Res> {
  factory _$$FlowForecastBucketImplCopyWith(
    _$FlowForecastBucketImpl value,
    $Res Function(_$FlowForecastBucketImpl) then,
  ) = __$$FlowForecastBucketImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int hour, int count});
}

/// @nodoc
class __$$FlowForecastBucketImplCopyWithImpl<$Res>
    extends _$FlowForecastBucketCopyWithImpl<$Res, _$FlowForecastBucketImpl>
    implements _$$FlowForecastBucketImplCopyWith<$Res> {
  __$$FlowForecastBucketImplCopyWithImpl(
    _$FlowForecastBucketImpl _value,
    $Res Function(_$FlowForecastBucketImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FlowForecastBucket
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? hour = null, Object? count = null}) {
    return _then(
      _$FlowForecastBucketImpl(
        hour: null == hour
            ? _value.hour
            : hour // ignore: cast_nullable_to_non_nullable
                  as int,
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FlowForecastBucketImpl implements _FlowForecastBucket {
  const _$FlowForecastBucketImpl({required this.hour, this.count = 0});

  factory _$FlowForecastBucketImpl.fromJson(Map<String, dynamic> json) =>
      _$$FlowForecastBucketImplFromJson(json);

  @override
  final int hour;
  @override
  @JsonKey()
  final int count;

  @override
  String toString() {
    return 'FlowForecastBucket(hour: $hour, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FlowForecastBucketImpl &&
            (identical(other.hour, hour) || other.hour == hour) &&
            (identical(other.count, count) || other.count == count));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, hour, count);

  /// Create a copy of FlowForecastBucket
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FlowForecastBucketImplCopyWith<_$FlowForecastBucketImpl> get copyWith =>
      __$$FlowForecastBucketImplCopyWithImpl<_$FlowForecastBucketImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FlowForecastBucketImplToJson(this);
  }
}

abstract class _FlowForecastBucket implements FlowForecastBucket {
  const factory _FlowForecastBucket({
    required final int hour,
    final int count,
  }) = _$FlowForecastBucketImpl;

  factory _FlowForecastBucket.fromJson(Map<String, dynamic> json) =
      _$FlowForecastBucketImpl.fromJson;

  @override
  int get hour;
  @override
  int get count;

  /// Create a copy of FlowForecastBucket
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FlowForecastBucketImplCopyWith<_$FlowForecastBucketImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flow_alert.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FlowAlert _$FlowAlertFromJson(Map<String, dynamic> json) {
  return _FlowAlert.fromJson(json);
}

/// @nodoc
mixin _$FlowAlert {
  String get id => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  int? get location => throw _privateConstructorUsedError;
  String get level => throw _privateConstructorUsedError;

  /// Serializes this FlowAlert to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FlowAlert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FlowAlertCopyWith<FlowAlert> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FlowAlertCopyWith<$Res> {
  factory $FlowAlertCopyWith(FlowAlert value, $Res Function(FlowAlert) then) =
      _$FlowAlertCopyWithImpl<$Res, FlowAlert>;
  @useResult
  $Res call({String id, String message, int? location, String level});
}

/// @nodoc
class _$FlowAlertCopyWithImpl<$Res, $Val extends FlowAlert>
    implements $FlowAlertCopyWith<$Res> {
  _$FlowAlertCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FlowAlert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? message = null,
    Object? location = freezed,
    Object? level = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as int?,
            level: null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FlowAlertImplCopyWith<$Res>
    implements $FlowAlertCopyWith<$Res> {
  factory _$$FlowAlertImplCopyWith(
    _$FlowAlertImpl value,
    $Res Function(_$FlowAlertImpl) then,
  ) = __$$FlowAlertImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String message, int? location, String level});
}

/// @nodoc
class __$$FlowAlertImplCopyWithImpl<$Res>
    extends _$FlowAlertCopyWithImpl<$Res, _$FlowAlertImpl>
    implements _$$FlowAlertImplCopyWith<$Res> {
  __$$FlowAlertImplCopyWithImpl(
    _$FlowAlertImpl _value,
    $Res Function(_$FlowAlertImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FlowAlert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? message = null,
    Object? location = freezed,
    Object? level = null,
  }) {
    return _then(
      _$FlowAlertImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as int?,
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FlowAlertImpl implements _FlowAlert {
  const _$FlowAlertImpl({
    required this.id,
    required this.message,
    this.location,
    this.level = 'info',
  });

  factory _$FlowAlertImpl.fromJson(Map<String, dynamic> json) =>
      _$$FlowAlertImplFromJson(json);

  @override
  final String id;
  @override
  final String message;
  @override
  final int? location;
  @override
  @JsonKey()
  final String level;

  @override
  String toString() {
    return 'FlowAlert(id: $id, message: $message, location: $location, level: $level)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FlowAlertImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.level, level) || other.level == level));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, message, location, level);

  /// Create a copy of FlowAlert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FlowAlertImplCopyWith<_$FlowAlertImpl> get copyWith =>
      __$$FlowAlertImplCopyWithImpl<_$FlowAlertImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FlowAlertImplToJson(this);
  }
}

abstract class _FlowAlert implements FlowAlert {
  const factory _FlowAlert({
    required final String id,
    required final String message,
    final int? location,
    final String level,
  }) = _$FlowAlertImpl;

  factory _FlowAlert.fromJson(Map<String, dynamic> json) =
      _$FlowAlertImpl.fromJson;

  @override
  String get id;
  @override
  String get message;
  @override
  int? get location;
  @override
  String get level;

  /// Create a copy of FlowAlert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FlowAlertImplCopyWith<_$FlowAlertImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

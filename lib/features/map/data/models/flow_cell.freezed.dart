// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flow_cell.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FlowCell _$FlowCellFromJson(Map<String, dynamic> json) {
  return _FlowCell.fromJson(json);
}

/// @nodoc
mixin _$FlowCell {
  @JsonKey(name: 'grid_location')
  int get location => throw _privateConstructorUsedError;
  double get density => throw _privateConstructorUsedError;

  /// Serializes this FlowCell to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FlowCell
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FlowCellCopyWith<FlowCell> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FlowCellCopyWith<$Res> {
  factory $FlowCellCopyWith(FlowCell value, $Res Function(FlowCell) then) =
      _$FlowCellCopyWithImpl<$Res, FlowCell>;
  @useResult
  $Res call({@JsonKey(name: 'grid_location') int location, double density});
}

/// @nodoc
class _$FlowCellCopyWithImpl<$Res, $Val extends FlowCell>
    implements $FlowCellCopyWith<$Res> {
  _$FlowCellCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FlowCell
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? location = null, Object? density = null}) {
    return _then(
      _value.copyWith(
            location: null == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as int,
            density: null == density
                ? _value.density
                : density // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FlowCellImplCopyWith<$Res>
    implements $FlowCellCopyWith<$Res> {
  factory _$$FlowCellImplCopyWith(
    _$FlowCellImpl value,
    $Res Function(_$FlowCellImpl) then,
  ) = __$$FlowCellImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'grid_location') int location, double density});
}

/// @nodoc
class __$$FlowCellImplCopyWithImpl<$Res>
    extends _$FlowCellCopyWithImpl<$Res, _$FlowCellImpl>
    implements _$$FlowCellImplCopyWith<$Res> {
  __$$FlowCellImplCopyWithImpl(
    _$FlowCellImpl _value,
    $Res Function(_$FlowCellImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FlowCell
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? location = null, Object? density = null}) {
    return _then(
      _$FlowCellImpl(
        location: null == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as int,
        density: null == density
            ? _value.density
            : density // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FlowCellImpl implements _FlowCell {
  const _$FlowCellImpl({
    @JsonKey(name: 'grid_location') required this.location,
    this.density = 0,
  });

  factory _$FlowCellImpl.fromJson(Map<String, dynamic> json) =>
      _$$FlowCellImplFromJson(json);

  @override
  @JsonKey(name: 'grid_location')
  final int location;
  @override
  @JsonKey()
  final double density;

  @override
  String toString() {
    return 'FlowCell(location: $location, density: $density)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FlowCellImpl &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.density, density) || other.density == density));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, location, density);

  /// Create a copy of FlowCell
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FlowCellImplCopyWith<_$FlowCellImpl> get copyWith =>
      __$$FlowCellImplCopyWithImpl<_$FlowCellImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FlowCellImplToJson(this);
  }
}

abstract class _FlowCell implements FlowCell {
  const factory _FlowCell({
    @JsonKey(name: 'grid_location') required final int location,
    final double density,
  }) = _$FlowCellImpl;

  factory _FlowCell.fromJson(Map<String, dynamic> json) =
      _$FlowCellImpl.fromJson;

  @override
  @JsonKey(name: 'grid_location')
  int get location;
  @override
  double get density;

  /// Create a copy of FlowCell
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FlowCellImplCopyWith<_$FlowCellImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

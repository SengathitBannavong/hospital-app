// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'route_history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RouteHistory _$RouteHistoryFromJson(Map<String, dynamic> json) {
  return _RouteHistory.fromJson(json);
}

/// @nodoc
mixin _$RouteHistory {
  int get limit => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  List<RouteHistoryEntry> get routes => throw _privateConstructorUsedError;

  /// Serializes this RouteHistory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RouteHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RouteHistoryCopyWith<RouteHistory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RouteHistoryCopyWith<$Res> {
  factory $RouteHistoryCopyWith(
    RouteHistory value,
    $Res Function(RouteHistory) then,
  ) = _$RouteHistoryCopyWithImpl<$Res, RouteHistory>;
  @useResult
  $Res call({int limit, int page, int total, List<RouteHistoryEntry> routes});
}

/// @nodoc
class _$RouteHistoryCopyWithImpl<$Res, $Val extends RouteHistory>
    implements $RouteHistoryCopyWith<$Res> {
  _$RouteHistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RouteHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? limit = null,
    Object? page = null,
    Object? total = null,
    Object? routes = null,
  }) {
    return _then(
      _value.copyWith(
            limit: null == limit
                ? _value.limit
                : limit // ignore: cast_nullable_to_non_nullable
                      as int,
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
            routes: null == routes
                ? _value.routes
                : routes // ignore: cast_nullable_to_non_nullable
                      as List<RouteHistoryEntry>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RouteHistoryImplCopyWith<$Res>
    implements $RouteHistoryCopyWith<$Res> {
  factory _$$RouteHistoryImplCopyWith(
    _$RouteHistoryImpl value,
    $Res Function(_$RouteHistoryImpl) then,
  ) = __$$RouteHistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int limit, int page, int total, List<RouteHistoryEntry> routes});
}

/// @nodoc
class __$$RouteHistoryImplCopyWithImpl<$Res>
    extends _$RouteHistoryCopyWithImpl<$Res, _$RouteHistoryImpl>
    implements _$$RouteHistoryImplCopyWith<$Res> {
  __$$RouteHistoryImplCopyWithImpl(
    _$RouteHistoryImpl _value,
    $Res Function(_$RouteHistoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RouteHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? limit = null,
    Object? page = null,
    Object? total = null,
    Object? routes = null,
  }) {
    return _then(
      _$RouteHistoryImpl(
        limit: null == limit
            ? _value.limit
            : limit // ignore: cast_nullable_to_non_nullable
                  as int,
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
        routes: null == routes
            ? _value._routes
            : routes // ignore: cast_nullable_to_non_nullable
                  as List<RouteHistoryEntry>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RouteHistoryImpl implements _RouteHistory {
  const _$RouteHistoryImpl({
    this.limit = 20,
    this.page = 1,
    this.total = 0,
    final List<RouteHistoryEntry> routes = const <RouteHistoryEntry>[],
  }) : _routes = routes;

  factory _$RouteHistoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$RouteHistoryImplFromJson(json);

  @override
  @JsonKey()
  final int limit;
  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int total;
  final List<RouteHistoryEntry> _routes;
  @override
  @JsonKey()
  List<RouteHistoryEntry> get routes {
    if (_routes is EqualUnmodifiableListView) return _routes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_routes);
  }

  @override
  String toString() {
    return 'RouteHistory(limit: $limit, page: $page, total: $total, routes: $routes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RouteHistoryImpl &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.total, total) || other.total == total) &&
            const DeepCollectionEquality().equals(other._routes, _routes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    limit,
    page,
    total,
    const DeepCollectionEquality().hash(_routes),
  );

  /// Create a copy of RouteHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RouteHistoryImplCopyWith<_$RouteHistoryImpl> get copyWith =>
      __$$RouteHistoryImplCopyWithImpl<_$RouteHistoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RouteHistoryImplToJson(this);
  }
}

abstract class _RouteHistory implements RouteHistory {
  const factory _RouteHistory({
    final int limit,
    final int page,
    final int total,
    final List<RouteHistoryEntry> routes,
  }) = _$RouteHistoryImpl;

  factory _RouteHistory.fromJson(Map<String, dynamic> json) =
      _$RouteHistoryImpl.fromJson;

  @override
  int get limit;
  @override
  int get page;
  @override
  int get total;
  @override
  List<RouteHistoryEntry> get routes;

  /// Create a copy of RouteHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RouteHistoryImplCopyWith<_$RouteHistoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

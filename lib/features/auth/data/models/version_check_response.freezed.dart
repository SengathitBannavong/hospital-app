// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'version_check_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VersionCheckResponse _$VersionCheckResponseFromJson(Map<String, dynamic> json) {
  return _VersionCheckResponse.fromJson(json);
}

/// @nodoc
mixin _$VersionCheckResponse {
  @JsonKey(name: 'minimum_version')
  String? get minimumVersion => throw _privateConstructorUsedError;
  @JsonKey(name: 'latest_version')
  String? get latestVersion => throw _privateConstructorUsedError;
  @JsonKey(name: 'update_type')
  String? get updateType => throw _privateConstructorUsedError;
  @JsonKey(name: 'message')
  String? get message => throw _privateConstructorUsedError;
  @JsonKey(name: 'download_url')
  String? get downloadUrl => throw _privateConstructorUsedError;

  /// Serializes this VersionCheckResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VersionCheckResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VersionCheckResponseCopyWith<VersionCheckResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VersionCheckResponseCopyWith<$Res> {
  factory $VersionCheckResponseCopyWith(
    VersionCheckResponse value,
    $Res Function(VersionCheckResponse) then,
  ) = _$VersionCheckResponseCopyWithImpl<$Res, VersionCheckResponse>;
  @useResult
  $Res call({
    @JsonKey(name: 'minimum_version') String? minimumVersion,
    @JsonKey(name: 'latest_version') String? latestVersion,
    @JsonKey(name: 'update_type') String? updateType,
    @JsonKey(name: 'message') String? message,
    @JsonKey(name: 'download_url') String? downloadUrl,
  });
}

/// @nodoc
class _$VersionCheckResponseCopyWithImpl<
  $Res,
  $Val extends VersionCheckResponse
>
    implements $VersionCheckResponseCopyWith<$Res> {
  _$VersionCheckResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VersionCheckResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? minimumVersion = freezed,
    Object? latestVersion = freezed,
    Object? updateType = freezed,
    Object? message = freezed,
    Object? downloadUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            minimumVersion: freezed == minimumVersion
                ? _value.minimumVersion
                : minimumVersion // ignore: cast_nullable_to_non_nullable
                      as String?,
            latestVersion: freezed == latestVersion
                ? _value.latestVersion
                : latestVersion // ignore: cast_nullable_to_non_nullable
                      as String?,
            updateType: freezed == updateType
                ? _value.updateType
                : updateType // ignore: cast_nullable_to_non_nullable
                      as String?,
            message: freezed == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String?,
            downloadUrl: freezed == downloadUrl
                ? _value.downloadUrl
                : downloadUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VersionCheckResponseImplCopyWith<$Res>
    implements $VersionCheckResponseCopyWith<$Res> {
  factory _$$VersionCheckResponseImplCopyWith(
    _$VersionCheckResponseImpl value,
    $Res Function(_$VersionCheckResponseImpl) then,
  ) = __$$VersionCheckResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'minimum_version') String? minimumVersion,
    @JsonKey(name: 'latest_version') String? latestVersion,
    @JsonKey(name: 'update_type') String? updateType,
    @JsonKey(name: 'message') String? message,
    @JsonKey(name: 'download_url') String? downloadUrl,
  });
}

/// @nodoc
class __$$VersionCheckResponseImplCopyWithImpl<$Res>
    extends _$VersionCheckResponseCopyWithImpl<$Res, _$VersionCheckResponseImpl>
    implements _$$VersionCheckResponseImplCopyWith<$Res> {
  __$$VersionCheckResponseImplCopyWithImpl(
    _$VersionCheckResponseImpl _value,
    $Res Function(_$VersionCheckResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VersionCheckResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? minimumVersion = freezed,
    Object? latestVersion = freezed,
    Object? updateType = freezed,
    Object? message = freezed,
    Object? downloadUrl = freezed,
  }) {
    return _then(
      _$VersionCheckResponseImpl(
        minimumVersion: freezed == minimumVersion
            ? _value.minimumVersion
            : minimumVersion // ignore: cast_nullable_to_non_nullable
                  as String?,
        latestVersion: freezed == latestVersion
            ? _value.latestVersion
            : latestVersion // ignore: cast_nullable_to_non_nullable
                  as String?,
        updateType: freezed == updateType
            ? _value.updateType
            : updateType // ignore: cast_nullable_to_non_nullable
                  as String?,
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
        downloadUrl: freezed == downloadUrl
            ? _value.downloadUrl
            : downloadUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VersionCheckResponseImpl implements _VersionCheckResponse {
  const _$VersionCheckResponseImpl({
    @JsonKey(name: 'minimum_version') this.minimumVersion,
    @JsonKey(name: 'latest_version') this.latestVersion,
    @JsonKey(name: 'update_type') this.updateType,
    @JsonKey(name: 'message') this.message,
    @JsonKey(name: 'download_url') this.downloadUrl,
  });

  factory _$VersionCheckResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$VersionCheckResponseImplFromJson(json);

  @override
  @JsonKey(name: 'minimum_version')
  final String? minimumVersion;
  @override
  @JsonKey(name: 'latest_version')
  final String? latestVersion;
  @override
  @JsonKey(name: 'update_type')
  final String? updateType;
  @override
  @JsonKey(name: 'message')
  final String? message;
  @override
  @JsonKey(name: 'download_url')
  final String? downloadUrl;

  @override
  String toString() {
    return 'VersionCheckResponse(minimumVersion: $minimumVersion, latestVersion: $latestVersion, updateType: $updateType, message: $message, downloadUrl: $downloadUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VersionCheckResponseImpl &&
            (identical(other.minimumVersion, minimumVersion) ||
                other.minimumVersion == minimumVersion) &&
            (identical(other.latestVersion, latestVersion) ||
                other.latestVersion == latestVersion) &&
            (identical(other.updateType, updateType) ||
                other.updateType == updateType) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.downloadUrl, downloadUrl) ||
                other.downloadUrl == downloadUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    minimumVersion,
    latestVersion,
    updateType,
    message,
    downloadUrl,
  );

  /// Create a copy of VersionCheckResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VersionCheckResponseImplCopyWith<_$VersionCheckResponseImpl>
  get copyWith =>
      __$$VersionCheckResponseImplCopyWithImpl<_$VersionCheckResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$VersionCheckResponseImplToJson(this);
  }
}

abstract class _VersionCheckResponse implements VersionCheckResponse {
  const factory _VersionCheckResponse({
    @JsonKey(name: 'minimum_version') final String? minimumVersion,
    @JsonKey(name: 'latest_version') final String? latestVersion,
    @JsonKey(name: 'update_type') final String? updateType,
    @JsonKey(name: 'message') final String? message,
    @JsonKey(name: 'download_url') final String? downloadUrl,
  }) = _$VersionCheckResponseImpl;

  factory _VersionCheckResponse.fromJson(Map<String, dynamic> json) =
      _$VersionCheckResponseImpl.fromJson;

  @override
  @JsonKey(name: 'minimum_version')
  String? get minimumVersion;
  @override
  @JsonKey(name: 'latest_version')
  String? get latestVersion;
  @override
  @JsonKey(name: 'update_type')
  String? get updateType;
  @override
  @JsonKey(name: 'message')
  String? get message;
  @override
  @JsonKey(name: 'download_url')
  String? get downloadUrl;

  /// Create a copy of VersionCheckResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VersionCheckResponseImplCopyWith<_$VersionCheckResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'version_check_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VersionCheckResponseImpl _$$VersionCheckResponseImplFromJson(
  Map<String, dynamic> json,
) => _$VersionCheckResponseImpl(
  minimumVersion: json['minimum_version'] as String?,
  latestVersion: json['latest_version'] as String?,
  updateType: json['update_type'] as String?,
  message: json['message'] as String?,
  downloadUrl: json['download_url'] as String?,
);

Map<String, dynamic> _$$VersionCheckResponseImplToJson(
  _$VersionCheckResponseImpl instance,
) => <String, dynamic>{
  'minimum_version': instance.minimumVersion,
  'latest_version': instance.latestVersion,
  'update_type': instance.updateType,
  'message': instance.message,
  'download_url': instance.downloadUrl,
};

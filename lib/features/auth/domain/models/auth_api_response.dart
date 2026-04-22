import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_api_response.freezed.dart';
part 'auth_api_response.g.dart';

@Freezed(genericArgumentFactories: true)
class AuthApiResponse<T> with _$AuthApiResponse<T> {
  const factory AuthApiResponse({
    required int code,
    required String message,
    T? data,
  }) = _AuthApiResponse;

  factory AuthApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$AuthApiResponseFromJson(json, fromJsonT);
}

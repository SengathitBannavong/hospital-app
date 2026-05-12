import 'package:freezed_annotation/freezed_annotation.dart';

part 'medical_api_response.freezed.dart';
part 'medical_api_response.g.dart';

@Freezed(genericArgumentFactories: true)
class MedicalApiResponse<T> with _$MedicalApiResponse<T> {
  const factory MedicalApiResponse({
    required int code,
    required String message,
    T? data,
  }) = _MedicalApiResponse;

  factory MedicalApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$MedicalApiResponseFromJson(json, fromJsonT);
}

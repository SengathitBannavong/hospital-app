// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'otp_response.freezed.dart';
part 'otp_response.g.dart';

@freezed
class OtpResponse with _$OtpResponse {
  const factory OtpResponse({
    @JsonKey(name: 'user_id') int? userId,
    @JsonKey(name: 'otp_code') String? otpCode,
  }) = _OtpResponse;

  factory OtpResponse.fromJson(Map<String, dynamic> json) =>
      _$OtpResponseFromJson(json);
}

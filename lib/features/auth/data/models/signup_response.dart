// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'signup_response.freezed.dart';
part 'signup_response.g.dart';

@freezed
class SignupResponse with _$SignupResponse {
  const factory SignupResponse({
    @JsonKey(name: 'user_id') required int userId,
    @JsonKey(name: 'otp_code') required String otpCode,
  }) = _SignupResponse;

  factory SignupResponse.fromJson(Map<String, dynamic> json) =>
      _$SignupResponseFromJson(json);
}

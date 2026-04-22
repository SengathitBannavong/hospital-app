// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'otp_verification_request.freezed.dart';
part 'otp_verification_request.g.dart';

@freezed
class OtpVerificationRequest with _$OtpVerificationRequest {
  const factory OtpVerificationRequest({
    @JsonKey(name: 'phone_number') required String phoneNumber,
    required String otp,
    @JsonKey(name: 'otp_type') required String otpType, // 'login', 'signup', 'forgot_password'
  }) = _OtpVerificationRequest;

  factory OtpVerificationRequest.fromJson(Map<String, dynamic> json) =>
      _$OtpVerificationRequestFromJson(json);
}

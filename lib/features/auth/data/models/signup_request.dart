// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'signup_request.freezed.dart';
part 'signup_request.g.dart';

@freezed
class SignupRequest with _$SignupRequest {
  const factory SignupRequest({
    @JsonKey(name: 'phone_number') required String phoneNumber,
    required String password,
    @JsonKey(name: 'full_name') required String fullName,
    required String dob, // yyyy-MM-dd format
    required int gender, // 0 = male, 1 = female, etc.
  }) = _SignupRequest;

  factory SignupRequest.fromJson(Map<String, dynamic> json) =>
      _$SignupRequestFromJson(json);
}

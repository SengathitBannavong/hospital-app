// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';
part 'auth_user.g.dart';

@freezed
class AuthUser with _$AuthUser {
  const factory AuthUser({
    @JsonKey(name: 'user_id') required int userId,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'phone_number') required String phoneNumber,
    required String token,
    String? avatar,
    int? active,
    String? role,
  }) = _AuthUser;

  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      _$AuthUserFromJson(json);
}

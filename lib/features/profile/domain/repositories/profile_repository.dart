import '../models/user_profile.dart';

abstract class IProfileRepository {
  Future<UserProfile> getProfile();
  Future<UserProfile> updateProfile({
    String? fullName,
    String? dob,
    int? gender,
    String? avatarPath,
  });
}

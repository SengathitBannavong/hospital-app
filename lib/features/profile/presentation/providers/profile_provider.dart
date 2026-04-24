import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/profile_repository.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  return ProfileRepository();
});

final profileProvider =
    StateNotifierProvider.autoDispose<ProfileNotifier, AsyncValue<UserProfile>>(
      (ref) {
        final repository = ref.watch(profileRepositoryProvider);
        return ProfileNotifier(repository)..fetchProfile();
      },
    );

class ProfileNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  final IProfileRepository _repository;

  ProfileNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> fetchProfile() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getProfile());
  }

  Future<void> updateProfile({
    String? fullName,
    String? dob,
    int? gender,
    String? avatarPath,
  }) async {
    state = await AsyncValue.guard(() async {
      final updatedProfile = await _repository.updateProfile(
        fullName: fullName,
        dob: dob,
        gender: gender,
        avatarPath: avatarPath,
      );
      return updatedProfile;
    });

    // If update fails, we might want to revert or just show error
    // (guarded state handles error)
  }
}

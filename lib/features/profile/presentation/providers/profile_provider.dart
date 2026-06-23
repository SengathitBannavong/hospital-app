import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/profile_update_request.dart';
import '../../data/repositories/profile_repository.dart';
import 'profile_state.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

final profileProvider =
    StateNotifierProvider.autoDispose<ProfileNotifier, ProfileState>((ref) {
      final repository = ref.watch(profileRepositoryProvider);
      final notifier = ProfileNotifier(repository);
      notifier.fetchProfile().catchError((_) {});
      return notifier;
    });

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;

  ProfileNotifier(this._repository) : super(ProfileState.initial());

  Future<void> fetchProfile({bool isRefresh = false}) async {
    state = state.copyWith(
      isLoading: !isRefresh && !state.hasProfile,
      isRefreshing: isRefresh || state.hasProfile,
      isSaving: false,
      errorMessage: null,
    );

    try {
      final profile = await _repository.getProfile();
      state = state.copyWith(
        profile: profile,
        isLoading: false,
        isRefreshing: false,
        isSaving: false,
        errorMessage: null,
        isStale: false,
      );
    } catch (error) {
      // Live fetch failed (e.g. offline). Fall back to the cached profile so
      // the page still renders, flagged stale to surface the offline status.
      final cached = state.profile ?? await _repository.getCachedProfile();
      if (cached != null) {
        state = state.copyWith(
          profile: cached,
          isLoading: false,
          isRefreshing: false,
          isSaving: false,
          errorMessage: _formatError(error),
          isStale: true,
        );
        return;
      }
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        isSaving: false,
        errorMessage: _formatError(error),
        isStale: false,
      );
      rethrow;
    }
  }

  Future<bool> updateProfile(ProfileUpdateRequest request) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final updatedProfile = await _repository.updateProfile(request);
      state = state.copyWith(
        profile: updatedProfile,
        isLoading: false,
        isRefreshing: false,
        isSaving: false,
        errorMessage: null,
        isStale: false,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        isSaving: false,
        errorMessage: _formatError(error),
      );
      return false;
    }
  }

  String _formatError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}

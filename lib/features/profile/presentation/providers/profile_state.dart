import '../../data/models/user_profile.dart';

class ProfileState {
  const ProfileState({
    required this.profile,
    required this.isLoading,
    required this.isRefreshing,
    required this.isSaving,
    required this.errorMessage,
    this.isStale = false,
  });

  factory ProfileState.initial() {
    return const ProfileState(
      profile: null,
      isLoading: true,
      isRefreshing: false,
      isSaving: false,
      errorMessage: null,
    );
  }

  final UserProfile? profile;
  final bool isLoading;
  final bool isRefreshing;
  final bool isSaving;
  final String? errorMessage;

  /// True when the displayed profile came from the offline cache because the
  /// live fetch failed. Drives the offline indicator in the header.
  final bool isStale;

  bool get hasProfile => profile != null;
  bool get isBusy => isLoading || isRefreshing || isSaving;

  ProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    bool? isRefreshing,
    bool? isSaving,
    String? errorMessage,
    bool? isStale,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      isStale: isStale ?? this.isStale,
    );
  }
}

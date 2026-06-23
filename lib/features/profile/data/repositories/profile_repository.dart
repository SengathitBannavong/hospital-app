import '../datasources/profile_local_data_source.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/profile_update_request.dart';
import '../models/user_profile.dart';

class ProfileRepository {
  ProfileRepository({
    ProfileRemoteDataSource? remoteDataSource,
    ProfileLocalDataSource? localDataSource,
  }) : _remoteDataSource = remoteDataSource ?? ProfileRemoteDataSource(),
       _localDataSource = localDataSource ?? ProfileLocalDataSource();

  final ProfileRemoteDataSource _remoteDataSource;
  final ProfileLocalDataSource _localDataSource;

  Future<UserProfile> getProfile() async {
    final profile = await _remoteDataSource.getProfile();
    // Persist the fresh profile so it can be shown while offline.
    await _localDataSource.saveProfile(profile);
    return profile;
  }

  Future<UserProfile> updateProfile(ProfileUpdateRequest request) async {
    final profile = await _remoteDataSource.updateProfile(request);
    await _localDataSource.saveProfile(profile);
    return profile;
  }

  /// Returns the last successfully cached profile, or null if none was stored.
  Future<UserProfile?> getCachedProfile() {
    return _localDataSource.loadProfile();
  }
}

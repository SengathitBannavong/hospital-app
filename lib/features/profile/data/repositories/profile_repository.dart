import '../datasources/profile_remote_data_source.dart';
import '../models/profile_update_request.dart';
import '../models/user_profile.dart';

class ProfileRepository {
  ProfileRepository({ProfileRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? ProfileRemoteDataSource();

  final ProfileRemoteDataSource _remoteDataSource;

  Future<UserProfile> getProfile() {
    return _remoteDataSource.getProfile();
  }

  Future<UserProfile> updateProfile(ProfileUpdateRequest request) {
    return _remoteDataSource.updateProfile(request);
  }
}

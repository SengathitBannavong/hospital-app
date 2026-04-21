import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/core/network/token_repository.dart';
import '../../data/auth_repository.dart';
import '../../domain/models/auth_user.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthUser?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository)..checkAuthStatus();
});

class AuthNotifier extends StateNotifier<AuthUser?> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(null);

  // Step 1 of multi-step login: verify credentials but don't log in yet
  Future<AuthUser> verifyCredentials(
    String phoneNumber,
    String password,
  ) async {
    return await _repository.login(
      phoneNumber: phoneNumber,
      password: password,
    );
  }

  // To be called after OTP verification success to finalize login
  Future<void> login(String phoneNumber, String password) async {
    final user = await _repository.login(
      phoneNumber: phoneNumber,
      password: password,
    );
    await saveTokenAndSetUser(user);
  }

  // To be called when we already have the AuthUser
  // (e.g. from verifyCredentials then OTP)
  Future<void> saveTokenAndSetUser(AuthUser user) async {
    await TokenRepository.saveToken(user.token);
    state = user;
  }

  Future<void> logout() async {
    await TokenRepository.deleteToken();
    state = null;
  }

  // To be called on app start
  Future<void> checkAuthStatus() async {
    final token = await TokenRepository.getToken();
    if (token != null) {
      // Create a minimal user object since we have the token
      // In a real app, you'd fetch the full profile here
      state = AuthUser(
        userId: 0,
        fullName: 'User',
        phoneNumber: '',
        token: token,
      );
    } else {
      state = null;
    }
  }

  // For OTP verification success that leads to login
  void setUser(AuthUser user) {
    state = user;
  }
}

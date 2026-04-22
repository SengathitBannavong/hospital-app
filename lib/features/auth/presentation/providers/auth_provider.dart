import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/core/network/token_repository.dart';
import 'package:hospital_app/features/auth/domain/models/otp_response.dart';
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

  // Signup with phone, password, fullName, dob, and gender
  // Returns OtpResponse containing userId and otpCode
  Future<OtpResponse> signup({
    required String phoneNumber,
    required String password,
    required String fullName,
    required String dob,
    required int gender,
  }) async {
    return await _repository.signup(
      phoneNumber: phoneNumber,
      password: password,
      fullName: fullName,
      dob: dob,
      gender: gender,
    );
  }

  // Verify OTP for signup, forgot_password, or login flows
  Future<void> verifyOtp({
    required String phoneNumber,
    required String otp,
    String? otpType,
  }) async {
    return await _repository.verifyOtp(
      phoneNumber: phoneNumber,
      otp: otp,
      otpType: otpType,
    );
  }

  // Request OTP for password recovery
  Future<OtpResponse> forgotPassword(String phoneNumber) async {
    return await _repository.forgotPassword(phoneNumber);
  }

  // Reset password with OTP
  Future<void> resetPassword({
    required String phoneNumber,
    required String otp,
    required String newPassword,
  }) async {
    return await _repository.resetPassword(
      phoneNumber: phoneNumber,
      otp: otp,
      newPassword: newPassword,
    );
  }

  // Change password (requires authentication)
  // On 401 (token invalid), will be caught by interceptor and trigger logout
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    return await _repository.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }
}

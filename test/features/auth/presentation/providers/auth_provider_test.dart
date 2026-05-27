import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/features/auth/data/auth_repository.dart';
import 'package:hospital_app/features/auth/data/models/auth_user.dart';
import 'package:hospital_app/features/auth/data/models/otp_response.dart';
import 'package:hospital_app/features/auth/presentation/providers/auth_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock flutter_secure_storage method channel for token deletion
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (call) async => null,
        );
  });
  group('AuthNotifier methods', () {
    test('verifyCredentials returns AuthUser', () async {
      final mockRepo = MockAuthRepository();
      final notifier = AuthNotifier(mockRepo);

      final result = await notifier.verifyCredentials(
        '0900000001',
        'password123',
      );

      expect(result.userId, 1);
      expect(result.fullName, 'Test User');
    });

    test('signup returns OtpResponse with userId', () async {
      final mockRepo = MockAuthRepository();
      final notifier = AuthNotifier(mockRepo);

      final result = await notifier.signup(
        phoneNumber: '0900000001',
        password: 'password123',
        fullName: 'Test User',
        dob: '2000-01-01',
        gender: 0,
      );

      expect(result.userId, isNotNull);
      expect(result.otpCode, isNotNull);
    });

    test('verifyOtp completes successfully', () async {
      final mockRepo = MockAuthRepository();
      final notifier = AuthNotifier(mockRepo);

      await notifier.verifyOtp(
        phoneNumber: '0900000001',
        otp: '123456',
        otpType: 'signup',
      );

      // No exception should be thrown
    });

    test('forgotPassword returns OtpResponse', () async {
      final mockRepo = MockAuthRepository();
      final notifier = AuthNotifier(mockRepo);

      final result = await notifier.forgotPassword('0900000001');

      expect(result.userId, isNotNull);
    });

    test('resetPassword completes successfully', () async {
      final mockRepo = MockAuthRepository();
      final notifier = AuthNotifier(mockRepo);

      await notifier.resetPassword(
        phoneNumber: '0900000001',
        otp: '123456',
        newPassword: 'newpass123',
      );

      // No exception should be thrown
    });

    test('changePassword completes successfully', () async {
      final mockRepo = MockAuthRepository();
      final notifier = AuthNotifier(mockRepo);

      await notifier.changePassword(
        oldPassword: 'oldpass123',
        newPassword: 'newpass123',
      );

      // No exception should be thrown
    });

    test('deleteAccount calls repository and clears state', () async {
      final mockRepo = MockAuthRepositoryWithTracking();
      final notifier = AuthNotifier(mockRepo);

      // Set initial state
      final testUser = const AuthUser(
        userId: 1,
        fullName: 'Test User',
        phoneNumber: '0900000001',
        token: 'test_token',
      );
      notifier.setUser(testUser);
      expect(notifier.state, testUser);

      // Execute deleteAccount - should not throw
      await notifier.deleteAccount(password: 'password123');

      // Verify repository deleteAccount was called with correct password
      expect(mockRepo.deleteAccountCalled, true);
      expect(mockRepo.lastDeletePassword, 'password123');

      // Verify state is cleared after logout
      expect(notifier.state, isNull);
    });

    test('resendOtp completes successfully', () async {
      final mockRepo = MockAuthRepository();
      final notifier = AuthNotifier(mockRepo);

      await notifier.resendOtp(phoneNumber: '0900000001', otpType: 'signup');

      // No exception should be thrown
    });

    test('setUser sets the state', () {
      final mockRepo = MockAuthRepository();
      final notifier = AuthNotifier(mockRepo);

      final user = const AuthUser(
        userId: 1,
        fullName: 'Test User',
        phoneNumber: '0900000001',
        token: 'test_token',
      );

      notifier.setUser(user);

      expect(notifier.state, user);
    });
  });
}

class MockAuthRepository implements AuthRepository {
  @override
  Future<AuthUser> login({
    required String phoneNumber,
    required String password,
  }) async {
    return AuthUser(
      userId: 1,
      fullName: 'Test User',
      phoneNumber: phoneNumber,
      token: 'mock_token',
    );
  }

  @override
  Future<OtpResponse> signup({
    required String phoneNumber,
    required String password,
    required String fullName,
    required String dob,
    required int gender,
  }) async {
    return const OtpResponse(userId: 1, otpCode: '123456');
  }

  @override
  Future<void> verifyOtp({
    required String phoneNumber,
    required String otp,
    String? otpType,
  }) async {}

  @override
  Future<OtpResponse> forgotPassword(String phoneNumber) async {
    return const OtpResponse(userId: 1, otpCode: '123456');
  }

  @override
  Future<void> resetPassword({
    required String phoneNumber,
    required String otp,
    required String newPassword,
  }) async {}

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {}

  @override
  Future<void> deleteAccount({required String password}) async {}

  @override
  Future<OtpResponse?> resendOtp({
    required String phoneNumber,
    String? otpType,
  }) async => null;
}

/// Extended mock repository that tracks deleteAccount calls
class MockAuthRepositoryWithTracking extends MockAuthRepository {
  bool deleteAccountCalled = false;
  String? lastDeletePassword;

  @override
  Future<void> deleteAccount({required String password}) async {
    deleteAccountCalled = true;
    lastDeletePassword = password;
  }
}

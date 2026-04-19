import 'package:flutter/material.dart';

import 'package:hospital_app/core/network/token_repository.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/utils/app_toast.dart';
import 'package:hospital_app/features/auth/data/auth_repository.dart';
import 'package:hospital_app/features/auth/data/mock_auth_credentials.dart';
import 'package:hospital_app/features/auth/presentation/pages/register_page.dart';
import 'package:hospital_app/features/home/presentation/pages/home_page.dart';
import 'package:hospital_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:hospital_app/features/auth/presentation/widgets/otp_countdown_button.dart';
import 'package:hospital_app/features/auth/presentation/widgets/otp_pin_input.dart';

class LoginOtpPage extends StatefulWidget {
  const LoginOtpPage({super.key});

  @override
  State<LoginOtpPage> createState() => _LoginOtpPageState();
}

class _LoginOtpPageState extends State<LoginOtpPage>
    with SingleTickerProviderStateMixin {
  static const int _otpLength = 6;
  static const int _otpCooldownSeconds = 60;

  final _authRepository = AuthRepository();
  final _phoneController = TextEditingController(
    text: MockAuthCredentials.phoneNumber,
  );
  final _passwordController = TextEditingController(
    text: MockAuthCredentials.password,
  );
  final _otpController = TextEditingController();

  late final TabController _tabController;

  bool _isSigningIn = false;
  bool _isOtpSent = false;
  bool _isVerifyingOtp = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _signIn() async {
    final phoneNumber = _phoneController.text.trim();
    final password = _passwordController.text;

    if (phoneNumber.isEmpty || password.isEmpty) {
      AppToast.showError('Enter phone number and password.');
      return;
    }

    setState(() {
      _isSigningIn = true;
    });

    try {
      final token = await _authRepository.login(
        phoneNumber: phoneNumber,
        password: password,
      );
      await TokenRepository.saveToken(token);

      if (!mounted) {
        return;
      }

      AppToast.showSuccess('Login successful.');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const HomePage(title: 'Hospital App Home'),
        ),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      AppToast.showError(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
      }
    }
  }

  Future<void> _sendOtp() async {
    final phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      throw Exception('Enter a phone number first.');
    }

    if (phoneNumber != MockAuthCredentials.phoneNumber) {
      throw Exception(
        'Use the mock phone number ${MockAuthCredentials.phoneNumber}.',
      );
    }

    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (!mounted) {
      return;
    }

    setState(() {
      _isOtpSent = true;
    });

    AppToast.showSuccess('OTP sent to $phoneNumber.');
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != _otpLength) {
      AppToast.showError('OTP must be exactly $_otpLength digits.');
      return;
    }

    if (otp != MockAuthCredentials.signupOtp) {
      AppToast.showError('Invalid OTP. Use ${MockAuthCredentials.signupOtp}.');
      return;
    }

    setState(() {
      _isVerifyingOtp = true;
    });

    try {
      await TokenRepository.saveToken(MockAuthCredentials.jwtToken);
      if (!mounted) {
        return;
      }

      AppToast.showSuccess('Login successful.');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const HomePage(title: 'Hospital App Home'),
        ),
        (route) => false,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isVerifyingOtp = false;
        });
      }
    }
  }

  Widget _buildOtpTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        top: AppSpacing.lg,
        bottom: AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: AppRadius.borderXl,
              boxShadow: AppShadows.card,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Đăng nhập bằng OTP',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Nhập số điện thoại, nhận mã OTP và xác thực để tiếp tục.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AuthTextField(
                    controller: _phoneController,
                    hintText: 'Số điện thoại',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  OtpCountdownButton(
                    onSendOtp: _sendOtp,
                    initialCountdown: _otpCooldownSeconds,
                    buttonLabel: _isOtpSent ? 'Gửi lại OTP' : 'Gửi OTP',
                    resendLabel: 'Gửi lại sau',
                  ),
                  if (_isOtpSent) ...[
                    const SizedBox(height: AppSpacing.lg),
                    OtpPinInput(controller: _otpController, length: _otpLength),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: _isVerifyingOtp ? null : _verifyOtp,
                      child: _isVerifyingOtp
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Xác thực OTP'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        top: AppSpacing.lg,
        bottom: AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: AppRadius.borderXl,
              boxShadow: AppShadows.card,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Đăng nhập bằng mật khẩu',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Sử dụng số điện thoại và mật khẩu để vào ứng dụng.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AuthTextField(
                    controller: _phoneController,
                    hintText: 'Số điện thoại',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AuthTextField(
                    controller: _passwordController,
                    hintText: 'Mật khẩu',
                    obscureText: !_isPasswordVisible,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      onPressed: _togglePasswordVisibility,
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      tooltip: _isPasswordVisible
                          ? 'Ẩn mật khẩu'
                          : 'Hiện mật khẩu',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton(
                    onPressed: _isSigningIn ? null : _signIn,
                    child: _isSigningIn
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('Đăng nhập'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.backgroundLight, AppColors.primarySurface],
            ),
          ),
          child: Padding(
            padding: AppSpacing.pageWithTop,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xxl),
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                    borderRadius: AppRadius.borderXl,
                    boxShadow: AppShadows.elevated,
                  ),
                  child: const Icon(
                    Icons.health_and_safety_outlined,
                    size: 72,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Màn hình Đăng nhập',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Đăng nhập bằng OTP hoặc mật khẩu. '
                  'Lưu access token vào local storage sau khi '
                  'đăng nhập thành công.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: AppRadius.borderFull,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: AppRadius.borderFull,
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Theme.of(
                      context,
                    ).colorScheme.onSurface,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'OTP'),
                      Tab(text: 'Mật khẩu'),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildOtpTab(), _buildPasswordTab()],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    );
                  },
                  child: const Text('Tạo tài khoản mới'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

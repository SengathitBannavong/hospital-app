import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/utils/app_toast.dart';
import 'package:hospital_app/core/widgets/fade_slide_transition.dart';
import 'package:hospital_app/features/auth/data/models/auth_user.dart';
import 'package:hospital_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:hospital_app/features/auth/presentation/widgets/otp_pin_input.dart';
import 'package:hospital_app/features/auth/presentation/widgets/otp_countdown_button.dart';

class OtpVerificationPage extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String otpType;
  final AuthUser? pendingUser;
  final String? password;
  final String? otpCode;

  const OtpVerificationPage({
    super.key,
    required this.phoneNumber,
    required this.otpType,
    this.pendingUser,
    this.password,
    this.otpCode,
  });

  @override
  ConsumerState<OtpVerificationPage> createState() =>
      _OtpVerificationPageState();
}

class _OtpVerificationPageState extends ConsumerState<OtpVerificationPage> {
  final _otpController = TextEditingController();
  bool _isVerifying = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      AppToast.showError('Vui lòng nhập đầy đủ mã OTP.');
      return;
    }

    setState(() => _isVerifying = true);

    try {
      // 1. Verify OTP with Backend
      await ref
          .read(authStateProvider.notifier)
          .verifyOtp(
            phoneNumber: widget.phoneNumber,
            otp: otp,
            otpType: widget.otpType,
          );

      if (!mounted) return;

      // 2. Handle different OTP types
      switch (widget.otpType) {
        case 'login':
          // Login flow: Already have pending user
          if (widget.pendingUser != null) {
            await ref
                .read(authStateProvider.notifier)
                .saveTokenAndSetUser(widget.pendingUser!);
          }
          AppToast.showSuccess('Xác thực thành công!');
          if (mounted) context.go('/');
          break;

        case 'signup':
          // Signup flow: Have password, need to auto-login
          if (widget.password != null) {
            await ref
                .read(authStateProvider.notifier)
                .login(widget.phoneNumber, widget.password!);
          }
          AppToast.showSuccess('Đăng nhập thành công!');
          if (mounted) context.go('/');
          break;

        case 'forgot_password':
          // Forgot password flow: Navigate to reset password page
          AppToast.showSuccess('Xác thực thành công!');
          if (mounted) {
            context.push('/reset-password/${widget.phoneNumber}/$otp');
          }
          break;

        default:
          AppToast.showSuccess('Xác thực thành công!');
          if (mounted) context.go('/');
      }
    } catch (error) {
      if (!mounted) return;
      AppToast.showError(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resendOtp() async {
    try {
      await ref
          .read(authRepositoryProvider)
          .resendOtp(phoneNumber: widget.phoneNumber, otpType: widget.otpType);
      AppToast.showSuccess('Đã gửi lại mã OTP.');
    } catch (e) {
      AppToast.showError('Không thể gửi lại mã.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final isSmallScreen = screenHeight < 700;

    // Determine title and description based on otp_type
    final (title, description) = switch (widget.otpType) {
      'login' => ('Xác thực đăng nhập', 'Nhập mã OTP để xác thực đăng nhập'),
      'signup' => ('Xác thực đăng ký', 'Nhập mã OTP để hoàn thành đăng ký'),
      'forgot_password' => (
        'Xác thực lấy lại mật khẩu',
        'Nhập mã OTP để đặt lại mật khẩu',
      ),
      _ => ('Xác thực OTP', 'Nhập mã OTP'),
    };

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: isSmallScreen ? 40 : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: isSmallScreen ? AppSpacing.md : AppSpacing.lg),
              FadeSlideTransition(
                delay: const Duration(milliseconds: 100),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                        isSmallScreen ? AppSpacing.md : AppSpacing.lg,
                      ),
                      decoration: BoxDecoration(
                        color: context.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shield_rounded,
                        size: isSmallScreen ? 48 : 64,
                        color: context.colorScheme.primary,
                      ),
                    ),
                    SizedBox(
                      height: isSmallScreen ? AppSpacing.md : AppSpacing.lg,
                    ),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 20 : null,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                        fontSize: isSmallScreen ? 13 : null,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isSmallScreen ? AppSpacing.xl : AppSpacing.xxl),
              FadeSlideTransition(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Mã được gửi đến ${widget.phoneNumber}',
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                    fontSize: isSmallScreen ? 11 : 15,
                  ),
                ),
              ),
              SizedBox(height: isSmallScreen ? AppSpacing.xl : AppSpacing.xxl),
              FadeSlideTransition(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Mã được gửi là ${widget.otpCode ?? 'NULL'}',
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                    fontSize: isSmallScreen ? 11 : 15,
                  ),
                ),
              ),
              SizedBox(height: isSmallScreen ? AppSpacing.md : AppSpacing.lg),
              FadeSlideTransition(
                delay: const Duration(milliseconds: 300),
                child: Card(
                  elevation: 0,
                  color: context.colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderLg,
                    side: BorderSide(color: context.colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(
                      isSmallScreen ? AppSpacing.lg : AppSpacing.xl,
                    ),
                    child: Column(
                      children: [
                        OtpPinInput(controller: _otpController, length: 6),
                        SizedBox(
                          height: isSmallScreen ? AppSpacing.lg : AppSpacing.xl,
                        ),
                        OtpCountdownButton(
                          onSendOtp: _resendOtp,
                          initialCountdown: 60,
                          buttonLabel: 'Gửi lại mã',
                        ),
                        SizedBox(
                          height: isSmallScreen ? AppSpacing.lg : AppSpacing.xl,
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: isSmallScreen ? 48 : 56,
                          child: FilledButton(
                            onPressed: _isVerifying ? null : _verifyOtp,
                            style: FilledButton.styleFrom(
                              shape: const RoundedRectangleBorder(
                                borderRadius: AppRadius.borderMd,
                              ),
                            ),
                            child: _isVerifying
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Xác nhận',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

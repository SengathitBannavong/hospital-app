import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/utils/app_toast.dart';
import 'package:hospital_app/core/widgets/fade_slide_transition.dart';
import 'package:hospital_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:hospital_app/features/auth/presentation/widgets/otp_pin_input.dart';

class OtpVerificationPage extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String otpType;
  final String? password;
  final String? otpCode;

  const OtpVerificationPage({
    super.key,
    required this.phoneNumber,
    required this.otpType,
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
      switch (widget.otpType) {
        case 'signup':
          await ref
              .read(authStateProvider.notifier)
              .verifyOtp(
                phoneNumber: widget.phoneNumber,
                otp: otp,
                otpType: 'signup',
              );

          if (!mounted) return;

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
          // Do not call verify_otp here. The reset_password endpoint accepts
          // the OTP and may treat a prior verification as consuming it.
          AppToast.showSuccess('Tiếp tục đặt lại mật khẩu.');
          if (mounted) {
            context.push('/reset-password/${widget.phoneNumber}/$otp');
          }
          break;

        default:
          await ref
              .read(authStateProvider.notifier)
              .verifyOtp(
                phoneNumber: widget.phoneNumber,
                otp: otp,
                otpType: widget.otpType,
              );
          if (!mounted) return;
          AppToast.showSuccess('Xác thực thành công!');
          context.go('/');
      }
    } catch (error) {
      if (!mounted) return;
      AppToast.showError(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final isSmallScreen = screenHeight < 700;

    // Determine title and description based on otp_type
    final (title, description) = switch (widget.otpType) {
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
<<<<<<< HEAD
              SizedBox(height: isSmallScreen ? AppSpacing.md : AppSpacing.lg),
              FadeSlideTransition(
                delay: const Duration(milliseconds: 100),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                        isSmallScreen ? AppSpacing.md : AppSpacing.lg,
=======
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Xác thực OTP',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Mã OTP đã được gửi đến số ${widget.phoneNumber}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xxl),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      OtpPinInput(controller: _otpController, length: 6),
                      const SizedBox(height: AppSpacing.xl),
                      TextButton(
                        onPressed: null,
                        child: const Text('Gửi lại mã hiện chưa hỗ trợ'),
>>>>>>> 944e912 (Add SOS screen and home utility shortcuts)
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
              if (widget.otpCode != null) ...[
                FadeSlideTransition(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'Mã được gửi là ${widget.otpCode}',
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                      fontSize: isSmallScreen ? 11 : 15,
                    ),
                  ),
                ),
                SizedBox(height: isSmallScreen ? AppSpacing.md : AppSpacing.lg),
              ],
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
                          enabled: widget.otpType != 'signup',
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

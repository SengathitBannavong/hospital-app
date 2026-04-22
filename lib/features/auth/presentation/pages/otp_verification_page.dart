import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/utils/app_toast.dart';
import 'package:hospital_app/features/auth/domain/models/auth_user.dart';
import 'package:hospital_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:hospital_app/features/auth/presentation/widgets/otp_pin_input.dart';
import 'package:hospital_app/features/auth/presentation/widgets/otp_countdown_button.dart';

class OtpVerificationPage extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String otpType;
  final AuthUser? pendingUser;
  final String? password;

  const OtpVerificationPage({
    super.key,
    required this.phoneNumber,
    required this.otpType,
    this.pendingUser,
    this.password,
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
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      AppToast.showError('Vui lòng nhập đầy đủ mã OTP.');
      return;
    }

    setState(() => _isVerifying = true);

    try {
      // 1. Verify OTP with Backend
      final repository = ref.read(authRepositoryProvider);
      await repository.verifyOtp(
        phoneNumber: widget.phoneNumber,
        otp: otp,
        otpType: widget.otpType,
      );
      // 2. Finalize Login State
      if (widget.pendingUser != null) {
        // If we already have user data (from Login flow Step 1)
        await ref
            .read(authStateProvider.notifier)
            .saveTokenAndSetUser(widget.pendingUser!);
      } else if (widget.password != null) {
        // If we only have password (from Signup flow)
        await ref
            .read(authStateProvider.notifier)
            .login(widget.phoneNumber, widget.password!);
      }

      AppToast.showSuccess('Xác thực thành công!');

      // 3. Flow to Home Page
      if (mounted) context.go('/');
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
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                      OtpCountdownButton(
                        onSendOtp: _resendOtp,
                        initialCountdown: 60,
                        buttonLabel: 'Gửi lại mã',
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isVerifying ? null : _verifyOtp,
                          child: _isVerifying
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
                              : const Text('Xác nhận'),
                        ),
                      ),
                    ],
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

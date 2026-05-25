import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/utils/app_toast.dart';
import 'package:hospital_app/features/auth/data/models/auth_user.dart';
import 'package:hospital_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:hospital_app/features/auth/presentation/widgets/otp_pin_input.dart';

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
      final repository = ref.read(authRepositoryProvider);
      await repository.verifyOtp(
        phoneNumber: widget.phoneNumber,
        otp: otp,
        otpType: widget.otpType,
      );

      if (widget.pendingUser != null) {
        await ref
            .read(authStateProvider.notifier)
            .saveTokenAndSetUser(widget.pendingUser!);
      } else if (widget.password != null) {
        await ref
            .read(authStateProvider.notifier)
            .login(widget.phoneNumber, widget.password!);
      }

      AppToast.showSuccess('Xác thực thành công!');
      if (mounted) context.go('/');
    } catch (error) {
      if (!mounted) return;
      AppToast.showError(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isVerifying = false);
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
                      const TextButton(
                        onPressed: null,
                        child: Text('Gửi lại mã hiện chưa hỗ trợ'),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/utils/app_toast.dart';
import 'package:hospital_app/features/auth/data/models/auth_user.dart';
import 'package:hospital_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:hospital_app/features/auth/presentation/widgets/otp_countdown_button.dart';
import 'package:hospital_app/features/auth/presentation/widgets/otp_pin_input.dart';

class OtpVerificationPage extends ConsumerStatefulWidget {
  const OtpVerificationPage({
    super.key,
    required this.phoneNumber,
    required this.otpType,
    this.pendingUser,
    this.password,
    this.otpCode,
  });

  final String phoneNumber;
  final String otpType;
  final AuthUser? pendingUser;
  final String? password;
  final String? otpCode;

  @override
  ConsumerState<OtpVerificationPage> createState() =>
      _OtpVerificationPageState();
}

class _OtpVerificationPageState extends ConsumerState<OtpVerificationPage> {
  final _otpController = TextEditingController();
  bool _isVerifying = false;
  String? _mockOtpCode;

  @override
  void initState() {
    super.initState();
    _mockOtpCode = widget.otpCode;
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _resendOtp() async {
    final response = await ref
        .read(authRepositoryProvider)
        .resendOtp(phoneNumber: widget.phoneNumber, otpType: widget.otpType);
    if (response?.otpCode != null && mounted) {
      setState(() => _mockOtpCode = response!.otpCode);
    }
    AppToast.showSuccess('Đã gửi lại mã');
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      AppToast.showError('Vui lòng nhập đầy đủ mã OTP.');
      return;
    }

    setState(() => _isVerifying = true);

    try {
      // Forgot-password: don't call verify_otp here — reset_password accepts
      // the OTP and a prior verification may consume it.
      if (widget.otpType == 'forgot_password') {
        AppToast.showSuccess('Tiếp tục đặt lại mật khẩu.');
        if (mounted) {
          context.push('/reset-password/${widget.phoneNumber}/$otp');
        }
        return;
      }

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
      appBar: AppBar(backgroundColor: context.colorScheme.surface),
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
                      if (_mockOtpCode != null) ...[
                        InkWell(
                          onTap: () {
                            _otpController.text = _mockOtpCode!;
                            AppToast.showSuccess('Đã điền mã OTP');
                          },
                          borderRadius: AppRadius.borderMd,
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: context.colorScheme.tertiaryContainer,
                              borderRadius: AppRadius.borderMd,
                              border: Border.all(
                                color: context.colorScheme.tertiary,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.bug_report_outlined,
                                  color: context.colorScheme.tertiary,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Mã OTP (mock)',
                                        style: context.textTheme.labelSmall,
                                      ),
                                      Text(
                                        _mockOtpCode!,
                                        style: context.textTheme.titleLarge
                                            ?.copyWith(
                                              fontFamily: 'monospace',
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 4,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.touch_app_outlined,
                                  color: context.colorScheme.tertiary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      OtpPinInput(controller: _otpController, length: 6),
                      const SizedBox(height: AppSpacing.xl),
                      OtpCountdownButton(
                        onSendOtp: _resendOtp,
                        buttonLabel: 'Gửi lại mã',
                        resendLabel: 'Gửi lại mã',
                        errorMessage: 'Không thể gửi lại mã. Vui lòng thử lại.',
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isVerifying ? null : _verifyOtp,
                          child: _isVerifying
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      context.colorScheme.onPrimary,
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

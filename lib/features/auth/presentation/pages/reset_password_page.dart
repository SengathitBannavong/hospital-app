import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/utils/app_toast.dart';
import 'package:hospital_app/core/widgets/fade_slide_transition.dart';
import 'package:hospital_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:hospital_app/features/auth/presentation/widgets/auth_text_field.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String otp;

  const ResetPasswordPage({
    super.key,
    required this.phoneNumber,
    required this.otp,
  });

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }

  Future<void> _resetPassword() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password.isEmpty || confirmPassword.isEmpty) {
      AppToast.showError('Vui lòng điền tất cả các trường.');
      return;
    }

    if (password.length < 6) {
      AppToast.showError('Mật khẩu phải có ít nhất 6 ký tự.');
      return;
    }

    if (password != confirmPassword) {
      AppToast.showError('Mật khẩu không khớp.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authStateProvider.notifier).resetPassword(
            phoneNumber: widget.phoneNumber,
            otp: widget.otp,
            newPassword: password,
          );

      if (mounted) {
        AppToast.showSuccess('Mật khẩu đã được đặt lại thành công.');
        // Navigate back to login
        context.go('/login');
      }
    } catch (error) {
      if (!mounted) return;
      AppToast.showError(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.pagePadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Section
                FadeSlideTransition(
                  delay: const Duration(milliseconds: 100),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: context.colorScheme.tertiaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.vpn_key_rounded,
                          size: 64,
                          color: context.colorScheme.tertiary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Đặt lại mật khẩu',
                        textAlign: TextAlign.center,
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Tạo mật khẩu mới cho tài khoản của bạn',
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Form Card
                FadeSlideTransition(
                  delay: const Duration(milliseconds: 300),
                  child: Card(
                    elevation: 0,
                    color: context.colorScheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderLg,
                      side: BorderSide(
                        color: context.colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Mật khẩu mới',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          AuthTextField(
                            controller: _passwordController,
                            hintText: 'Mật khẩu mới',
                            obscureText: !_isPasswordVisible,
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              onPressed: _togglePasswordVisibility,
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              tooltip: _isPasswordVisible ? 'Ẩn' : 'Hiện',
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AuthTextField(
                            controller: _confirmPasswordController,
                            hintText: 'Xác nhận mật khẩu',
                            obscureText: !_isConfirmPasswordVisible,
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              onPressed: _toggleConfirmPasswordVisibility,
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                              tooltip: _isConfirmPasswordVisible ? 'Ẩn' : 'Hiện',
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          SizedBox(
                            height: 56,
                            child: FilledButton(
                              onPressed: _isLoading ? null : _resetPassword,
                              style: FilledButton.styleFrom(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: AppRadius.borderMd,
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      'Đặt lại mật khẩu',
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

                const SizedBox(height: AppSpacing.xl),

                // Footer
                FadeSlideTransition(
                  delay: const Duration(milliseconds: 400),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Đã nhớ mật khẩu?',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text(
                          'Đăng nhập',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

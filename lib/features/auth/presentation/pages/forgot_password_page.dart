import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/utils/app_toast.dart';
import 'package:hospital_app/core/widgets/fade_slide_transition.dart';
import 'package:hospital_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:hospital_app/features/auth/presentation/widgets/auth_text_field.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    FocusScope.of(context).unfocus();
    final phoneNumber = _phoneController.text.trim();

    if (phoneNumber.isEmpty) {
      AppToast.showError('Vui lòng nhập số điện thoại.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ref
          .read(authStateProvider.notifier)
          .forgotPassword(phoneNumber);

      if (mounted) {
        // Show OTP code for development (mock API)
        if (response.otpCode != null) {
          AppToast.showSuccess('Mã xác thực đã được gửi.');
          // Navigate to OTP verification page
        }
        context.push('/verify-otp/$phoneNumber/forgot_password');
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
    final screenHeight = MediaQuery.sizeOf(context).height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: isSmallScreen ? 40 : null,
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
                        padding: EdgeInsets.all(
                          isSmallScreen ? AppSpacing.md : AppSpacing.lg,
                        ),
                        decoration: BoxDecoration(
                          color: context.colorScheme.tertiaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_reset_rounded,
                          size: isSmallScreen ? 48 : 64,
                          color: context.colorScheme.tertiary,
                        ),
                      ),
                      SizedBox(
                        height: isSmallScreen ? AppSpacing.md : AppSpacing.lg,
                      ),
                      Text(
                        'Quên mật khẩu?',
                        textAlign: TextAlign.center,
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 20 : null,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Nhập số điện thoại để nhận mã xác thực',
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                          fontSize: isSmallScreen ? 13 : null,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: isSmallScreen ? AppSpacing.lg : AppSpacing.xxl,
                ),

                // Form Card
                FadeSlideTransition(
                  delay: const Duration(milliseconds: 300),
                  child: Card(
                    elevation: 0,
                    color: context.colorScheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderLg,
                      side: BorderSide(
                        color: context.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(
                        isSmallScreen ? AppSpacing.lg : AppSpacing.xl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Xác minh tài khoản',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: isSmallScreen
                                ? AppSpacing.lg
                                : AppSpacing.xl,
                          ),
                          AuthTextField(
                            controller: _phoneController,
                            hintText: 'Số điện thoại',
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icons.phone_outlined,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            maxLength: 11,
                          ),
                          SizedBox(
                            height: isSmallScreen
                                ? AppSpacing.md
                                : AppSpacing.lg,
                          ),
                          SizedBox(
                            height: isSmallScreen ? 48 : 56,
                            child: FilledButton(
                              onPressed: _isLoading ? null : _requestOtp,
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
                                      'Gửi mã xác thực',
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

                SizedBox(height: isSmallScreen ? AppSpacing.lg : AppSpacing.xl),

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
                          fontSize: isSmallScreen ? 13 : null,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: Text(
                          'Đăng nhập',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 13 : null,
                          ),
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

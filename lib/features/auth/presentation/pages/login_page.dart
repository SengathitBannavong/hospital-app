import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_app/core/l10n/locale_controller.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/utils/app_toast.dart';
import 'package:hospital_app/core/widgets/fade_slide_transition.dart';
import 'package:hospital_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:hospital_app/features/auth/presentation/widgets/auth_link_button_style.dart';
import 'package:hospital_app/features/auth/presentation/widgets/auth_text_field.dart';

class LoginOtpPage extends ConsumerStatefulWidget {
  const LoginOtpPage({super.key});

  @override
  ConsumerState<LoginOtpPage> createState() => _LoginOtpPageState();
}

class _LoginOtpPageState extends ConsumerState<LoginOtpPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _signIn() async {
    FocusScope.of(context).unfocus();
    final phoneNumber = _phoneController.text.trim();
    final password = _passwordController.text;

    if (phoneNumber.isEmpty || password.isEmpty) {
      AppToast.showError(context.l10n.loginErrorEmptyFields);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authStateProvider.notifier).login(phoneNumber, password);

      if (mounted) {
        // Login is a single-step flow on the current backend.
        AppToast.showSuccess(context.l10n.loginSuccess);
        context.go('/');
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.pagePadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Section - Grouped tightly
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
                          Icons.health_and_safety_rounded,
                          size: isSmallScreen ? 48 : 64,
                          color: context.colorScheme.primary,
                        ),
                      ),
                      SizedBox(
                        height: isSmallScreen ? AppSpacing.md : AppSpacing.lg,
                      ),
                      Text(
                        context.l10n.loginWelcomeBack,
                        textAlign: TextAlign.center,
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 20 : null,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        context.l10n.loginSubtitle,
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

                // Login Form Card
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
                            context.l10n.loginCredentials,
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
                            hintText: context.l10n.authPhone,
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icons.phone_outlined,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            maxLength: 11,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AuthTextField(
                            controller: _passwordController,
                            hintText: context.l10n.authPassword,
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
                                  ? context.l10n.authHide
                                  : context.l10n.authShow,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => context.push('/forgot-password'),
                              style: authLinkButtonStyle(
                                context,
                                compact: true,
                              ),
                              child: Text(context.l10n.loginForgotPassword),
                            ),
                          ),
                          SizedBox(
                            height: isSmallScreen
                                ? AppSpacing.md
                                : AppSpacing.lg,
                          ),
                          SizedBox(
                            height: isSmallScreen ? 48 : 56,
                            child: FilledButton(
                              onPressed: _isLoading ? null : _signIn,
                              style: FilledButton.styleFrom(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: AppRadius.borderMd,
                                ),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              context.colorScheme.onPrimary,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      context.l10n.commonContinue,
                                      style: const TextStyle(
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

                // Footer Section
                FadeSlideTransition(
                  delay: const Duration(milliseconds: 400),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.l10n.loginNoAccount,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                          fontSize: isSmallScreen ? 13 : null,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/register'),
                        style: authLinkButtonStyle(
                          context,
                          fontSize: isSmallScreen ? 13 : null,
                          fontWeight: FontWeight.bold,
                        ),
                        child: Text(context.l10n.loginRegisterNow),
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

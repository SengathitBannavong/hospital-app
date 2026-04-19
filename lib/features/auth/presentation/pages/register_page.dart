import 'package:flutter/material.dart';

import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/utils/app_toast.dart';
import 'package:hospital_app/features/auth/data/mock_auth_credentials.dart';
import 'package:hospital_app/features/auth/presentation/widgets/auth_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    AppToast.showWarning('Registration is a demo screen for now.');
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.pageWithTop,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xxl),
                Icon(
                  Icons.person_add_alt_1_rounded,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Create account',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Use the signup OTP from the mock API '
                  'when creating an account.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xxl),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        AuthTextField(
                          controller: _nameController,
                          hintText: 'Full name',
                          prefixIcon: Icons.person_outline,
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? 'Enter your name'
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AuthTextField(
                          controller: _phoneController,
                          hintText: 'Phone number',
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_outlined,
                          validator: (value) =>
                              (value == null || value.trim().length < 8)
                              ? 'Enter a valid phone number'
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AuthTextField(
                          controller: _passwordController,
                          hintText: 'Password',
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
                                ? 'Hide password'
                                : 'Show password',
                          ),
                          validator: (value) =>
                              (value == null || value.trim().length < 8)
                              ? 'Password must be at least 8 characters'
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _submit,
                            child: const Text('Create account'),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Back to login'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mock OTP hints',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const Text(
                          'Signup OTP: ${MockAuthCredentials.signupOtp}',
                        ),
                        const Text(
                          'Forgot password OTP: '
                          '${MockAuthCredentials.forgotPasswordOtp}',
                        ),
                      ],
                    ),
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

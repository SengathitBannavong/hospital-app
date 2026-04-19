import 'package:flutter/material.dart';

import 'package:hospital_app/core/network/token_repository.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/utils/app_toast.dart';
import 'package:hospital_app/features/auth/presentation/pages/login_otp_page.dart';
import 'package:hospital_app/features/home/presentation/pages/home_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  Future<void> _logout(BuildContext context) async {
    await TokenRepository.deleteToken();
    if (!context.mounted) {
      return;
    }

    AppToast.showSuccess('Logged out successfully.');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginOtpPage()),
      (route) => false,
    );
  }

  void _continueToHome(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const HomePage(title: 'Hospital App Home'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.pageWithTop,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: AppRadius.borderXl,
                ),
                child: Icon(
                  Icons.verified_user_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Welcome back',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Your OTP session is stored securely. Continue to the app '
                'or sign out when you are done.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xxl),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => _continueToHome(context),
                          child: const Text('Continue to app'),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => _logout(context),
                          child: const Text('Logout'),
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

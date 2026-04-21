import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/core/utils/app_toast.dart';
import 'package:hospital_app/features/auth/domain/models/auth_user.dart';
import 'package:hospital_app/features/auth/presentation/pages/login_otp_page.dart';
import 'package:hospital_app/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:hospital_app/features/auth/presentation/pages/register_page.dart';
import 'package:hospital_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:hospital_app/features/home/presentation/pages/home_page.dart';
import 'package:hospital_app/features/auth/presentation/widgets/auth_text_field.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      AppToast.showError('Vui lòng nhập số điện thoại');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).forgotPassword(phone);
      if (mounted) {
        AppToast.showSuccess('Mã OTP đã được gửi.');
        context.push('/verify-otp/$phone/forgot_password');
      }
    } catch (e) {
      if (mounted) AppToast.showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Quên mật khẩu', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.md),
            const Text('Nhập số điện thoại để nhận mã khôi phục.'),
            const SizedBox(height: AppSpacing.xl),
            AuthTextField(
              controller: _phoneController,
              hintText: 'Số điện thoại',
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                : const Text('Gửi mã'),
            ),
          ],
        ),
      ),
    );
  }
}

// RouterNotifier to handle reactive redirection
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthUser?>(
      authStateProvider,
      (_, __) => notifyListeners(),
    );
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authUser = _ref.read(authStateProvider);
    final isLoggedIn = authUser != null;
    
    final isLoggingIn = state.matchedLocation == '/login' || 
                        state.matchedLocation == '/register' ||
                        state.matchedLocation == '/forgot-password' ||
                        state.matchedLocation.startsWith('/verify-otp');

    if (!isLoggedIn) {
      return isLoggingIn ? null : '/login';
    }

    // If logged in, don't allow access to auth pages
    if (isLoggedIn && isLoggingIn) {
      return '/';
    }

    return null;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final goRouterPrivider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: AppToast.navigatorKey,
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(title: 'Trang chủ'),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginOtpPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/verify-otp/:phone/:type',
        builder: (context, state) {
          final phone = state.pathParameters['phone'] ?? '';
          final type = state.pathParameters['type'] ?? '';
          final extra = state.extra as Map<String, dynamic>?;
          final pendingUser = extra?['pendingUser'] as AuthUser?;
          final password = extra?['password'] as String?;
          
          return OtpVerificationPage(
            phoneNumber: phone,
            otpType: type,
            pendingUser: pendingUser,
            password: password,
          );
        },
      ),
    ],
  );
});

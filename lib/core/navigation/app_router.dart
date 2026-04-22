import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:hospital_app/core/utils/app_toast.dart';
import 'package:hospital_app/features/auth/domain/models/auth_user.dart';
import 'package:hospital_app/features/auth/presentation/pages/change_password_page.dart';
import 'package:hospital_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:hospital_app/features/auth/presentation/pages/login_otp_page.dart';
import 'package:hospital_app/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:hospital_app/features/auth/presentation/pages/register_page.dart';
import 'package:hospital_app/features/auth/presentation/pages/reset_password_page.dart';
import 'package:hospital_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:hospital_app/features/home/presentation/pages/home_page.dart';

// RouterNotifier to handle reactive redirection
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthUser?>(
      authStateProvider,
      (previous, next) => notifyListeners(),
    );
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authUser = _ref.read(authStateProvider);
    final isLoggedIn = authUser != null;

    final isLoggingIn =
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/register' ||
        state.matchedLocation == '/forgot-password' ||
        state.matchedLocation.startsWith('/verify-otp') ||
        state.matchedLocation.startsWith('/reset-password');

    final isProtected = state.matchedLocation == '/change-password';

    // Not logged in: redirect to login unless on auth pages
    if (!isLoggedIn) {
      return isLoggingIn ? null : '/login';
    }

    // Logged in: don't allow access to auth pages except protected routes
    if (isLoggedIn && isLoggingIn && !isProtected) {
      return '/';
    }

    // Allow access to protected routes only if logged in
    if (isProtected && !isLoggedIn) {
      return '/login';
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
      GoRoute(
        path: '/reset-password/:phone/:otp',
        builder: (context, state) {
          final phone = state.pathParameters['phone'] ?? '';
          final otp = state.pathParameters['otp'] ?? '';

          return ResetPasswordPage(phoneNumber: phone, otp: otp);
        },
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordPage(),
      ),
    ],
  );
});

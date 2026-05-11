import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:hospital_app/core/utils/app_toast.dart';
import 'package:hospital_app/features/auth/data/models/auth_user.dart';
import 'package:hospital_app/features/auth/presentation/pages/change_password_page.dart';
import 'package:hospital_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:hospital_app/features/auth/presentation/pages/login_page.dart';
import 'package:hospital_app/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:hospital_app/features/auth/presentation/pages/register_page.dart';
import 'package:hospital_app/features/auth/presentation/pages/reset_password_page.dart';
import 'package:hospital_app/features/auth/presentation/pages/welcome_page.dart';
import 'package:hospital_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:hospital_app/features/home/presentation/pages/home_page.dart';
import 'package:hospital_app/features/map/presentation/pages/map_page.dart';
import 'package:hospital_app/features/profile/presentation/page/profile_page.dart';
import 'package:hospital_app/features/main/presentation/pages/main_shell.dart';
import 'package:hospital_app/features/medical/presentation/pages/task_list_page.dart';
import 'package:hospital_app/features/medical/presentation/pages/queue_page.dart';
import 'package:hospital_app/features/medical/presentation/pages/prescription_page.dart';

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
      return '/welcome';
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
    initialLocation: '/welcome',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      // Main Application Shell with Bottom Navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // Home Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomePage(title: 'Trang chủ'),
              ),
            ],
          ),
<<<<<<< HEAD
          // Medical Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/medical',
                builder: (context, state) => const TaskListPage(),
                routes: [
                  GoRoute(
                    path: 'queue',
                    builder: (context, state) => const QueuePage(),
                  ),
                  GoRoute(
                    path: 'prescription',
                    builder: (context, state) => const PrescriptionPage(),
                  ),
                ],
              ),
            ],
          ),
=======
>>>>>>> 8009d76 (feat(map): add indoor navigation map feature)
          // Map Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                builder: (context, state) => const MapPage(),
              ),
            ],
          ),
          // Profile Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),

      // Auth Routes
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomePage(),
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
          final optCode = extra?['otp_code'] as String?;

          return OtpVerificationPage(
            phoneNumber: phone,
            otpType: type,
            pendingUser: pendingUser,
            password: password,
            otpCode: optCode,
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

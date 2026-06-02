import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:hospital_app/core/network/session_manager.dart';
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
import 'package:hospital_app/features/info/presentation/pages/about_page.dart';
import 'package:hospital_app/features/info/presentation/pages/contact_page.dart';
import 'package:hospital_app/features/info/presentation/pages/faq_page.dart';
import 'package:hospital_app/features/chat/presentation/pages/chat_rooms_page.dart';
import 'package:hospital_app/features/chat/presentation/pages/chat_messages_page.dart';
import 'package:hospital_app/features/info/presentation/pages/info_page.dart';
import 'package:hospital_app/features/main/presentation/pages/main_shell.dart';
import 'package:hospital_app/features/map/presentation/pages/map_page.dart';
import 'package:hospital_app/features/medical/presentation/pages/prescription_page.dart';
import 'package:hospital_app/features/medical/presentation/pages/queue_page.dart';
import 'package:hospital_app/features/medical/presentation/pages/task_list_page.dart';
import 'package:hospital_app/features/notification/presentation/pages/notification_page.dart';
import 'package:hospital_app/features/profile/presentation/page/profile_page.dart';
import 'package:hospital_app/features/settings/presentation/pages/settings_page.dart';
import 'package:hospital_app/features/sos/presentation/pages/sos_page.dart';
import 'package:hospital_app/features/device/presentation/pages/asset_booking_page.dart';
import 'package:hospital_app/features/device/presentation/pages/asset_stations_page.dart';
import 'package:hospital_app/features/device/presentation/pages/asset_tracking_page.dart';
import 'package:hospital_app/features/device/presentation/pages/broken_asset_report_page.dart';
import 'package:hospital_app/features/device/presentation/pages/wheelchair_search_page.dart';
import 'package:hospital_app/features/map/presentation/pages/obstacle_report_page.dart';
import 'package:hospital_app/features/map/presentation/pages/route_rating_page.dart';
import 'package:hospital_app/features/staff/presentation/pages/request_staff_page.dart';
import 'package:hospital_app/features/util/presentation/pages/feedback_page.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthUser?>(
      authStateProvider,
      (previous, next) => notifyListeners(),
    );
    // Let the network layer force a logout when the backend rejects the token
    // (e.g. logged in from another device). Clearing auth state makes
    // redirect() bounce the user to /login.
    SessionManager.onForceLogout = () =>
        _ref.read(authStateProvider.notifier).logout();
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

    if (!isLoggedIn) {
      return isLoggingIn ? null : '/login';
    }

    if (isLoggedIn && isLoggingIn && !isProtected) {
      return '/welcome';
    }

    if (isProtected && !isLoggedIn) {
      return '/login';
    }

    return null;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: AppToast.navigatorKey,
    initialLocation: '/welcome',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomePage(title: 'Trang chủ'),
              ),
            ],
          ),
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
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                builder: (context, state) => const MapPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
          // Chat Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chat',
                builder: (context, state) => const ChatRoomsPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/notification',
        builder: (context, state) => const NotificationPage(),
      ),
      GoRoute(
        path: '/chat/:room_id',
        builder: (context, state) {
          final roomId =
              int.tryParse(state.pathParameters['room_id'] ?? '') ?? 0;
          final extra = state.extra as Map<String, dynamic>?;
          final roomName = extra?['room_name'] as String? ?? '';
          return ChatMessagesPage(roomId: roomId, roomName: roomName);
        },
      ),
      GoRoute(path: '/info', builder: (context, state) => const InfoPage()),
      GoRoute(path: '/faq', builder: (context, state) => const FaqPage()),
      GoRoute(path: '/about', builder: (context, state) => const AboutPage()),
      GoRoute(
        path: '/contact',
        builder: (context, state) => const ContactPage(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(path: '/sos', builder: (context, state) => const SosPage()),
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
          final otpCode = extra?['otp_code'] as String?;

          return OtpVerificationPage(
            phoneNumber: phone,
            otpType: type,
            pendingUser: pendingUser,
            password: password,
            otpCode: otpCode,
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
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/feedback',
        builder: (context, state) => const FeedbackPage(),
      ),
      // Standalone help page — used by Settings to avoid shell-push conflict
      GoRoute(path: '/help', builder: (context, state) => const InfoPage()),

      // ── Asset / Device ──────────────────────────────────────
      GoRoute(
        path: '/asset/stations',
        builder: (context, state) => const AssetStationsPage(),
      ),
      GoRoute(
        path: '/asset/search',
        builder: (context, state) => const WheelchairSearchPage(),
      ),
      GoRoute(
        path: '/asset/book/:asset_id',
        builder: (context, state) {
          final assetId = state.pathParameters['asset_id'] ?? '';
          return AssetBookingPage(assetId: assetId);
        },
      ),
      GoRoute(
        path: '/asset/track/:asset_id',
        builder: (context, state) {
          final assetId = state.pathParameters['asset_id'] ?? '';
          return AssetTrackingPage(assetId: assetId);
        },
      ),
      GoRoute(
        path: '/asset/report/:asset_id',
        builder: (context, state) {
          final assetId = state.pathParameters['asset_id'] ?? '';
          return BrokenAssetReportPage(assetId: assetId);
        },
      ),

      // ── Staff ────────────────────────────────────────────────
      GoRoute(
        path: '/staff',
        builder: (context, state) => const RequestStaffPage(),
      ),

      // ── Route Features ───────────────────────────────────────
      GoRoute(
        path: '/route/rate/:route_id',
        builder: (context, state) {
          final routeId = state.pathParameters['route_id'] ?? '';
          return RouteRatingPage(routeId: routeId);
        },
      ),

      // ── Traffic & Flow ───────────────────────────────────────
      GoRoute(
        path: '/flow/report-obstacle',
        builder: (context, state) => const ObstacleReportPage(),
      ),
    ],
  );
});

# Hospital App Project Checklist

Last checked: 2026-05-14

This checklist is based on the current Flutter project structure under `lib/`, existing routes in `lib/core/navigation/app_router.dart`, providers, repositories, and visible feature pages.

## Overall Status

- [x] Flutter feature-first structure is in place: `auth`, `map`, `medical`, `profile`, `home`, `main`.
- [x] Riverpod is used for auth, map, medical, and profile state.
- [x] GoRouter app shell is configured with bottom navigation for Home, Medical, Map, and Profile.
- [x] API client/endpoints exist for auth, map, route, medical, and profile.
- [ ] Notification and SOS endpoints/repositories/pages are not wired into the app shell yet.
- [ ] Static info pages are not visible in the current route tree.
- [ ] Demo flow and final QA checklist still need execution.

## Chat 1: Auth Module

Scope: login, signup, OTP, forgot password, 6 pages, auth state management.

- [x] Welcome page exists: `lib/features/auth/presentation/pages/welcome_page.dart`.
- [x] Login page exists: `lib/features/auth/presentation/pages/login_page.dart`.
- [x] Register/signup page exists: `lib/features/auth/presentation/pages/register_page.dart`.
- [x] OTP verification page exists: `lib/features/auth/presentation/pages/otp_verification_page.dart`.
- [x] Forgot password page exists: `lib/features/auth/presentation/pages/forgot_password_page.dart`.
- [x] Reset password page exists: `lib/features/auth/presentation/pages/reset_password_page.dart`.
- [x] Change password page exists: `lib/features/auth/presentation/pages/change_password_page.dart`.
- [x] Auth state provider exists: `lib/features/auth/presentation/providers/auth_provider.dart`.
- [x] Token persistence is wired through `TokenRepository`.
- [x] Auth repository supports login, signup, verify OTP, resend OTP, forgot password, reset password, and change password.
- [x] Router redirects unauthenticated users to `/login`.
- [ ] Confirm full OTP flows against real backend responses.
- [ ] Add/expand tests for auth provider and form validation.
- [ ] Review route naming typo: `goRouterPrivider` should likely be `goRouterProvider`.

## Chat 2: Map + Route Module

Scope: grid-based map rendering, route preview/navigation, floor switching.

- [x] Map page exists: `lib/features/map/presentation/pages/map_page.dart`.
- [x] Grid painter exists: `lib/features/map/presentation/widgets/map_grid_painter.dart`.
- [x] Map search UI exists: top bar and search results panel.
- [x] POI metadata panel exists.
- [x] Route panel exists.
- [x] Route state providers exist for start, destination, mode, result, and route locations.
- [x] Route preview is wired to `route/preview`.
- [x] Map repository supports floors, nodes, edges, metadata, departments, landmarks, full sync, route modes, route preview/order/history.
- [x] Map provider tests exist under `test/features/map/`.
- [ ] Floor switching UI is not complete; current map page uses `_defaultMapId = 1`.
- [ ] Route "navigation" is currently preview/animation-focused; confirm whether turn-by-turn active navigation is required.
- [ ] Wire route order/history/clear history into UI if needed for demo.
- [ ] Add loading/error UI polish for route preview failures.

## Chat 3: Medical Module

Scope: tasks, queue, prescription, appointment display.

- [x] Task list page exists: `lib/features/medical/presentation/pages/task_list_page.dart`.
- [x] Queue page exists: `lib/features/medical/presentation/pages/queue_page.dart`.
- [x] Prescription page exists: `lib/features/medical/presentation/pages/prescription_page.dart`.
- [x] Medical providers exist for tasks, history, queue, room open, result status, and prescription.
- [x] Medical repository supports tasks, history, queue, check-in, check-out, result status, prescription, sync, room open, and cancel task.
- [x] Medical widgets exist for task cards, queue items, and prescription tiles.
- [x] Medical branch is routed in the bottom navigation shell.
- [ ] Appointment display is only represented on Home as a placeholder counter/card; no dedicated appointment data flow is visible.
- [ ] Add tests for medical providers/repository parsing.
- [ ] Confirm task actions against backend: check-in, check-out, cancel, sync.

## Chat 4: Notification + Profile

Scope: notification list, mark read, delete, profile edit.

- [x] Profile page exists: `lib/features/profile/presentation/page/profile_page.dart`.
- [x] Profile edit form exists.
- [x] Profile avatar, profile form, and profile info widgets exist.
- [x] Profile provider supports fetch and update.
- [x] Profile repository is wired to get/set profile endpoints.
- [x] Notification model files exist under `lib/features/notification_support/models/`.
- [ ] Notification list page is missing.
- [ ] Notification provider/state management is missing.
- [ ] Notification repository/API endpoint constants are missing.
- [ ] Mark-read action is not wired to UI/API.
- [ ] Delete notification action is not wired to UI/API.
- [ ] Notification route or bottom-nav entry is not configured.
- [ ] Add profile update success/error toast handling if demo requires visible feedback.

## Chat 5: Util + SOS

Scope: static info pages and SOS feature.

- [x] SOS request model exists in generated notification/support models.
- [ ] SOS page/button is not visible in the route tree or main shell.
- [ ] SOS provider/repository/API endpoint is missing.
- [ ] SOS confirmation/error states are missing.
- [ ] Static info pages are missing from routes and feature folders.
- [ ] Define the static pages needed for demo, for example hospital guide, departments, visiting hours, help/contact.
- [ ] Add navigation entry points for static info and SOS.

## Chat 6: Polish + Demo Prep

Scope: loading states, animations, error handling, demo script execution.

- [x] Shared theme system exists in `lib/core/theme/`.
- [x] Shared `FadeSlideTransition` widget exists.
- [x] Toast utility exists.
- [x] Loading/error states exist in several pages/providers.
- [x] Home page has refresh, logout, theme toggle, and animated summary cards.
- [ ] Run `dart format` after final code changes.
- [ ] Run `dart analyze lib test`.
- [ ] Run `flutter test`.
- [ ] Manually verify auth flow: login, signup, OTP, forgot/reset password, logout.
- [ ] Manually verify map flow: search POI, select start/destination, preview route, clear route, recenter.
- [ ] Manually verify medical flow: task list, queue page, prescription page.
- [ ] Manually verify profile flow: fetch profile, edit fields, update avatar if supported.
- [ ] Prepare seeded test account and backend URL/config for demo.
- [ ] Prepare short demo script with expected screens and fallback plan if backend is unavailable.

## Suggested Next Build Order

1. Finish Chat 4 notification UI/API wiring.
2. Finish Chat 5 SOS and static info pages.
3. Add floor switching to the map module.
4. Replace Home appointment placeholder with real appointment data or remove it from demo scope.
5. Add focused tests for new notification, SOS, auth, and medical state.
6. Run full format/analyze/test and execute the demo script.

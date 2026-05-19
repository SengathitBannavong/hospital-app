# Hospital App Project Checklist

Last checked: 2026-05-18

This checklist is based on the current Flutter project structure under `lib/`, existing routes in `lib/core/navigation/app_router.dart`, providers, repositories, and visible feature pages.
Admin-only web, traffic-control, and algorithm-engine features are intentionally out of scope for this mobile checklist unless explicitly noted.

## Overall Status

- [x] Flutter feature-first structure is in place: `auth`, `map`, `medical`, `profile`, `home`, `main`.
- [x] Riverpod is used for auth, map, medical, and profile state.
- [x] GoRouter app shell is configured with bottom navigation for Home, Medical, Map, and Profile.
- [x] API client/endpoints exist for auth, map, route, medical, and profile.
- [ ] Home page is still mostly a dashboard/demo surface; it fetches task count but does not yet aggregate notifications, appointments, utilities, route status, or asset shortcuts.
- [ ] Notification and SOS endpoints/repositories/pages are not wired into the app shell yet.
- [ ] Static info pages are not visible in the current route tree.
- [ ] Several patient/public Swagger-backed features are not wired into the mobile app yet: voice support, active route guidance, asset booking, staff request, chat/FAQ, utilities, and feedback.
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
- [ ] App version check is not wired; Swagger exposes `sys/check_version`.
- [ ] Account deletion is not wired; Swagger exposes `user/delete_account`.
- [ ] Confirm full OTP flows against real backend responses.
- [ ] Add/expand tests for auth provider and form validation.
- [ ] Review route naming typo: `goRouterPrivider` should likely be `goRouterProvider`.

## Chat 2: Home Module

Scope: mobile dashboard, patient summary cards, quick actions, and public/patient entry points.

- [x] Home page exists: `lib/features/home/presentation/pages/home_page.dart`.
- [x] Home repository exists: `lib/features/home/data/home_repository.dart`.
- [x] Home branch is routed in the bottom navigation shell.
- [x] Home fetches `medical/get_tasks` and displays the current task count.
- [x] Home includes pull-to-refresh, manual refresh, theme toggle, logout, toast examples, and animated summary cards.
- [ ] Home still uses a local counter for appointments; no real appointment API/data flow is wired.
- [ ] Home "doctors available" card is static demo content.
- [ ] Home notification area is static/demo-only; it is not wired to `notification/get_list`.
- [ ] Home quick actions are missing for Map, Medical tasks, Notifications, SOS, FAQ/help, utilities, wheelchair booking, staff request, and chat/support.
- [ ] Home does not show live utility data even though Swagger exposes `util/weather`, `util/parking`, `util/pharmacy`, `util/canteen`, and `util/wifi`.
- [ ] Home does not show active route status even though Swagger exposes `route/get_active` and route lifecycle APIs.
- [ ] Home does not surface device/asset state even though Swagger exposes wheelchair/device APIs.
- [ ] Replace toast demo buttons and FAB appointment counter with real patient actions before demo/final delivery.
- [ ] Add tests for Home task-count loading, error state, refresh behavior, and navigation shortcuts.

## Chat 3: Map + Route Module

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
- [ ] Voice route support is not wired; Swagger exposes `sys/get_voice_key` and `sys/get_voice_files`.
- [ ] Turn-by-turn route APIs are not wired in UI/repository: `route/get_steps`, `route/get_next`, `route/get_eta`, `route/pass_node`, and `route/recalculate`.
- [ ] Active route lifecycle is not wired: `route/order`, `route/get_active`, `route/cancel`, `route/share`, and `route/rate`.
- [ ] Multi-stop route ordering is not exposed in UI even though Swagger supports `route/order_multi` and `route/order_unordered`.
- [ ] Wheelchair/stretcher/hospital-cart modes are supported by Swagger route modes, but need verification in UI and backend responses.
- [ ] Patient-side traffic/flow data is not surfaced: `flow/get_density`, `flow/get_heatmap`, `flow/get_bottlenecks`, `flow/get_forecast`, `flow/get_alerts`, and `flow/edge_status`.
- [ ] Patient-side location/obstacle reporting is not wired: `flow/ping_location`, `flow/report_obstacle`, and `flow/get_obstacles`.
- [ ] Offline map fallback is not implemented; `map/sync_full` can support local cache, but client-side static routing/Dijkstra is still missing.
- [ ] Wire route order/history/clear history into UI if needed for demo.
- [ ] Add loading/error UI polish for route preview failures.

## Chat 4: Medical Module

Scope: tasks, queue, prescription, appointment display.

- [x] Task list page exists: `lib/features/medical/presentation/pages/task_list_page.dart`.
- [x] Queue page exists: `lib/features/medical/presentation/pages/queue_page.dart`.
- [x] Prescription page exists: `lib/features/medical/presentation/pages/prescription_page.dart`.
- [x] Medical providers exist for tasks, history, queue, room open, result status, and prescription.
- [x] Medical repository supports tasks, history, queue, check-in, check-out, result status, prescription, sync, room open, and cancel task.
- [x] Medical widgets exist for task cards, queue items, and prescription tiles.
- [x] Medical branch is routed in the bottom navigation shell.
- [ ] Appointment display is only represented on Home as a placeholder counter/card; no dedicated appointment data flow is visible.
- [ ] QR scanning UI is not implemented; check-in/check-out APIs exist, but the client still needs camera scan flow and treatment/room validation.
- [ ] Medical records/history screen is missing; Swagger exposes `medical/get_history`, `medical/result_status`, and `medical/get_prescription`.
- [ ] Add tests for medical providers/repository parsing.
- [ ] Confirm task actions against backend: check-in, check-out, cancel, sync.

## Chat 5: Notification + Profile

Scope: notification list, mark read, delete, profile edit.

- [x] Profile page exists: `lib/features/profile/presentation/page/profile_page.dart`.
- [x] Profile edit form exists.
- [x] Profile avatar, profile form, and profile info widgets exist.
- [x] Profile provider supports fetch and update.
- [x] Profile repository is wired to get/set profile endpoints.
- [x] Notification model files exist under `lib/features/notification_support/models/`.
- [x] Notification list page exists and is wired in app shell.
- [x] Notification provider/state management exists.
- [x] Notification repository/API endpoint constants are wired.
- [x] Mark-read action is wired to UI/API.
- [x] Delete notification action is wired to UI/API.
- [x] Notification route or bottom-nav entry is configured.
- [ ] Verify notification response fields (`id`, `title`, `message`, `created_at`, `is_read`) and update parsing if backend differs.
- [ ] Confirm `DELETE /notification/delete` accepts JSON body in production.
- [ ] Use `total/page/limit` to implement pagination or load-more.
- [ ] Show notification time in UI (use `created_at`).
- [ ] Add global unread badge count (tab/app bar).
- [ ] Register device token with `user/set_devtoken` and update via push.
- [ ] Add notification settings UI using `user/get_settings` and `user/set_settings`.
- [ ] Add repository/provider tests for notification flow.
- [ ] Manual QA: list load, pull-to-refresh, mark read, delete.
- [ ] Push notification/device-token flow is not complete; Swagger exposes `user/set_devtoken`, user settings, and notification APIs, but app-side push registration still needs implementation.
- [ ] Add profile update success/error toast handling if demo requires visible feedback.

## Chat 6: Util + SOS

Scope: static info pages and SOS feature.

- [x] SOS request model exists in generated notification/support models.
- [ ] SOS page/button is not visible in the route tree or main shell.
- [ ] SOS provider/repository/API endpoint is missing.
- [ ] SOS confirmation/error states are missing.
- [ ] Static info pages are missing from routes and feature folders.
- [ ] Define the static pages needed for demo, for example hospital guide, departments, visiting hours, help/contact.
- [ ] Public utility APIs are available but not wired: `util/faq`, `util/about`, `util/contact`, `util/pharmacy`, `util/canteen`, `util/parking`, `util/wifi`, and `util/weather`.
- [ ] Feedback submission is not wired; Swagger exposes `util/feedback`.
- [ ] Language list/settings are not wired; Swagger exposes `util/languages`, `user/get_settings`, and `user/set_settings`.
- [ ] File upload is not wired; Swagger exposes `util/upload`, useful for feedback/report images if backend accepts attachments.
- [ ] Add navigation entry points for static info and SOS.

## Chat 7: Patient/Public API-backed Features Missing From Mobile

Scope: features available in `swagger.yaml` for patient/public/mobile use, excluding admin-only web, flow-control, and engine-management screens.

- [ ] Device/asset feature is missing from the app: `asset/asset_stations`, `asset/find_wheelchairs`, `asset/book_asset`, `asset/release_asset`, `asset/asset_health`, `asset/track_asset`, and `asset/report_broken_asset`.
- [ ] Staff assistance request is missing: `staff/request_staff`.
- [ ] Chat/support UI is missing: `chat/create_room`, `chat/get_rooms`, `chat/get_messages`, `chat/send_message`, `chat/get_unread_count`, `chat/mark_read`, and `ws/chat`.
- [ ] FAQ/help center is missing even though `util/faq`, `util/about`, and `util/contact` are available.
- [ ] Hospital utility pages are missing even though `util/pharmacy`, `util/canteen`, `util/parking`, `util/wifi`, and `util/weather` are available.
- [ ] Feedback UI is missing even though `util/feedback` is available.
- [ ] Route sharing/rating/history UI is missing even though route APIs exist.
- [ ] Patient traffic awareness and reporting are missing even though public Flow APIs exist for density, heatmap, alerts, ping location, and obstacle reports.
- [ ] User settings page is not wired for language/theme/notification preferences even though `user/get_settings` and `user/set_settings` exist in Swagger.

## Chat 8: Polish + Demo Prep

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

1. Finish Chat 5 notification UI/API wiring.
2. Finish Chat 6 SOS and static info pages.
3. Turn Home into the patient dashboard: replace demo cards/actions with real task, notification, utility, route, SOS, and asset entry points.
4. Add patient utility pages backed by Swagger: FAQ, contact/about, pharmacy, canteen, parking, Wi-Fi, weather, and feedback.
5. Add device/asset flow: stations, available wheelchairs, booking, release, health, track, report broken, and staff request.
6. Add active route guidance: order active route, steps, next step, ETA, pass-node, recalculate, cancel, share, and rate.
7. Add floor switching to the map module.
8. Replace Home appointment placeholder with real appointment data or remove it from demo scope.
9. Add focused tests for new Home, notification, SOS, utilities, assets, route guidance, auth, and medical state.
10. Run full format/analyze/test and execute the demo script.

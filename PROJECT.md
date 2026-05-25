# Hospital App Project Checklist

Last checked: 2026-05-25 (Notification, Home, Navigation, Firebase)

This checklist is based on the current Flutter project structure under `lib/`, existing routes in `lib/core/navigation/app_router.dart`, providers, repositories, and visible feature pages.
Admin-only web, traffic-control, and algorithm-engine features are intentionally out of scope for this mobile checklist unless explicitly noted.

## Overall Status

- [x] Flutter feature-first structure is in place: `auth`, `map`, `medical`, `profile`, `home`, `main`.
- [x] Riverpod is used for auth, map, medical, and profile state.
- [x] GoRouter app shell uses a 4-tab bottom navigation (Home, Medical, Map, Profile). Notification, Info, FAQ, About, and Contact are top-level pushed routes with back buttons (no longer bottom-nav tabs).
- [x] API client/endpoints exist for auth, map, route, medical, and profile.
- [x] Home page aggregates real task count and live notifications (unread bell in the app bar + summary card); demo placeholder cards and the FAB counter were removed. Utilities, route status, and asset shortcuts are still not aggregated.
- [x] Notification endpoints/repositories/pages are wired into the app shell, with pagination/load-more, mark-read, delete, settings, and an unread badge.
- [x] Firebase Cloud Messaging push is implemented client-side but **optional** (off by default; gated behind the `ENABLE_FIREBASE` dart-define). API keys are sourced from dart-defines, not committed. See `FIREBASE.md`.
- [ ] SOS endpoints/repositories/pages are not wired into the app shell yet.
- [x] Static info pages are visible in the current route tree (`/info`).
- [x] Settings page exists at `/settings`, accessible via gear icon in Profile page AppBar: theme switcher, notification toggles, change-password shortcut, logout, and app info.
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
- [x] App version check is wired through `VersionCheckWidget` and `sys/check_version`.
- [x] Account deletion is wired through `ProfilePage`, `DeleteAccountService`, and `user/delete_account`.
- [x] Run build_runner; generated Freezed/json files are present.
- [x] Login is direct phone/password per `swagger.yaml`; no login OTP is required.
- [ ] Confirm signup OTP flow against real backend responses.
- [x] Confirm forgot/reset-password OTP flow against real backend responses.
- [ ] Decide whether signup OTP resend is required; current code disables signup resend.
- [x] Auth provider tests exist.
- [x] Form validation tests exist.
- [ ] Expand tests for auth repository errors, router redirects, widget flows, version check dialog, and delete account UI.
- [x] Route provider is named `goRouterProvider`; no `goRouterPrivider` typo exists in `lib/`.

## Chat 2: Home Module

Scope: mobile dashboard, patient summary cards, quick actions, and public/patient entry points.

- [x] Home page exists: `lib/features/home/presentation/pages/home_page.dart`.
- [x] Home repository exists: `lib/features/home/data/home_repository.dart`.
- [x] Home branch is routed in the bottom navigation shell.
- [x] Home fetches `medical/get_tasks` and displays the current task count.
- [x] Home includes pull-to-refresh, manual refresh, theme toggle, logout, and animated summary cards.
- [x] Removed the local appointment counter, the static "doctors available" demo card, and the FAB appointment counter.
- [x] Home shows live notifications: an unread bell in the app bar (badge from `unreadCountProvider`) and a summary card, both wired to `notification/get_list` and opening `/notification` via push.
- [x] Home quick actions de-duplicated (Map/Medical/Profile removed since they are tabs); a single "Thông tin" shortcut opens the Info hub. Shortcuts are still missing for SOS, utilities, wheelchair booking, staff request, and chat/support.
- [ ] Home does not show live utility data even though Swagger exposes `util/weather`, `util/parking`, `util/pharmacy`, `util/canteen`, and `util/wifi`.
- [ ] Home does not show active route status even though Swagger exposes `route/get_active` and route lifecycle APIs.
- [ ] Home does not surface device/asset state even though Swagger exposes wheelchair/device APIs.
- [x] Removed the FAB appointment counter; remaining placeholder content cleaned for demo.
- [ ] Add tests for Home task-count loading, error state, refresh behavior, and navigation shortcuts.

## Chat 3: Map + Route Module

Scope: grid map rendering, route preview/navigation, floor switching, offline
routing, and patient-facing flow analytics. Major backlog tracking only.

Done (major capabilities)

- [x] Grid map: rendering, POI search + metadata sheet, legend, zoom/pan, recenter; first-paint-fast deferred walkable layer.
- [x] Multi-floor: floor switcher; meta/nodes/edges/search/POI follow the active floor; route + search reset on floor change.
- [x] Positioning: "you are here" (entrance default), long-press pin, QR scan (`poi_code`), "I'm here" on landmark POIs.
- [x] Navigation (simulated): animated dot, mode-based speed, traveled/remaining split, camera follow, live distance/ETA, pause/resume/stop, ×1/×2, arrival; `route/order` logged on arrival.
- [x] Routing: typed RouteResult, `route/preview`, client-side A*/Dijkstra engine as crowd-aware authority.
- [x] Dynamic rerouting around blocked/congested edges (`route/recalculate` online, cached-graph reroute offline).
- [x] Offline: `map/sync_full` + granular meta/nodes/edges/obstacles cache (Hive), offline route cache, in-memory edge cache + isolate parse.
- [x] Flow analytics: density heatmap, bottlenecks, alerts, client-derived corridor congestion, hourly forecast chart.
- [x] Obstacle reporting (`flow/report_obstacle` + `flow/get_obstacles`) with offline queue; obstacle-aware routing.
- [x] Route history modal (re-navigate + clear via `route/clear_history`) and offline clear-cache modal.
- [x] Tests under `test/features/map/` (91 passing); `flutter analyze` clean.

Backlog (remaining)

Genuinely still missing (code):

| Gap | Evidence |
|-----|----------|
| Voice guidance unwired | `voice_service.dart` exists but zero call sites in navigation |
| `pass_node` / `ping_location` | `PassNodeReporter` + `pingLocation()` exist but are a queued stub (TODO: pending backend) |

Verify-only (not code, backend confirmation): non-walking `speed_factor` and meters-per-cell label truthfulness.

### Map — out of scope (optional)

- `route/order_multi`, `route/order_unordered` — multi-stop routing.
- `route/share`, `route/rate` — route sharing / rating.
- `route/get_active`, `route/cancel` — server-side route lifecycle (local Stop covers the demo).

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
- [x] Medical history, result-status dialog, and prescription page are wired.
- [ ] Add tests for medical providers/repository parsing.
- [ ] Confirm task actions against backend: check-in, check-out, cancel, sync.

## Chat 5: Notification + Profile

Scope: notification list, mark read, delete, profile edit.

- [x] Profile page exists: `lib/features/profile/presentation/page/profile_page.dart`.
- [x] Profile edit form exists.
- [x] Profile avatar, profile form, and profile info widgets exist.
- [x] Profile provider supports fetch and update.
- [x] Profile repository is wired to get/set profile endpoints.
- [x] Profile data layer refactored into `profile_state.dart` / `profile_update_request.dart` with a remote data source.
- [x] Notification model files exist under `lib/features/notification/data/models/`; list items are unified on `AppNotification` (legacy `NotificationModel`/`NotificationListResponse`/`NotificationTile` removed).
- [x] Notification list page exists and is wired as a top-level pushed route (back button), using `NotificationCard` with infinite scroll + pull-to-refresh.
- [x] Notification provider/state management exists.
- [x] Notification repository/API endpoint constants are wired.
- [x] Mark-read action is wired to UI/API.
- [x] Delete notification action is wired to UI/API.
- [x] Notification route or bottom-nav entry is configured.
- [x] Notification parsing is defensive for `id/notif_id/notification_id`, `message/content/body`, `time/created_at`, and `is_read/read/isRead`.
- [x] Confirm `DELETE /notification/delete` accepts JSON body in production.
- [x] Use `total/page/limit` to implement pagination or load-more.
- [x] Show notification time in UI (`NotificationCard` renders `created_at`).
- [x] Add global unread badge count (Home app-bar bell via `unreadCountProvider`).
- [x] Register device token with `user/set_devtoken` (sends `device_token` + `platform`); driven by the optional Firebase service.
- [x] Add notification settings UI using `user/get_settings` and `user/set_settings` (`notification_settings_page.dart`).
- [ ] Add repository/provider tests for notification flow.
- [ ] Manual QA: list load, pull-to-refresh, mark read, delete.
- [x] App-side push registration is implemented (FCM client) but **optional** via `ENABLE_FIREBASE`. NOTE: the backend stores tokens but does not send pushes yet, so no push arrives until the backend FCM sender ships.
- [ ] Add profile update success/error toast handling if demo requires visible feedback.

## Chat 6: Util + SOS

Scope: static info pages and SOS feature.

- [ ] SOS request model is missing.
- [ ] SOS page/button is not visible in the route tree or main shell.
- [ ] SOS provider/repository/API endpoint is missing.
- [ ] SOS confirmation/error states are missing.
- [x] Info page (`/info`) is now a **hub** that links FAQ, Giới thiệu (About), and Liên hệ (Contact) as separate pushed pages with back buttons; the duplicate `/faq` route was removed.
- [x] Define/expand static info pages needed for demo (hospital guide, departments, visiting hours, help/contact).
- [ ] Public utility APIs are available but not wired: `util/faq`, `util/about`, `util/contact`, `util/pharmacy`, `util/canteen`, `util/parking`, `util/wifi`, and `util/weather`.
- [ ] Feedback submission is not wired; Swagger exposes `util/feedback`.
- [ ] Language list/settings are not wired; Swagger exposes `util/languages`, `user/get_settings`, and `user/set_settings`.
- [ ] File upload is not wired; Swagger exposes `util/upload`, useful for feedback/report images if backend accepts attachments.
- [x] Add navigation entry points for static info pages.
- [ ] Add navigation entry points for SOS.

## Chat 7: Patient/Public API-backed Features Missing From Mobile

Scope: features available in `swagger.yaml` for patient/public/mobile use, excluding admin-only web, flow-control, and engine-management screens.

- [ ] Device/asset feature is missing from the app: `asset/asset_stations`, `asset/find_wheelchairs`, `asset/book_asset`, `asset/release_asset`, `asset/asset_health`, `asset/track_asset`, and `asset/report_broken_asset`.
- [ ] Staff assistance request is missing: `staff/request_staff`.
- [ ] Chat/support UI is missing: `chat/create_room`, `chat/get_rooms`, `chat/get_messages`, `chat/send_message`, `chat/get_unread_count`, `chat/mark_read`, and `ws/chat`.
- [ ] FAQ/help center is static-only; `util/faq`, `util/about`, and `util/contact` are not wired.
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
## Chat 9: Settings Module

Scope: user settings page covering account, appearance, notifications, and app information.




- [x] "Change password" button — navigates to `/change-password` (page already exists).
- [x] "Logout" button — shows a confirmation AlertDialog, then calls `authStateProvider.notifier.logout()`.
- [x] Theme selection is shown with `SegmentedButton<ThemeMode>` with 3 options: Light / System / Dark.
- [x] `ThemeController.setThemeMode(ThemeMode)` was added to `lib/core/theme/theme_controller.dart` to support direct selection (in addition to the existing `toggleTheme()`).
- [x] Theme state updates in real time through `ListenableBuilder` — `themeController` is a global `ChangeNotifier`.
- [ ] Theme selection is not persisted across restarts yet (SharedPreferences or Hive needed).
- [x] Toggle "Enable notifications" — turns all notifications on/off (in-memory state).
- [x] Toggle "Appointment reminders" — automatically disabled when global notifications are turned off.
- [ ] Not wired to the `user/get_settings` / `user/set_settings` APIs.
- [ ] Not wired to the device push token (`user/set_devtoken`).
- [x] "Help & Support" — navigates to `/info` (FAQ page already exists).
- [x] "About app" — opens `showAboutDialog` with the app name, version, and a short description.
- [x] "Version" — shows static `1.0.0`.
- [ ] Not wired to the real version from `sys/check_version`.



## Suggested Next Build Order

1. Persist Settings: wire SharedPreferences/Hive for theme and notification toggles in the Settings page.
2. Wire Settings notifications to `user/get_settings` / `user/set_settings` (device token is already wired).
3. ~~Finish Chat 5 notification UI/API wiring.~~ Done (pagination, badge, settings, device token, optional FCM push). Remaining: tests + manual QA.
4. Finish Chat 6 SOS; static info pages now organised under the Info hub.
5. Turn Home into the patient dashboard: add utility, route, SOS, and asset entry points (task + notification already wired).
6. Add patient utility pages backed by Swagger: FAQ, contact/about, pharmacy, canteen, parking, Wi-Fi, weather, and feedback.
7. Add device/asset flow: stations, available wheelchairs, booking, release, health, track, report broken, and staff request.
8. Add active route guidance: order active route, steps, next step, ETA, pass-node, recalculate, cancel, share, and rate.
9. Add floor switching to the map module.
10. Add focused tests for new Home, notification, settings, SOS, utilities, assets, route guidance, auth, and medical state.
11. Run full format/analyze/test and execute the demo script.

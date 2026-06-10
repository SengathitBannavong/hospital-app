# Hospital App Project Checklist

Last checked: 2026-06-03 (branch `main`, HEAD `a8a67e7`)

This checklist is based on the current Flutter project structure under `lib/`, existing routes in `lib/core/navigation/app_router.dart`, providers, repositories, and visible feature pages.
Admin-only web, traffic-control, and algorithm-engine features are intentionally out of scope for this mobile checklist unless explicitly noted.

## Current State (2026-06-03)

Overall user-facing progress is higher than the old 68% snapshot, but has not
been recalculated in [`doc/overview_process.md`](doc/overview_process.md).

**Latest pass (#51 — patient-facing optimization):** Home quick-access expanded
to a **6-shortcut grid** (queue, find wheelchair, staff support, prescription,
obstacle report, SOS); swipe-to-switch-tab in `MainShell` with Profile moved to
the last nav slot and "Y tế" relabeled "Utilities"; a shared `PoiPickerField` /
`showPoiPicker` lets queue/wheelchair/staff flows pick a location instead of
typing a code; per-task check-in/out/result/cancel extracted into a dedicated
`TaskDetailPage`; and a map declutter (left FAB rail cut to 3 — QR/recenter/More
— with legend, route history, and flow analytics folded into a More sheet, and
offline-cache clearing moved to Settings).

**Current branch:** notifications with pagination/load-more, unread bell,
notification settings, device-token registration, and **optional** Firebase push
(off by default); unified Settings; chat; SOS; asset/wheelchair flows; staff
request; feedback; dynamic FAQ/About/Contact; map POI-backed utility metadata;
and REST force-logout on token rejection.

**Known limitations:** the backend stores device tokens but does **not** send
pushes yet and has no real notification triggers, so notifications are seed-only
in practice; `auth/logout` is local-only; `auth/resend_otp` has no backend route;
chat WebSocket `401`/`3009` still needs force-logout wiring; active route
guidance, voice guidance, and Medical QR check-in/out remain backlog.

## Overall Status

- [x] Flutter feature-first structure is in place: `auth`, `map`, `medical`, `profile`, `home`, `main`.
- [x] Riverpod is used for auth, map, medical, and profile state.
- [x] GoRouter app shell uses a **5-tab** bottom navigation (Home, Utilities, Map, Chat, Profile) with swipe-to-switch between tabs. Notification, Info, FAQ, About, Contact, SOS, Feedback, and individual chat rooms are top-level pushed routes with back buttons (no longer bottom-nav tabs).
- [x] API client/endpoints exist for auth, map, route, medical, and profile.
- [x] Home page aggregates real task count, live notifications, weather, and a 6-shortcut quick-access grid (queue, find wheelchair, staff, prescription, obstacle report, SOS) plus the map preview; demo placeholder cards and the FAB counter were removed. Active route status and asset summaries are still not aggregated.
- [x] Notification endpoints/repositories/pages are wired into the app shell, with pagination/load-more, mark-read, delete, settings, and an unread badge.
- [x] Firebase Cloud Messaging push is implemented client-side but **optional** (off by default; gated behind the `ENABLE_FIREBASE` dart-define). API keys are sourced from dart-defines, not committed. See `FIREBASE.md`.
- [x] SOS endpoints/repositories/pages are wired, with a `/sos` route and Home shortcut.
- [x] Static info pages are visible in the current route tree (`/info`).
- [x] Single Settings page at `/settings`, reached via the gear icon in the Home, Profile, and Notification app bars: theme (persisted to backend), notification + language preferences (via `user/get_settings` / `user/set_settings`), change password, logout, and app info.
- [ ] Remaining patient/public gaps: voice guidance, backend-synced active route guidance, Medical QR check-in/out, and chat product polish.
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
- [x] Home includes pull-to-refresh, manual refresh, a Settings gear, a notification bell with unread badge, logout, and animated summary cards.
- [x] Removed the local appointment counter, the static "doctors available" demo card, and the FAB appointment counter.
- [x] Home shows live notifications: an unread bell in the app bar (badge from `unreadCountProvider`) and a summary card, both wired to `notification/get_list` and opening `/notification` via push.
- [x] Home quick actions expanded into a **6-shortcut grid** — queue, find wheelchair, staff support, prescription, obstacle report (warning color), and SOS (emergency color) — bringing the top patient flows one tap from launch. Nav-duplicating Map/Medical/Profile actions remain removed.
- [x] Home shows live weather from `util/weather`; pharmacy/canteen/parking are map POI metadata, not standalone Home utility cards.
- [ ] Home does not show active route status even though Swagger exposes `route/get_active` and route lifecycle APIs.
- [ ] Home does not surface device/asset state summaries even though wheelchair/device flows are wired elsewhere.
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
- [x] Route history modal (re-navigate + clear via `route/clear_history`); offline clear-cache moved to Settings.
- [x] Declutter pass: left FAB rail cut to 3 (QR, recenter, More); legend, route history, and flow analytics fold into a More sheet; search collapses to an icon by default; POI panel gains a "Yêu cầu hỗ trợ" action that opens request-staff pre-filled with the POI; shared `PoiPickerField` used across queue/wheelchair/staff.
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
- [x] Per-task check-in / check-out / result / cancel extracted into a dedicated `TaskDetailPage` (`/medical/task`, task via `state.extra`); `TaskListPage` shows a 2-per-row utility action grid and taps `TaskCard` through to detail. Each action invalidates `medicalTasksProvider`/`medicalHistoryProvider` then pops.
- [x] Queue page uses the shared `PoiPickerField` / `showPoiPicker` so users pick a location from the active map's POIs instead of typing a code.
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
- [x] Notification settings handled by the unified Settings page via `user/get_settings` / `user/set_settings` (the standalone `notification_settings_page.dart` was removed).
- [x] Add repository/provider tests for notification flow.
- [x] Manual QA: list load, pull-to-refresh, mark read, delete.
- [x] App-side push registration is implemented (FCM client) but **optional** via `ENABLE_FIREBASE`. NOTE: the backend stores tokens but does not send pushes yet, so no push arrives until the backend FCM sender ships.
- [x] Add profile update success/error toast handling if demo requires visible feedback.

## Chat 6: Util + SOS

Scope: static info pages and SOS feature.

- [x] SOS request/detail models exist.
- [x] SOS page/button is visible via `/sos` and the Home shortcut.
- [x] SOS provider/repository/API endpoints are wired to `sos/create` and `sos/get_detail`.
- [x] SOS confirmation/error states are present.
- [x] Info page (`/info`) is now a **hub** that links FAQ, About, and Contact as separate pushed pages with back buttons.
- [x] Define/expand static info pages needed for demo (hospital guide, departments, visiting hours, help/contact).
- [x] Public utility APIs are partially wired: `util/faq`, `util/about`, `util/contact`, `util/weather`, `util/feedback`, and `util/feedback_summary`.
- [x] Pharmacy/canteen/parking utility info is intentionally POI-backed via `map/get_nodes` metadata and shown on map POI tap.
- [x] Feedback submission is wired through `/feedback`.
- [x] Language + notification + theme preferences are wired to `user/get_settings` / `user/set_settings`. (Dynamic `util/languages` list still not used — the picker is static vi/en.)
- [ ] File upload is not wired; Swagger exposes `util/upload`, useful for feedback/report images if backend accepts attachments.
- [x] Add navigation entry points for static info pages.
- [x] Add navigation entry points for SOS.

## Chat 7: Patient/Public API-backed Features

Scope: features available in `swagger.yaml` for patient/public/mobile use, excluding admin-only web, flow-control, and engine-management screens.

- [x] Device/asset feature is wired: `asset/asset_stations`, `asset/find_wheelchairs`, `asset/book_asset`, `asset/release_asset`, `asset/asset_health`, `asset/track_asset`, and `asset/report_broken_asset`.
- [x] Staff assistance request is wired: `staff/request_staff`.
- [x] Chat/support UI is wired for rooms, messages, send, unread aggregation, mark-read, and `ws/chat`; create-room UI and some polish remain backlog.
- [x] FAQ/help center uses `util/faq`, `util/about`, and `util/contact`.
- [x] Hospital utilities are no longer standalone list pages: weather stays on Home, while pharmacy/canteen/parking are POI metadata on the Map. WiFi is dropped unless backend adds it as a navigable POI.
- [x] Feedback UI is wired to `util/feedback`.
- [x] Route history UI and route rating page are wired; route sharing has a repository method but no visible UI yet.
- [x] Patient traffic awareness and reporting are wired through the Map flow overlays, route history sheet, and obstacle reporting.
- [x] User settings page is wired for language/theme/notification preferences via `user/get_settings` and `user/set_settings`.


## Chat 8: Polish + Demo Prep

Scope: loading states, animations, error handling, demo script execution.

- [x] Shared theme system exists in `lib/core/theme/`.
- [x] Shared `FadeSlideTransition` widget exists.
- [x] Toast utility exists.
- [x] Loading/error states exist in several pages/providers.
- [x] Home page has refresh, a Settings gear, a notification bell, logout, and animated summary cards.
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


- [x] Single Settings page (`/settings`) — consolidated from the old per-feature settings; reached via the gear icon in the Home, Profile, and Notification app bars (the standalone `notification_settings_page.dart` was removed).
- [x] Backed by `user/get_settings` / `user/set_settings` — theme, notification on/off, and language load and save to the backend (partial updates).
- [x] Theme: `SegmentedButton<ThemeMode>` (Light / System / Dark); applies live via `themeController` and **persists via the backend `theme` field**; restored on launch/login by `AppInitializer`.
- [x] `ThemeController.setThemeMode(ThemeMode)` supports direct selection.
- [x] "Change password" → `/change-password`; "Logout" → confirm dialog → `logout()`.
- [x] Device push token (`user/set_devtoken`) registered via the optional Firebase service.
- [x] "Help & Support" → `/help`; "About app" → `showAboutDialog`; "Version" shows the installed package version via `PackageInfo`.
- [x] Offline map-cache clearing lives here (moved from the Map screen, where a destructive action did not belong).
- [ ] Voice-guidance + travel-mode toggles dropped — backend `get/set_settings` does not expose those columns yet.
- [x] "Version" reads the installed package version via `PackageInfo.fromPlatform()` (no longer a static `1.0.0`).

## Chat 10: Chat Module

Scope: real-time messaging between patients and support staff, including chat room list, message history, send message, and WebSocket real-time updates.

- [x] Chat room list page exists: `lib/features/chat/presentation/pages/chat_rooms_page.dart`.
- [x] Chat message history page exists: `lib/features/chat/presentation/pages/chat_messages_page.dart`.
- [x] Route `/chat` is wired into the bottom navigation shell.
- [x] Route `/chat/:room_id` is a full-screen page (outside the shell) that receives `room_id` and `room_name` via `extra`.
- [x] `ChatRoom` model exists: `lib/features/chat/data/models/chat_room.dart` (id, name, lastMessage, lastMessageAt, unreadCount, avatarUrl).
- [x] `ChatMessage` model exists: `lib/features/chat/data/models/chat_message.dart`.
- [x] `ChatRepository` exists: `lib/features/chat/data/repository/chat_repository.dart`.
- [x] `ChatRemoteDataSource` exists: `lib/features/chat/data/datasources/chat_remote_data_source.dart`.
- [x] Repository supports: `getRooms`, `createRoom`, `getMessages` (paginated), `sendMessage`, `getUnreadCount`, `markRead`.
- [x] Fixed runtime crash `_JsonMap is not a subtype of List`: `getRooms` and `getMessages` now handle both cases where the API returns `data` as a direct List or as a Map containing key `rooms`/`messages`/`data`.
- [x] `chatRoomsProvider` (StateNotifier) exists: load, refresh, createRoom, markRoomRead, updateRoomLastMessage.
- [x] `chatMessagesProvider` (StateNotifierProvider.family<int>) exists: load, loadMore (pagination), sendMessage, markRead.
- [x] `chatUnreadTotalProvider` aggregates the total unread badge count across all rooms.
- [x] `ChatRoomsState` and `ChatMessagesState` exist under `presentation/providers/`.
- [x] `ChatWebSocketService` exists: `lib/core/services/chat_websocket_service.dart`.
- [x] `chatWsProvider` opens the WebSocket connection on entering chat and disposes it on exit.
- [x] `ChatMessagesNotifier` subscribes/unsubscribes to a room via WebSocket and receives new messages via stream.
- [x] Incoming WebSocket messages are deduplicated by `message.id` before being added to state.
- [x] WebSocket reconnect on disconnect is handled: `ChatWebSocketService` auto-reconnects (3s) and exposes a `connectionStates` stream; `ChatMessagesNotifier` runs a catch-up fetch on every reconnect to backfill messages dropped during the gap (the broadcast does not replay history).
- [x] In-conversation sync is WebSocket-primary: realtime via the socket, catch-up on reconnect, and a slow 25s backstop poll for silent socket failures (replaces the old 4s poll).
- [x] Rooms list polls `get_rooms` every 60s via a root-anchored provider; the timer is lifecycle-aware (paused only on real backgrounding, not the transient `inactive` event that would otherwise reset the countdown and stall polling).
- [x] Rooms are merged in place across polls (`_mergePreservingOrder`) so rows keep their position — a room with a new message lights its unread dot/badge without the list reordering/jumping.
- [x] Conversation view preserves scroll position when messages arrive while the user is scrolled up, showing a tap-to-jump "Tin nhắn mới" pill instead of snapping to newest; auto-scrolls only when at the bottom or on the user's own send.
- [ ] WebSocket connection status (connected/disconnected) is not surfaced in the UI (the `connectionStates` stream exists but is consumed only for catch-up, not shown).
- [ ] Rooms list cannot be push-updated: the WS broadcast omits `conversation_id` and there is no global user-level socket, so the 60s poll is the only awareness path until one of those lands.
- [x] `ChatRoomCard` — displays room name, last message, timestamp, and unread badge count.
- [x] `ChatMessageBubble` — message bubble distinguishing sent vs. received messages.
- [x] `ChatAvatar` — chat room avatar.
- [x] `ChatTimeLabel` — time separator label between message groups.
- [ ] No UI for creating a new chat room (`createRoom` exists in the repository but has no screen).
- [ ] Message pagination (`loadMore`) is not wired to the UI (scroll-to-top trigger missing).
- [ ] `getUnreadCount` API is not wired to the badge icon on the bottom navigation.
- [ ] No delete/leave room functionality in the UI.
- [ ] No typing indicator via WebSocket.
- [ ] Sending images/file attachments is not supported.
- [x] Tests exist for `ChatRoomsNotifier`, `ChatMessagesNotifier`, the WebSocket service, and JSON parsing (`test/features/chat/`, 27 passing).

## Backlog

Prioritised for the team. **Area:** FE = Flutter app · BE = Go backend ·
FE+BE = both. **Effort:** S ≈ half a day · M ≈ 1–3 days · L ≈ a week+.
**P0** = do next.

### Recently shipped (context)
Recent git history now includes: notifications (pagination, unread bell,
settings, device-token, optional push) · unified Settings page
(theme/notification/language, backend-persisted) · chat rooms/messages/WebSocket
sync · SOS screen + home shortcut · dynamic FAQ/About/Contact + feedback ·
asset/wheelchair stations/search/book/release/track/report · staff request ·
route history/rating/share contract fixes · Info cleanup with
pharmacy/canteen/parking as map POI metadata · REST force-logout for token
rejection including `3009 accountLoggedInElsewhere`.

Generated `VersionCheckResponse` files are committed after the branch rebase
(`53cc0f4`), and `flutter analyze` was clean after conflict resolution.

### P0 — Correctness, then demo-ready
| # | Item | Area | Effort | Notes / acceptance |
|---|------|------|--------|--------------------|
| 1 | **Push sender + notification triggers** | BE | L | Send via FCM/APNs and fire on real events (queue ready, appointment, prescription, SOS). Until this lands, notifications are seed-only. Unlocks SOS/queue/staff alerts. |
| 2 | **Chat WebSocket force-logout path** | FE | S | REST token rejection is handled globally, but WS validation can still return HTTP 401 / code `3009` outside Dio. Wire it to `SessionManager` and redirect to `/login`. |
| 3 | **Fix Flow API contract mismatches** | FE+BE | S | `flow/edge_status` (app sends no required param + expects a list, backend wants a param + returns one) and `flow/get_density` (missing param, single vs list). Detail in `doc/overview_system.md`. |
| 4 | **auth/logout (server) + auth/resend_otp route** | BE | S | logout is local-only; `resend_otp` service exists but has no route. Single-active-JWT REST rejection is already handled. |
| 5 | **Pre-demo QA pass** | FE | S | `dart format`, `flutter analyze`, `flutter test`; manually walk auth / map / medical / notification / settings / chat / SOS / asset / staff flows. |
| 6 | **Demo prep** | — | S | seeded test account, backend URL/config, short demo script with an offline fallback. |

### P1 — High-value patient features
| # | Item | Area | Effort | Notes / acceptance |
|---|------|------|--------|--------------------|
| 7 | **Active route guidance** | FE+BE | L | `route/get_steps`, `get_next`, `get_eta`, `pass_node`, `cancel` — turn the simulated dot into backend-synced live guidance. |
| 8 | **Home dashboard enrichment** | FE | M | Add useful live summaries for active route, assets/wheelchairs, chat/support, and SOS status. Task, notification, weather, map, and SOS entry points already exist. |
| 9 | **Chat product gaps** | FE+BE | M | Add create-room UI, scroll-to-top pagination trigger, bottom-nav unread badge via `getUnreadCount`, connection status UI, and optional leave/delete room. Attachments/typing indicators remain later scope. |
| 10 | **Medical QR check-in/out** | FE | M | Camera scan + treatment/room validation on top of the existing check-in/out APIs. |
| 11 | **SOS escalation polish** | FE+BE | M | SOS screen and APIs are wired; add backend notification/escalation behavior and demo-ready status copy once #1 exists. |

### P2 — Later
| # | Item | Area | Effort | Notes |
|---|------|------|--------|-------|
| 12 | **Multi-stop navigation UI** | FE | M | repo wrappers exist for `order_multi`/`order_unordered`; needs a destination-picker flow. |
| 13 | **Route sharing/rating UI polish** | FE | S | Repository/router hooks exist; confirm discoverability and result-state handling in the Map flow. |
| 14 | **Voice guidance wiring** | FE | S | `voice_service.dart` exists with no navigation call sites — wire spoken prompts into simulated/live guidance. |
| 15 | **Chat attachments + typing indicators** | FE+BE | M | Image/file send exists in tests/repo paths only where supported; add UI and backend/WebSocket typing contract if needed. |
| 16 | **Utility POI metadata completeness** | FE+BE | S | Pharmacy/canteen/parking are map POIs now. Confirm backend `map/get_nodes` includes `open_hours`, `details`, `capacity`, `is_accessible`, and `wheelchair_accessible` for all relevant POIs. WiFi is intentionally not a navigable POI unless backend adds it to nodes. |

### Cross-cutting / tech debt
- [ ] **Restore voice-guidance + travel-mode** settings toggles once BE exposes those columns in `get/set_settings`.
- [x] **Real app version** in Settings — Settings + About now read the installed package version via `PackageInfo.fromPlatform()` (was static `1.0.0`).
- [x] **Removed dead mock-credentials file** (`mock_auth_credentials.dart`, `password='secret123'` + fake JWT) — 0 references anywhere.
- [x] **Pruned dead endpoint constants + repository getters** in `api_endpoints.dart` / `map_repository.dart` (superseded by the offline `syncFull` bundle; kept the ones reserved for Phase 1/2 wiring).
- [x] **Stopped silently swallowing errors** in the 3 empty `catch (_) {}` blocks (chat WebSocket + provider) — now `debugPrint`.
- [ ] **Tests** for settings, home, medical, SOS, asset, staff, and remaining chat UI flows; expand auth (repo errors, router redirects, widget flows). Notification/chat/map provider coverage already exists.
- [ ] **Backend `getEdges` perf** (~17s) — biggest map-load slowdown.
- [ ] Profile update success/error toast feedback.
- [ ] Map verify-only: non-walking `speed_factor`, meters-per-cell label truthfulness.

> The full FE↔BE API contract map (responses, requests, and backend mismatches)
> is in [`doc/overview_system.md`](doc/overview_system.md); per-module feature
> progress is in [`doc/overview_process.md`](doc/overview_process.md).

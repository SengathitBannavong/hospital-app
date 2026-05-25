# User Feature Progress Overview

This overview is from the mobile app user's point of view. It measures what a
patient/user can actually use in the Flutter app, not raw backend endpoint
coverage.

_Reflects `main` @ `f06aed8` (PR #29 merged: notifications + Info hub + home/nav
cleanup), 2026-05-25._ Bottom nav is now **4 tabs** — Home · Medical · Map ·
Profile; Notification, Info, FAQ, About, Contact are top-level pushed routes.

> **Pending PR (not yet in main):** `add-setting-page → main` adds a unified
> `/settings` page (theme/notification/language, backend-persisted) and the
> notification API contract fixes (without it, the notification list parses the
> wrong key and shows empty). See `context/branch-pr-status.md`.

Admin-only features are intentionally excluded from the table and from the
missing endpoint count:

- Admin Map
- Admin Logs
- Admin Device
- Admin Flow
- Admin Simulation
- Admin Engine

## Current Progress

| User feature module | Progress bar | What we have | What is missing | Missing user endpoints |
| --- | --- | --- | --- | --- |
| Authentication | `████████░░` 80% | Login, register, OTP verify, forgot password, reset password, change password, local logout. | Logout does not call backend; signup OTP resend has no backend route. | `POST /api/auth/logout` (local-only), `auth/resend_otp` (route missing) |
| Home | `███████░░░` 65% | Cleaned dashboard, real task count, unread notification **bell** badge, notification summary card, single "Thông tin" shortcut, pull-to-refresh, theme/settings + logout in app bar. | Utility, route-status, SOS, and asset quick actions; richer contextual summaries. | No direct missing endpoint for current home. |
| Profile | `███████▌░░` 75% | View/edit profile, avatar upload, delete account, **device-token registration** (`set_devtoken`), notification settings page. | Unified app-settings UI persistence (in the pending add-setting-page PR). | `GET /api/user/get_settings`, `POST /api/user/set_settings` (used by notification settings; full settings in pending PR) |
| Medical Tasks | `█████████░` 90% | View tasks, check in/out room, cancel task, sync now, history-backed task flow. | Deeper task status + result follow-up. | None from current medical list. |
| Queue | `████████░░` 80% | View queue status for a room/POI. | Broader queue browsing, stronger empty/error states. | None. |
| Prescription | `████████░░` 80% | View prescription data. | Prescription history/details. | None. |
| Notifications | `█████████▌` 95% | List + **pagination/load-more** + pull-to-refresh, mark read, mark all read, delete, **unread bell badge**, **notification settings page** (`get_settings`/`set_settings`), device token, **optional FCM push** (off by default). | Backend does not actually send pushes (stores tokens only, "Bucket B") and has no real notification triggers, so the list is seed-only in practice. List-display fix is in the pending PR. | None (device token now wired). |
| Indoor Map | `████████░░` 80% | Floor/map loading, grid rendering, POIs, local search, QR position set, offline cache, sync fallback. | Department/landmark browsing as user features; backend search as the normal path. | Optional/unused: `GET /api/map/get_depts`, `GET /api/map/get_landmarks` |
| Navigation | `███████░░░` 70% | Current position, route preview, route drawing, simulated moving dot, pause/resume/stop, route history, clear history, order-on-arrival log. | Real active-route lifecycle, backend route steps/next-step/pass-node sync, ETA, cancel/share/rate, dynamic modes. | `route/get_steps`, `route/get_next`, `route/get_active`, `POST route/get_eta`, `route/cancel`, `route/pass_node`, `route/share`, `route/rate` |
| Multi-stop Navigation | `██░░░░░░░░` 20% | Repository wrappers for ordered/unordered multi-stop calls. | No user flow for choosing multiple destinations or optimizing order. | UI for `POST route/order_multi`, `POST route/order_unordered` |
| Crowd / Flow Overlay | `██████░░░░` 60% | Heatmap, bottlenecks, forecast, alerts, obstacle reporting/display, crowd-aware local routing. | Point density view, edge-status overlay (request mismatch), location ping during nav, priority controls. | `flow/get_density` (param/shape mismatch), `flow/edge_status` (mismatch), `flow/ping_location`, `flow/set_priority`, `flow/expire_priority` |
| QR Scanner | `████████░░` 80% | Scan a QR and set current map position. | Robust payload formats, friendlier invalid-code handling. | None beyond current map search. |
| Info / FAQ / Utility | `█████░░░░░` 50% | **Info hub** linking static FAQ, Giới thiệu (About), and Liên hệ (Contact) pages. | Dynamic FAQ/about/contact, feedback, languages, pharmacy, canteen, parking, Wi-Fi, weather, upload. | `util/faq`, `util/about`, `util/contact`, `util/languages`, `util/check_version`, `util/pharmacy`, `util/canteen`, `util/parking`, `util/wifi`, `util/weather`, `util/feedback`, `util/feedback_summary`, `util/upload` |
| Asset / Wheelchair | `░░░░░░░░░░` 0% | Not available in the current app. | Asset stations, wheelchair finding, health, tracking, booking, release, broken-asset reporting. | `asset/asset_stations`, `asset/find_wheelchairs`, `asset/asset_health`, `asset/track_asset`, `asset/book_asset`, `asset/release_asset`, `asset/report_broken_asset` |
| Staff Request | `░░░░░░░░░░` 0% | Not available in the current app. | Request staff/help from the app. | `POST /api/staff/request_staff` |
| SOS | `░░░░░░░░░░` 0% | Not in the app (SOS screens exist on `feature/medical-sos-util`, waiting on backend). | Create SOS request and view own SOS detail. | `POST /api/sos/create`, `GET /api/sos/get_detail` |
| Chat | `░░░░░░░░░░` 0% | Not available in the current app (backend has `ws/chat`). | Chat rooms, messages, send, unread count, mark read, WebSocket updates. | `chat/create_room`, `chat/get_rooms`, `chat/get_messages`, `chat/send_message`, `chat/get_unread_count`, `chat/mark_read`, `ws/chat` |

## Summary

Overall user-facing progress is about `68%`.

The strongest completed areas are authentication, medical tasks, prescriptions,
**notifications (pagination + settings + optional push)**, profile basics with
device-token registration, indoor map, QR positioning, the **Info hub**, and
simulated navigation.

The biggest remaining gaps are SOS, chat, asset/wheelchair booking, staff
request, dynamic utility/info content, the unified settings page (pending PR),
deeper live navigation sync, and — critically on the backend — a real **push
sender + notification triggers** (without which notifications stay seed-only).
See `context/backend-tasks.md` and `context/overview_system.md`.

# User Feature Progress Overview

This overview is from the mobile app user's point of view. It measures what a
patient/user can actually use in the Flutter app, not raw backend endpoint
coverage.

_Reflects `main` @ `0952fa4`, 2026-06-03._ Bottom nav is **5 tabs** —
Home · Utilities (Medical) · Map · Chat · Profile — with swipe-to-switch between
tabs. Notification, Info, FAQ, About, Contact, SOS, Settings, Feedback, and
individual chat rooms are pushed routes.

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
| Authentication | `████████▌░` 85% | Login, register, OTP verify, forgot password, reset password, change password, **logout now calls `POST /api/auth/logout`** (deactivates this device's FCM token server-side; forced/session-rejected and post-delete logouts skip the call and clear locally), fixed signup/forgot-password OTP handoff. | Signup OTP resend still depends on a backend route. | `auth/resend_otp` (route missing) |
| Home | `████████▌░` 85% | Map-first dashboard, real task count, unread notification **bell** badge, notification summary card, **6-shortcut quick-access grid** (queue, find wheelchair, staff, prescription, obstacle report, SOS), **weather summary card**, **startup app-update check**, pull-to-refresh, settings + logout menu. | Richer contextual summaries (active route, asset/SOS status). | No direct missing endpoint for current home. |
| Profile | `████████▌░` 85% | View/edit profile, avatar upload with normalized media URLs, **device-token registration** (`set_devtoken`), `/settings` entry, **"Đánh giá ứng dụng" entry to feedback form**, **red logout button**. Delete-account now lives under **Settings → Tài khoản** (red tile, confirm + password flow) rather than on the profile screen. | Profile-specific polish and richer account metadata. | None for current profile/settings flow. |
| Medical Tasks | `█████████░` 90% | View tasks, **per-task detail page** with check in/out room, result status, cancel; sync now; history-backed task flow; utility action grid. | Deeper task status + result follow-up. | None from current medical list. |
| Queue | `████████░░` 80% | View queue status for a room/POI, picked via the shared **location picker** (`PoiPickerField`) instead of a typed code. | Broader queue browsing, stronger empty/error states. | None. |
| Prescription | `████████░░` 80% | View prescription data. | Prescription history/details. | None. |
| Notifications | `█████████▌` 95% | List + **pagination/load-more** + pull-to-refresh, mark read, mark all read, delete, **unread bell badge**, **60s polling fallback** (surfaces new items + read-state without manual refresh, since there is no backend push/WS), unified `/settings` page (`get_settings`/`set_settings`), device token, **optional FCM push** (off by default, now genuinely optional — lazy `FirebaseMessaging` so disabled builds never touch Firebase), provider/page tests. | Backend does not actually send pushes (stores tokens only, "Bucket B") and has no real notification triggers, so the list is seed-only in practice; polling masks the missing push within ~60s. | None (device token now wired). |
| Indoor Map | `████████░░` 80% | Floor/map loading, grid rendering, POIs, local search, QR position set, offline cache, sync fallback. | Department/landmark browsing as user features; backend search as the normal path. | Optional/unused: `GET /api/map/get_depts`, `GET /api/map/get_landmarks` |
| Navigation | `███████░░░` 70% | Current position, route preview, route drawing, simulated moving dot, pause/resume/stop, route history, clear history, order-on-arrival log. | Real active-route lifecycle, backend route steps/next-step/pass-node sync, ETA, cancel/share, dynamic modes. **`route/rate` has a complete `RouteRatingPage` + repo call wired but no navigation entry point — an orphan route, not reachable in any user flow.** | Not wired: `route/get_steps`, `route/get_next`, `route/get_active`, `POST route/get_eta`, `route/cancel`. Repo wrapper, no entry point: `route/pass_node`, `route/share`. Page + endpoint built but route unreachable: `route/rate`. |
| Multi-stop Navigation | `██░░░░░░░░` 20% | Repository wrappers for ordered/unordered multi-stop calls. | No user flow for choosing multiple destinations or optimizing order. | UI for `POST route/order_multi`, `POST route/order_unordered` |
| Crowd / Flow Overlay | `██████░░░░` 60% | Heatmap, bottlenecks, forecast, alerts, obstacle reporting/display, crowd-aware local routing. | Point density view, edge-status overlay (request mismatch), location ping during nav, priority controls. | `flow/get_density` (param/shape mismatch), `flow/edge_status` (mismatch), `flow/ping_location` (repo wrapper, no entry point), `flow/set_priority`, `flow/expire_priority` |
| QR Scanner | `████████░░` 80% | Scan a QR and set current map position. | Robust payload formats, friendlier invalid-code handling. | None beyond current map search. |
| Info / FAQ / Utility | `████████▌░` 85% | **Info hub** with dynamic FAQ/About/Contact via `util/*`, app update check, weather card, feedback form, and reusable upload support used by chat image messages. | Image attachments on feedback UI, broader language-source integration. | None for Info/Utility. `util/pharmacy`, `util/canteen`, `util/parking`, `util/wifi` are POI-list endpoints and belong in the **Map** module as POI categories. |
| Asset / Wheelchair | `████████░░` 80% | Asset stations, wheelchair finding (with shared location picker), health, tracking, booking, release, broken-asset reporting; reachable from the Home grid and Medical utility grid. | Live availability polish, richer tracking UX. | None (endpoints wired): `asset/asset_stations`, `asset/find_wheelchairs`, `asset/asset_health`, `asset/track_asset`, `asset/book_asset`, `asset/release_asset`, `asset/report_broken_asset` |
| Staff Request | `████████░░` 80% | Request staff/help via `staff/request_staff`, reachable from Home, the Medical grid, and a map-POI "Yêu cầu hỗ trợ" action (pre-filled with the selected POI). | Status/escalation feedback once backend triggers ship. | None (endpoint wired): `POST /api/staff/request_staff` |
| SOS | `████████░░` 80% | Dedicated `/sos` page reachable from Home red quick-action — confirm dialog → `POST sos/create`, then `GET sos/get_detail` with pull-to-refresh and status rendering. | Backend endpoints must be live for the flow to actually work end-to-end; richer post-send UX (cancel, resolved-by info). | None (endpoints already called: `POST /api/sos/create`, `GET /api/sos/get_detail`). |
| Chat | `███████░░░` 70% | 5th bottom-nav tab, room list, unread/activity badge, per-room message screen, WebSocket realtime path, reconnect catch-up, 25s message backstop poll, 60s room poll, text send, image send via `util/upload`, mark-read, tests. | Create-room UI, close-room UI, richer participant discovery, media preview polish, backend push/trigger alignment. | UI for `chat/create_room`, `chat/close_room`; `chat/get_unread_count` is not directly used because unread is derived from rooms. |

## Summary

Overall user-facing progress is about `82%`.

The strongest completed areas are authentication, medical tasks (now with a
per-task detail page), prescriptions, **notifications (pagination + settings +
60s polling fallback + optional push + tests)**, profile basics with
device-token registration, indoor
map, QR positioning, the **dynamic Info/Utility hub** (FAQ/About/Contact +
weather + app-update check + feedback), **SOS quick-send**, asset/wheelchair and
staff-request flows (now surfaced on the Home grid and via a shared location
picker), simulated navigation, and the first complete **Chat** surface.

The biggest remaining gaps are feedback image attachments, deeper chat room
creation/management, deeper live navigation sync, and — critically on the
backend — a real **push sender + notification triggers** (without which
notifications stay seed-only). See `context/backend-tasks.md` and
`context/overview_system.md`.

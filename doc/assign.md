# Contribution Assignment — `main` (45 commits)

_Updated 2026-06-03. HEAD `a8a67e7`. Ordered oldest → newest. "#" = PR number
(or short hash for direct commits). Co-contributors are from `Co-Authored-By`._

| # | Date (UTC+?) | Module | What it does (summary) | Main contributor | Co-contributor |
|---|---|---|---|---|---|
| `f744b0f` | 2026-04-07 17:09 | Project setup | Initialise project with clean architecture structure | Bannavong | — |
| #1 | 2026-04-07 23:24 | Core / Theme / Home | Custom theme system + initial home page UI | Bannavong | — |
| #2 | 2026-04-12 09:46 | Core | Global API client + Toast utility | Bannavong | — |
| #3 | 2026-04-12 09:54 | CI | Fix `flutter_ci.yaml` workflow | Bannavong | — |
| #5 | 2026-04-21 23:11 | Auth / Core / Home | New pages, dependencies, core functions | Samkol Meng Leang | — |
| #7 | 2026-04-23 09:27 | Auth | Sign-up flow | Vongphet Pasithphone | — |
| #8 | 2026-04-25 00:48 | Profile | Profile page with mock data | Soumek Xaynguyen (quangngv) | — |
| #9 | 2026-05-03 18:30 | Auth | Remove OTP from the login flow | Bannavong | — |
| #10 | 2026-05-04 10:48 | Auth | Show OTP on the OTP page | Bannavong | — |
| #11 | 2026-05-11 15:12 | Map | Upgrade to full indoor navigation system | Bannavong | — |
| `bb190b1` | 2026-05-11 15:23 | Docs / API | Add swagger from backend team | Bannavong | — |
| #12 | 2026-05-12 14:40 | Map | Add indoor navigation map feature (preview) | Bannavong | — |
| #13 | 2026-05-12 22:24 | Medical | Medical services: queue + prescription | Bannavong | — |
| #14 | 2026-05-14 16:45 | Map | Map feature work | Bannavong | — |
| #15 | 2026-05-14 17:29 | Chore / Docs | Add docs, retire unused files | Bannavong | — |
| #16 | 2026-05-18 22:27 | Docs | Update swagger.yaml + PROJECT.md checklist | Bannavong | — |
| #17 | 2026-05-19 12:10 | UI / Core | Add async handling + new UI | Vongphet Pasithphone | bannavong |
| #18 | 2026-05-19 17:46 | Notification | Notification feature UI | Kimheng99 | — |
| #20 | 2026-05-20 15:10 | Docs / API | Update swagger from backend team | Bannavong | — |
| #21 | 2026-05-20 20:45 | Map / Navigation | Indoor "You are here" simulated navigation + backlog scope | Bannavong | — |
| #22 | 2026-05-22 13:16 | Auth | Auth module work | Vongphet Pasithphone | — |
| #23 | 2026-05-22 16:15 | CI / Docs | Firebase Hosting deploy workflow for docs-site | Bannavong | — |
| #24 | 2026-05-22 18:13 | Docs | Update docs | Bannavong | — |
| #25 | 2026-05-22 18:56 | Auth | Fix reset-password flow | Vongphet Pasithiphone | Bannavong |
| #26 | 2026-05-24 13:36 | Map / Route / Flow | Offline-first indoor navigation, crowd-aware routing, flow analytics | Bannavong | — |
| #27 | 2026-05-24 15:48 | Map | Fix map bug | Bannavong | — |
| #29 | 2026-05-25 14:55 | Notification / Home / Nav | Notifications (pagination + optional push + settings + bell), Info hub, home cleanup, 4-tab nav | kimheng99 | Vongphet Pasithiphone, Bannavong |
| #31 | 2026-05-25 16:58 | Settings / Notification | Unified Settings page (theme/notification/language, backend-persisted) + notification API contract fixes | Soumek Xaynguyen (quangngv) | Bannavong |
| #32 | 2026-05-25 18:56 | Docs | PROJECT.md current-state summary + prioritised backlog; move overview docs to `doc/` | Bannavong | — |
| #30 | 2026-05-26 12:36 | SOS / Home / Core | SOS screen (`POST sos/create`, `GET sos/get_detail`) + red Home quick-action; restored forgot-password flow; dropped dead util scaffolding; gated macOS token fallback behind `kDebugMode`; removed unused `google_fonts`. | Samkol Meng Leang | Bannavong |
| #37 | 2026-05-26 14:06 | Util / Info / Home / Profile | Dynamic FAQ/About/Contact via `util/*`; startup app-update check (`util/check_version`); Home weather card (`util/weather`); Feedback page reachable from Profile (`util/feedback` + `util/feedback_summary`); consolidated duplicate version-check path. | Punleu-Oun | Bannavong |
| #41 | 2026-05-26 | Docs | Update documentation website and assignment docs | Bannavong | — |
| #42 | 2026-05-26 | CI / iOS | Add iOS build workflow work | Bannavong | — |
| #43 | 2026-05-26 | CI / iOS | Update iOS build workflow | Bannavong | — |
| `43e5f81` | 2026-05-26 | CI / iOS | Fix archive upload for unsigned iOS builds | Bannavong | — |
| `79b5f9b` | 2026-05-26 | CI / iOS | Update workflow to retrieve app IPA artifacts correctly | Bannavong | — |
| #44 | 2026-05-26 | UI / Home / Map / SOS / CI | Responsive UI pass, accessibility/role tokens, map-first Home, collapsible map overlays, iOS release CI | Bannavong | — |
| #46 | 2026-05-27 | Auth / Profile | Fix signup and forgot-password OTP flow; normalize profile avatar media URLs | Bannavong | — |
| #45 | 2026-05-31 | Chat | Add chat rooms, per-room WebSocket messages, image sending via upload, unread/activity badges, lifecycle polling, and tests | Soumek Xaynguyen (quanghot31lao) | — |
| #48 | 2026-05-31 | Notification / Tests | Add notification provider and page tests; minor profile/map cache cleanup | Vongphet Pasithphone | — |
| `12a085b` | 2026-05-31 | Docs | Update document files; add chat documentation | Bannavong | — |
| #49 | 2026-06-02 | Util / Info | Implement FAQ and hospital utility screens | Kimheng99 | — |
| #50 | 2026-06-03 | Profile | Fix date-of-birth validation on the profile form | Vongphet Pasithphone | — |
| #51 | 2026-06-03 | Home / Medical / Map / Nav | Optimize patient-facing pages: 6-shortcut Home grid, swipe-to-switch nav + "Utilities" relabel, shared POI picker, dedicated `TaskDetailPage`, map declutter | Bannavong | — |

## Contributor summary

| Person | Lead commits | Also co-contributed |
|---|---|---|
| **Bannavong** (bannavong.sa239717) | 30 — core, theme, CI, map, route, flow, medical, docs, responsive UI, auth/profile fixes, patient-facing optimization (#51) | #17, #25, #29, #31, #30, #37 |
| **Vongphet Pasithphone** (pasithphone.v220116) | 6 — auth (#7, #22), async/UI (#17), reset-password (#25), notification tests (#48), dob validation fix (#50) | #29 |
| **Kimheng99** (nutkimheng000) | 3 — notification UI (#18), notifications/info/nav (#29), FAQ/utility screens (#49) | — |
| **Soumek Xaynguyen** (aka quangngv / quanghot31lao) | 3 — profile page (#8), unified Settings page (#31), chat (#45) | — |
| **Samkol Meng Leang** (CodeLeang) | 2 — auth/core/home pages (#5), SOS + home utility shortcuts (#30) | — |
| **Punleu-Oun** (ounpunleu7975) | 1 — util wiring: Info hub, Home, app update, feedback (#37) | — |

> **Reassignment rule applied:** on any commit where Bannavong was the merger but
> a teammate co-contributed, the teammate is credited as **main** and Bannavong
> moved to **co** — affects #25 (→ Vongphet), #29 (→ kimheng99, lead author of the
> kim-heng branch), #31 (→ Soumek Xaynguyen, who commits as `quangngv` — author of the settings branch),
> #30 (→ Samkol Meng Leang, who merged the SOS branch as `CodeLeang`), and #37
> (→ Punleu-Oun, who merged the util-wiring branch).
>
> Module labels are inferred from the commit subject + the files each PR touched.
> Co-contributors come from `Co-Authored-By` trailers on the squash/merge commits.

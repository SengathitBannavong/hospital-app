# Contribution Assignment — `main` (65 commits)

_Updated 2026-06-23. HEAD `cc62f99`. Ordered oldest → newest. "#" = PR number
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
| `01d23fe` | 2026-06-03 | Docs | Update overall documentation files | Bannavong | — |
| `30988f5` | 2026-06-03 | Auth / Notification / Profile / Settings / Docs | Backend logout (`POST auth/logout` deactivates device FCM token; forced/post-delete logouts skip it); lazy `FirebaseMessaging` so disabled builds are crash-free (Firebase genuinely optional); 60s notification polling fallback (no backend push yet); move delete-account to **Settings → Tài khoản** + red profile logout; reconcile `overview_process.md` | Bannavong | — |
| `369d1f5` | 2026-06-03 | Docs | Log `01d23fe` + `30988f5` (logout/FCM, notification polling) in the assignment doc | Bannavong | — |
| #54 | 2026-06-06 | Map / UI | Anchor expandable action menu to FAB left edge (real on-screen rect); tap-outside scrim, height-bounded list, drop phantom semantics when collapsed; replace deprecated `SizeTransition.axisAlignment`; page-slide fixes | Vongphet Pasithphone | — |
| #55 | 2026-06-08 | Map / Navigation | Edge-swipe page navigation; untrack generated `*.g.dart`/`*.freezed.dart` files | Vongphet Pasithphone | Bannavong |
| #56 | 2026-06-10 | Chore / Core | Phase 0 hygiene (FIX-01..04): read app version from `PackageInfo.fromPlatform()`, delete dead mock auth credentials, prune dead `ApiEndpoints`/`MapRepository` symbols, `debugPrint` in empty catch blocks | Bannavong | — |
| #57 | 2026-06-13 | Profile / Auth | Fix delete-account error handling + Vietnamese localization | Vongphet Pasithphone | — |
| #58 | 2026-06-13 | Map / Voice | Offline turn-by-turn Vietnamese voice guidance: bundle 8 nav voice clips as assets, pre-warmed AudioPlayer pool + sequential queue, `flutter_tts` fallback, turn-by-turn decider, mute toggle + ×0.5/×1/×2 speed | Bannavong | — |
| `cc269ab` | 2026-06-13 | Map | Merge the route pill's two close buttons into one (inner × now hides/collapses) | Bannavong | — |
| `a221331` | 2026-06-13 | Map / Voice | Stop voice from firing on destination change and cancel (guard `_setProgress` to navigating phase; drop cues queued before `stop()` via a generation counter) | Bannavong | — |
| `3921912` | 2026-06-13 | Profile | Add clear-avatar action (send `avatar: ""` so a clear reaches the backend; "Xóa ảnh đại diện" picker entry + confirm dialog) | Bannavong | — |
| #59 | 2026-06-13 | Map / Route / Auth | Wire backend route lifecycle (`route/order`→`route_id`, `cancel`, `pass_node` every 2s, `rate` with `is_accurate`) as telemetry+rating while the client A* engine stays routing authority; reachable rating page; shared `authLinkButtonStyle` helper (`inherit: false`, survives route transitions) | Bannavong | — |
| #60 | 2026-06-14 | Asset / Core | Make Asset/Wheelchair flow usable end-to-end: shared code→Vietnamese error map (backend returns `message:"OK"` on errors), station-picker release sending `station_name`, local active-booking tracking + "Xe lăn của tôi" heuristic recovery, Home active-booking card + "Trạm thiết bị" shortcut, "Tìm xe lăn gần đây" on accessible map POIs; gap/`my_booking` docs into tracked `doc/` | Bannavong | — |
| `bb0e8b6` | 2026-06-14 | Docs | Refresh `assign.md` (log #60) | Bannavong | — |
| #61 | 2026-06-15 | Core / i18n | English/Vietnamese language switching foundation: `LocaleController` (persisted, system-locale fallback), `gen-l10n`/ARB pipeline wiring (`l10n.yaml`, app router, initializer), localized API error messages + interceptor/services | Soumek Xaynguyen (quanghot31lao) | quangngv |
| #62 | 2026-06-15 | Map / i18n / CI | Localize the map module end-to-end (~110 ARB keys via `context.l10n`/`appL10n`); fix two longer-Vietnamese-label layout bugs (extended-FAB `StadiumBorder`, analytics-row `Expanded`); gitignore generated `app_localizations*.dart` and add a `flutter gen-l10n` step to CI + `pre_commit.sh` | Bannavong | — |
| #63 | 2026-06-17 | Asset / Map | Wire 3 new backend endpoints: map search history (`map/save_search` + `get_search_history` "Recent searches" + `clear_search_history`) and authoritative `asset/my_booking` (heuristic demoted to offline fallback); fix release station-picker stuck spinner (wrap modal body in `Consumer`) | Bannavong | — |
| #64 | 2026-06-23 | Notification / Settings | On-device **test notification**: `showTestNotification()` shows a local notification offline/online (independent of Firebase) + secure-storage FCM token cache (`getSavedToken`), Android 13+ `POST_NOTIFICATIONS` request; Settings "Gửi thông báo thử" tile also drops a matching in-app entry; restore the accidentally-deleted `flutter_ci.yml` quality gate | Soumek Xaynguyen (quanghot31lao) | quangngv |
| #65 | 2026-06-23 | Map / Perf | Render large floors (300×500 = 150k cells) from a pre-baked bundled PNG base (`assets/map/{id}.png`, `map_asset_registry.dart`) drawn once via `drawImageRect`; split `MapGridPainter` into `MapStaticPainter` (base+POIs, own `RepaintBoundary`) and `MapDynamicPainter` (route+dot, only per-frame layer); `walkableRunsProvider` collapses cells into per-row runs for the fallback renderer; `tool/render_map_png.dart` rasterizer | Bannavong | — |
| #66 | 2026-06-23 | Auth / Home / Medical | Enforce a strong-password policy (≥8 chars w/ upper, lower, digit, symbol via shared `FormValidators.isStrongPassword`) across register/reset/change-password (was 6-char); wire the Home appointments card to `/medical` (was a no-op refetch); patient-friendly copy ("My appointments / Lịch khám của tôi", "{n} upcoming") in en/vi | Bannavong | — |

## Contributor summary

| Person | Lead commits | Also co-contributed |
|---|---|---|
| **Bannavong** (bannavong.sa239717) | 44 — core, theme, CI, map, route, flow, medical, docs, responsive UI, auth/profile fixes, patient-facing optimization (#51), backend-logout/FCM lifecycle (`30988f5`), Phase 0 hygiene (#56), offline voice guidance (#58) + voice/route-pill fixes, clear-avatar (`3921912`), backend route lifecycle (#59), Asset/Wheelchair end-to-end (#60), map i18n + layout fixes (#62), search-history/my_booking wiring (#63), map render perf (#65), strong-password/appointments copy (#66) | #17, #25, #29, #31, #30, #37, #55 |
| **Vongphet Pasithphone** (pasithphone.v220116) | 9 — auth (#7, #22), async/UI (#17), reset-password (#25), notification tests (#48), dob validation fix (#50), map action-menu/page-slide (#54), edge-swipe nav (#55), delete-account fix (#57) | #29 |
| **Kimheng99** (nutkimheng000) | 3 — notification UI (#18), notifications/info/nav (#29), FAQ/utility screens (#49) | — |
| **Soumek Xaynguyen** (aka quangngv / quanghot31lao) | 5 — profile page (#8), unified Settings page (#31), chat (#45), i18n language-switch foundation (#61), test notification (#64) | — |
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

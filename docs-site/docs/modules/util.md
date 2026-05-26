---
id: util
title: Util Module
sidebar_position: 9
---

# Util Module

The **Util Module** (`lib/features/util`) wires the app to the backend's
`util/*` family of endpoints. It powers the dynamic Info hub (FAQ / About /
Contact), the Home weather card, the startup app-update check, and the
Feedback page.

:::info[Single source of truth]
All calls flow through the shared `ApiClient.instance` — same base URL as the
rest of the app. No alternate host, no raw `Dio()` instances.
:::

## Endpoints in use

| Method | Endpoint | Auth | Consumer |
| :--- | :--- | :--- | :--- |
| `GET` | `util/about` | No | About page |
| `GET` | `util/contact` | No | Contact page |
| `GET` | `util/faq` | No | FAQ page (optional `?category=`) |
| `GET` | `util/weather` | No | Home weather card |
| `GET` | `util/check_version` | No | Startup update prompt (`?platform=&code=`) |
| `GET` | `util/feedback_summary` | No | Feedback page header card |
| `POST` | `util/feedback` | **Yes** | Feedback submit (`rating`, `comment`, `images`-as-JSON-string) |

:::caution[Backend quirk — `images` is a stringified array]
`POST util/feedback` expects `images` as a JSON-**encoded string** (e.g. the
literal `"[]"`) rather than a real JSON array. The repository wraps it with
`jsonEncode(images)` before POSTing — sending a real array returns
"request body invalid".
:::

### Out-of-scope endpoints
- `util/pharmacy`, `util/canteen`, `util/parking`, `util/wifi` — POI-list
  endpoints, will land as filters in the [Map Module](./map).
- `util/languages` — feeds the Settings language picker; deferred until the
  language work is taken up there.
- `util/upload` — deferred until the feedback page actually attaches images.

## State Management

| Provider | Type | Backing call |
| :--- | :--- | :--- |
| `utilRepositoryProvider` | `Provider<UtilRepository>` | constructs the repository |
| `aboutProvider` | `FutureProvider<AboutInfo>` | `util/about` |
| `contactProvider` | `FutureProvider<ContactInfo>` | `util/contact` |
| `faqProvider(category)` | `FutureProvider.family<List<FaqItem>, String?>` | `util/faq[?category=]` |
| `weatherProvider` | `FutureProvider<Weather>` | `util/weather` |
| `feedbackSummaryProvider` | `FutureProvider<FeedbackSummary>` | `util/feedback_summary` |

All pages that consume these providers wrap them in
`AsyncValue.when(loading, error, data)`. Errors surface a small "Thử lại"
retry button (Info hub) or hide the card silently (Home weather).

## Repository contract

`UtilRepository` returns typed freezed models — no `_firstString` key-guessing
of response keys. Special parsing notes:

- **`Weather.descriptions`** — the backend returns a list of `{value: "..."}`
  objects; the model parses to `List<String>` via a `fromJson` adapter, with
  a comment in the code documenting the actual shape.
- **`UtilVersionCheck.changeLog`** / **`downloadUrl`** — used by the
  `version_gate` service (see Home module).

## Feedback Page

The Feedback page (`/feedback`) is the user-facing surface of `util/feedback`
and `util/feedback_summary`. Entry point: Profile → "Đánh giá ứng dụng".

```text
📦 FeedbackPage
├── 🧭 AppBar ("Đánh giá ứng dụng")
└── 📜 SingleChildScrollView
    ├── 📇 Summary card ("Đã có N đánh giá • X.X★" from feedback_summary)
    └── 📇 Form card
        ├── ⭐ 1–5 star Row (IconButton-based selector)
        ├── 📝 TextField (góp ý, multiline)
        └── 🖼️ "Chọn ảnh (Sắp ra mắt)" OutlinedButton — disabled with Tooltip
            (Tính năng đính kèm ảnh sẽ sớm có mặt)
    └── 🔘 FilledButton "Gửi đánh giá" → POST util/feedback
```

After a successful submit the page invalidates `feedbackSummaryProvider`,
toasts "Cảm ơn bạn đã đánh giá!" and pops.

## App update check (`version_gate.dart`)

`lib/core/services/version_gate.dart` exposes a single function
`checkAndPrompt(context)` invoked from the Home page's post-frame callback.
It:

1. Reads the current build via `PackageInfo.fromPlatform()`.
2. Calls `util/check_version?platform=android|ios&code=<buildNumber>`.
3. If `status == 'update_available'` and the same `latest_version` was not
   already shown within the last 24h (tracked in a Hive `util` box), shows a
   dismissible `AlertDialog`. The "Cập nhật" action opens `download_url`
   externally via `url_launcher`.

The legacy `sys/check_version` path (`VersionCheckWidget`,
`VersionCheckService`, `auth_repository.checkVersion`) was removed when this
module landed, so there is now a single canonical update flow.

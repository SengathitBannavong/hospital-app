---
id: settings
title: Settings Module
sidebar_position: 8
---

# Settings Module

The **Settings Module** (`lib/features/settings`) is a single, backend-wired
preferences page. It was consolidated from earlier per-feature settings: there is
now **one** `/settings` page, reached from the gear icon in the **Home**,
**Profile**, and **Notification** app bars (the old `notification_settings_page`
was removed).

## State Management

| Source | Description |
| :--- | :--- |
| **`notificationSettingsProvider`** | Loads (`user/get_settings`) and saves (`user/set_settings`) the user's preferences as an `AsyncValue`. Single source of truth for the page. |
| **`themeController`** | Global `ChangeNotifier` that applies the theme live; kept in sync with the persisted `theme` value. |

Persisted fields (backend `UserSetting`): `notification` (on/off), `language`
(vi/en), `theme` (light/system/dark). Each change calls `saveSettings(...)` with
a partial update.

> Voice-guidance and travel-mode exist in the backend DB but are **not** exposed
> by `get/set_settings`, so they are intentionally absent from the UI.

## Sections

```text
📦 SettingsPage (/settings)  — settingsAsync.when(loading / error / data)
├── 👤 Tài khoản    → Change password (/change-password) · Logout (confirm dialog)
├── 🎨 Giao diện    → Theme SegmentedButton (Light / System / Dark)  [persisted]
├── 🔔 Thông báo    → Enable notifications switch                    [persisted]
│   └── 🧪 "Gửi thông báo thử" → showTestNotification() (local, offline-capable)
├── 🌐 Ngôn ngữ     → Language dropdown (vi / en)                    [persisted]
└── ℹ️  Thông tin   → Help (/help) · About dialog · Version (1.0.0)
```

## Theme persistence & restore

- On change: `themeController.setThemeMode(mode)` (instant) **and**
  `saveSettings(theme: ...)` (server-side).
- On app launch / login: `AppInitializer` loads settings once and applies the
  saved `theme` so the choice survives restarts — persistence is server-side, not
  local `SharedPreferences`.

## Test notification
- The **Thông báo** section includes a "Gửi thông báo thử" tile that fires a
  local notification via `FirebaseNotificationService.showTestNotification()`.
  Local notifications are on-device, so it works **offline** and **without
  Firebase** (`ENABLE_FIREBASE` may be off); it also drops a matching entry into
  the in-app notification list and toasts success/failure.

## Notes
- The page requires authentication + network (it is backend-backed); it is only
  reached from post-login screens.
- "Version" is currently a static `1.0.0` (not yet from `sys/check_version`).

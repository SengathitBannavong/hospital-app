---
id: sos
title: SOS Module
sidebar_position: 8
---

# SOS Module

The **SOS Module** (`lib/features/sos`) lets a patient raise an emergency
request from inside the app with a single confirm-and-send flow.

:::warning[Backend-dependent]
The frontend is complete (page, repository, provider, route, Home shortcut).
The full end-to-end experience depends on the backend `sos/create` and
`sos/get_detail` endpoints being live and on a staff/dispatch workflow being
wired on the backend side.
:::

## Entry Points

- **Home quick-action card** — a red `_QuickActionCard` labelled "SOS" with the
  `Icons.emergency_rounded` glyph pushes `/sos`.
- **Direct route** — `/sos` is a top-level pushed route (not a bottom-nav
  branch), so the back arrow returns to wherever the user came from.

## State Management

| Provider | Description |
| :--- | :--- |
| **`sosRepositoryProvider`** | Constructs the `SosRepository` once per app. |
| **`sosProvider`** (`StateNotifierProvider<SosNotifier, SosState>`) | Holds `detail`, `isLoading`, `isSending`, `errorMessage`, `successMessage`. Computed `hasActiveSos` derives from `detail.status == SosStatus.active`. |

## Repository

`SosRepository` uses the shared `ApiClient.instance` (same base URL as the rest
of the app) and exposes two methods:

| Method | Endpoint | Auth | Purpose |
| :--- | :--- | :--- | :--- |
| `createSos()` | `POST sos/create` | Yes | Raise an SOS request. |
| `getSosDetail()` | `GET sos/get_detail` | Yes | Fetch the user's own active/last SOS. |

The detail parser is tolerant: it accepts both `sos_id`/`id` and
`created_at`/`time` field aliases on the backend payload.

## Widget Types & Patterns

```text
📦 SosPage
├── 🧭 AppBar ("SOS — Khẩn Cấp") + refresh action / loading spinner
├── 🔄 RefreshIndicator → sosProvider.notifier.loadDetail()
└── 📜 SingleChildScrollView
    ├── 🚨 Big red "Gửi tín hiệu SOS" FilledButton
    │   └── opens AlertDialog confirm ("Xác nhận SOS / Hủy / Gửi SOS")
    └── 📇 Card: current SOS status
        └── status, created_at, resolved_at, optional note
```

The confirm dialog prevents accidental taps. On success the page invalidates
its own detail and shows a green toast; on failure it surfaces the server
message via the shared `AppToast`.

## State Taxonomy

- **Server State**: `SosDetail` returned from `GET sos/get_detail`, held in `SosState.detail`.
- **Local UI State**: `isLoading` (refresh), `isSending` (post-create transient).
- **Transient Feedback**: `successMessage` / `errorMessage` are read once by the page and cleared via `clearMessages()`.

## The Execution Lifecycle (Sending an SOS)

### 1. 💻 Tap the red button (UI Layer)
The user opens `/sos` from the Home quick action, taps "Gửi tín hiệu SOS",
and confirms in the dialog.

### 2. 🛡️ Confirm guard
The page does not call the API unless the user explicitly confirms.

### 3. 🌐 Execution (Repository Layer)
```dart
await ref.read(sosProvider.notifier).sendSos();
// internally: SosRepository.createSos() then getSosDetail()
```

### 4. 🔄 Reactivity (UI Layer)
On success the notifier sets `successMessage` and a fresh `SosDetail`; the
page surfaces a toast and the status card re-renders with the active status.
On failure the notifier sets `errorMessage` and the page toasts that instead.

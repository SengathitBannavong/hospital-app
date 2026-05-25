---
id: notification
title: Notification Module
sidebar_position: 5
---

# Notification Module

The **Notification Module** (`lib/features/notification`) functions as a unified inbox, surfacing critical system alerts, appointment reminders, and medical updates directly to the user.

## State Management

Notification state is managed by `notification_provider.dart`.

| Provider | Description |
| :--- | :--- |
| **`notificationProvider`** | Manages the `AppNotification` list, page/total/limit pagination state, and derives the unread badge count and loading flags. |
| **`unreadCountProvider`** | Exposes the derived unread count for the Home app-bar bell and other badges. |
| **`notificationSettingsProvider`** | Loads/saves notification preferences via `user/get_settings` and `user/set_settings`. |

## Widget Types & Patterns

The Notification module relies on a continuous, paginated scrollable list.

```text
📦 NotificationPage  (top-level pushed route, with back button)
├── 🧭 AppBar (unread badge · "mark all read" · settings)
├── 🔄 RefreshIndicator (pull-to-refresh)
└── 📜 ListView.builder (infinite scroll → loadMore)
    ├── 📇 NotificationCard
    │   ├── 🔤 Title & Message
    │   ├── 🕒 created_at timestamp
    │   ├── 🔵 Read/unread leading avatar
    │   └── 🗑️ Delete IconButton
    └── ⏳ Footer (spinner / "Đã tải hết thông báo")
```

:::note[Delete & Pagination]
Each `NotificationCard` exposes an explicit delete button (not swipe). The list
pages via `loadMore()` when the scroll nears the bottom, dedupes items by `id`,
and supports pull-to-refresh.
:::

## Push Notifications (optional)

Firebase Cloud Messaging is wired on the client (`FirebaseNotificationService`)
but **disabled by default** behind the `ENABLE_FIREBASE` dart-define. When
enabled, it requests permission, registers the device token via
`user/set_devtoken` (sending `device_token` + `platform`), and prepends
foreground messages into the list. See `FIREBASE.md` at the repo root.

## State Taxonomy

- **Server State (Cached)**: `notificationProvider` holds the paginated list of notifications and handles the unread badge count. It is the primary source of truth.
- **Transient UI State**: A `ScrollController` drives infinite scroll (triggering `loadMore()` near the bottom); `RefreshIndicator` drives pull-to-refresh.

## The Execution Lifecycle (Optimistic Deletion)

import NotificationFlowDiagram from '@site/static/img/diagrams/notification-flow.svg';

<div style={{ textAlign: 'center', margin: '2rem 0' }}>
  <NotificationFlowDiagram width="100%" style={{ borderRadius: '16px', boxShadow: '0 4px 20px rgba(0,0,0,0.15)' }} />
</div>

The Notification module heavily employs optimistic UI updates to ensure the interface feels snappy.

### 1. 💻 Trigger (UI Layer)
The user taps the delete button on a `NotificationCard`, which calls the notifier.
```dart
onDelete: () => ref
    .read(notificationProvider.notifier)
    .deleteNotifications([item.id]),
```

### 2. 🌐 Execution (Repository Layer)
The notifier calls the repository (via the remote data source) to delete on the server first.
```dart
await _repository.deleteNotifications(notificationIds: ids);
```

### 3. ⚡ State Update (Provider Layer)
On success, the removed items are filtered out of `state.items` and `total` is decremented.
```dart
state = state.copyWith(
  items: state.items.where((item) => !ids.contains(item.id)).toList(),
  total: (state.total - ids.length).clamp(0, state.total).toInt(),
);
```

### 4. 🛡️ Error handling (UI)
If the request throws, the page shows a toast and the list is left unchanged.
```dart
} catch (error) {
  AppToast.showError(_formatError(error));
}
```

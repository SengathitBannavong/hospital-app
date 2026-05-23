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
| **`notificationProvider`** | Manages the list of notifications, the unread badge count, and handles cursor-based pagination state for infinite scrolling. |

## Widget Types & Patterns

The Notification module relies on a continuous scrollable list capable of handling interactive gestures.

```text
📦 NotificationListPage
├── 🔄 RefreshIndicator
└── 📜 ListView.separated
    └── 👆 Dismissible (Swipe to delete)
        └── 📇 NotificationTile
            ├── 🔤 Title & Subtitle
            ├── 🕒 Timestamp
            └── 🔴 Unread Indicator Dot
```

:::note[Swipe-to-Delete Implementation]
The module utilizes Flutter's native `Dismissible` widget on each `NotificationTile`, allowing users to intuitively swipe away read messages.
:::

## State Taxonomy

- **Server State (Cached)**: `notificationProvider` holds the paginated list of notifications and handles the unread badge count. It is the primary source of truth.
- **Transient UI State**: The `Dismissible` widget manages internal swipe offsets during the swipe animation before triggering the provider.

## The Execution Lifecycle (Optimistic Deletion)

import NotificationFlowDiagram from '@site/static/img/diagrams/notification-flow.svg';

<div style={{ textAlign: 'center', margin: '2rem 0' }}>
  <NotificationFlowDiagram width="100%" style={{ borderRadius: '16px', boxShadow: '0 4px 20px rgba(0,0,0,0.15)' }} />
</div>

The Notification module heavily employs optimistic UI updates to ensure the interface feels snappy.

### 1. 💻 Trigger (UI Layer)
The user intuitively swipes away a `NotificationTile`. The native `Dismissible` widget captures the gesture and triggers the `onDismissed` callback.
```dart
onDismissed: (direction) {
  ref.read(notificationProvider.notifier).deleteNotification(notification.id);
}
```

### 2. ⚡ Optimism (Provider Layer)
Before any network request is fired, the `notificationProvider` immediately filters the notification out of its local state array. The UI re-renders instantly.
```dart
// Inside NotificationNotifier
final previousState = state;
state = AsyncData(state.value!.where((n) => n.id != id).toList());
```

### 3. 🌐 Execution (Repository Layer)
The provider then triggers the actual HTTP DELETE request in the background.
```dart
await dioClient.delete('/notification/$id');
```

### 4. 🛡️ Fallback (Provider & UI)
If the backend throws an error (e.g., no internet connection), the provider catches the exception, restores the `previousState`, and alerts the user.
```dart
} catch (e) {
  state = previousState; // Restore the UI
  AppToast.showError('Failed to delete notification');
}
```

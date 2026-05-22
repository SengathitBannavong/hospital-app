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
| **`notificationRepositoryProvider`** | Exposes `NotificationRepository` to the feature. |
| **`notificationProvider`** | Loads the notification list as `AsyncValue<List<AppNotification>>` and exposes actions to fetch, mark read, mark all read, and delete. |

## Widget Types & Patterns

The Notification module relies on a continuous scrollable list capable of handling interactive gestures.

```text
📦 NotificationPage
├── 🔄 RefreshIndicator
└── 📜 ListView.separated
    └── 📇 NotificationCard
        ├── 🔤 Title & Message
        ├── 🔔 Read/Unread Icon
        └── 🗑️ Delete IconButton
```

:::note[Current Implementation]
The current UI uses an explicit delete button on each `NotificationCard`.
There is no cursor pagination or swipe-to-delete behavior in the current code.
:::

## State Taxonomy

- **Server State**: `notificationProvider` holds the loaded list and exposes it
  as `AsyncValue<List<AppNotification>>`.
- **Derived UI State**: `NotificationPage` derives the unread count from the
  loaded list.

## The Execution Lifecycle (Delete Notification)

import NotificationFlowDiagram from '@site/static/img/diagrams/notification-flow.svg';

<div style={{ textAlign: 'center', margin: '2rem 0' }}>
  <NotificationFlowDiagram width="100%" style={{ borderRadius: '16px', boxShadow: '0 4px 20px rgba(0,0,0,0.15)' }} />
</div>

Deletion currently waits for the backend request to succeed before mutating the
local list.

### 1. 💻 Trigger (UI Layer)
The user taps the delete icon on a `NotificationCard`.
```dart
await ref
    .read(notificationProvider.notifier)
    .deleteNotification(item.id);
```

### 2. 🌐 Execution (Repository Layer)
The provider calls the repository first.
```dart
await _repository.deleteNotification(notificationId: id);
```

### 3. 🔄 Reactivity (Provider Layer)
After the repository call succeeds, the provider removes the item from its
`AsyncValue` data.
```dart
state = AsyncValue.data(items.where((item) => item.id != id).toList());
```

### 4. 🛡️ Error Handling (UI Layer)
`NotificationPage` catches action errors and shows an app toast.
```dart
} catch (error) {
  AppToast.showError(_formatError(error));
}
```

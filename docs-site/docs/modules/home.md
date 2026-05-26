---
id: home
title: Home Module
sidebar_position: 2
---

# Home Module

The **Home Module** (`lib/features/home`) acts as the central dashboard for the mobile application. It provides patients with an aggregated view of their active tasks, upcoming appointments, and quick entry points to all other features.

:::note[Design Philosophy]
The `HomePage` is designed to be a lightweight aggregator. Rather than maintaining complex global state, it fetches its data directly and consumes states provided by other modules.
:::

## State Management

Unlike deeply nested features, the Home module relies primarily on localized state for its immediate UI needs, while reading global providers for application-wide status.

| Mechanism | Description |
| :--- | :--- |
| **Local State (`StatefulWidget`)** | Manages the `_isLoadingTasks` boolean and `_taskCount` integer directly within `_HomePageState`. |
| **Direct Repository Access** | Instantiates `HomeRepository` to execute `getTasks()` directly during `initState` and via Pull-to-Refresh. |
| **Global Consumers** | Consumes `themeController` (dark/light), `authStateProvider` (logout), `notificationProvider` / `unreadCountProvider` (app-bar bell badge + summary card), and `weatherProvider` (Home weather card). |
| **Startup hooks** | Post-frame callback invokes `checkAndPrompt()` from `lib/core/services/version_gate.dart` — calls `util/check_version` and shows a dismissible update dialog when `status == 'update_available'`, throttled to once per 24h via Hive. |

## Widget Types & Patterns

The UI is composed of animated, highly-reusable components designed to give a premium feel. 

```text
📦 HomePage
├── 🧭 AppBar (refresh · ⚙️ Settings → /settings · 🔔 notification bell badge · logout)
├── 🔄 RefreshIndicator
└── 📜 SingleChildScrollView
    └── 🏗️ Column
        ├── 🌟 FadeSlideTransition (Welcome Card)
        ├── 🌟 FadeSlideTransition
        │   └── 📇 MedicalInfoCard (Active Tasks — real count)
        ├── 🌟 FadeSlideTransition
        │   └── 🔔 Notification summary card → push('/notification')
        ├── 🌟 FadeSlideTransition
        │   └── 🌤️ _WeatherSummaryCard (weatherProvider · util/weather)
        ├── 🌟 FadeSlideTransition
        │   └── 📱 Wrap of _QuickActionCard
        │       ├── "Thông tin" → push('/info')
        │       └── "SOS" (red) → push('/sos')
        └── 🌟 FadeSlideTransition
            └── 🚨 Status Badge
```

:::note[Demo content removed]
The fake appointment counter (and its `FloatingActionButton`), the static
"doctors available" card, and the nav-duplicating quick actions (Map / Medical /
Profile) were removed. The Home screen now shows only real data plus an Info shortcut.
:::

- **Core Reusable Components**: `FadeSlideTransition`, `MedicalInfoCard`, `NotificationBadge`.

## State Taxonomy

- **Local UI State**: `_taskCount` and `_isLoadingTasks`. The Home module relies entirely on internal `StatefulWidget` state for its immediate metrics.
- **Consumed Global State**: `themeController` (for dark mode) and `authStateProvider` (for logout).
- **Remote State**: Summary data fetched directly from the backend without intermediate caching providers.

## The Execution Lifecycle

import HomeFlowDiagram from '@site/static/img/diagrams/home-flow.svg';

<div style={{ textAlign: 'center', margin: '2rem 0' }}>
  <HomeFlowDiagram width="100%" style={{ borderRadius: '16px', boxShadow: '0 4px 20px rgba(0,0,0,0.15)' }} />
</div>

The dashboard population follows a simple, robust fetch-and-render cycle directly bound to the widget's lifecycle.

### 1. 💻 Initialization (UI Layer)
The `HomePage` widget mounts and instantly invokes the fetch method within its `initState`.
```dart
@override
void initState() {
  super.initState();
  _fetchTasks();
}
```

### 2. ⚙️ State Preparation (Local State)
The UI sets a loading flag to render skeleton loaders or spinners, locking user interactions that require the data.
```dart
setState(() {
  _isLoadingTasks = true;
});
```

### 3. 🌐 Execution (Repository Layer)
The `HomeRepository` is invoked directly to fetch the required data via Dio.
```dart
final tasks = await _homeRepository.getTasks();
```

### 4. 🔄 Reactivity (UI Layer)
Upon success, the UI safely mutates its local state, triggering a targeted `build()` execution to render the `MedicalInfoCard` with the latest task count.
```dart
if (mounted) {
  setState(() {
    _taskCount = tasks.length;
    _isLoadingTasks = false;
  });
}
```

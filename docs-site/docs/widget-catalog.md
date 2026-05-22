---
id: widget-catalog
title: Global Widget Catalog
sidebar_position: 8
---

# Global Widget Catalog

To maintain a consistent, premium, and unified UI/UX across the entire application, developers are required to use the **Core Widgets** located in `lib/core/widgets/` rather than building ad-hoc UI elements.

This catalog documents the foundational widgets used across all modules.

## Global App Architecture Tree

Before diving into individual components, here is the high-level structural composition of the entire application. It illustrates how state management, version gating, routing, and the main shell are nested.

```text
📦 ProviderScope (Riverpod Root)
└── 📦 MaterialApp.router
    └── 🛡️ VersionCheckWidget (Global Wrapper)
        └── 🔀 go_router (Route Management)
            ├── 🔒 Unauthenticated Branch
            │   └── 📦 LoginOtpPage
            └── 🔓 Authenticated Branch
                └── 📦 MainShell
                    └── 📄 StatefulNavigationShell
                        ├── 📑 Home Branch
                        ├── 📑 Medical Branch
                        ├── 📑 Notification Branch
                        ├── 📑 Info Branch
                        ├── 📑 Map Branch
                        └── 📑 Profile Branch
```

---

## 🌟 `FadeSlideTransition`
**Path**: `lib/core/widgets/fade_slide_transition.dart`

This is the most critical micro-animation component in the app. It is used to gracefully cascade elements into the view (sliding up slightly while fading from 0 to 1 opacity) when a screen mounts.

### Usage Pattern
Wrap any child widget with `FadeSlideTransition` and assign a staggered `delay`.
```dart
FadeSlideTransition(
  delay: const Duration(milliseconds: 150),
  child: Text('Tổng quan'),
)
```

---

## 📇 `MedicalInfoCard`
**Path**: `lib/core/widgets/medical_info_card.dart`

The standardized metric display card used extensively in the `Home` and `Medical` modules to display stats like "Active Tasks" or "Appointments".

### Usage Pattern
It guarantees consistent padding, icon alignment, and border-radii across the application.
```dart
MedicalInfoCard(
  label: 'Nhiệm vụ hiện tại',
  value: '$_taskCount Hoạt động',
  icon: Icons.assignment_rounded,
  onTap: () => _fetchTasks(),
)
```

---

## 🛡️ `VersionCheckWidget`
**Path**: `lib/core/widgets/version_check_widget.dart`

A structural wrapper widget used at the root of the application (or specific protected routes) to ensure the user is running a backend-compliant version of the app. If the version is outdated, this widget intercepts the UI and forces a blocking "Update Required" screen.

---

## Form Controls (Buttons & Fields)

While not contained in a single global file, the application uses a mix of
standard Material controls and feature-specific controls.

- **Buttons**: Most screens use standard Material buttons (`FilledButton`,
  `ElevatedButton`, `TextButton`, and `FloatingActionButton`) styled through the
  app theme or local `ButtonStyle`s.
- **Text Fields**: Auth screens use `AuthTextField`; profile editing uses
  `ProfileForm` fields; map search uses `MapTopBar`.

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
    └── 🔀 go_router (Route Management)
        ├── 🔒 Unauthenticated Branch
        │   └── 📦 LoginPage
        └── 🔓 Authenticated Branch
            └── 📦 MainShell (NavigationBar)
                └── 📄 StatefulNavigationShell
                    ├── 📑 Home Branch
                    ├── 📑 Medical Branch
                    ├── 📑 Map Branch
                    ├── 📑 Profile Branch
                    └── 📑 Chat Branch
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

## 🛡️ Startup Update Prompt
**Path**: `lib/core/services/version_gate.dart`

The current update flow runs from Home after startup. It calls
`util/check_version`, rate-limits repeated prompts, and opens the backend
`download_url` externally when an update is available.

---

## Form Controls (Buttons & Fields)

While not contained in a single file, the application relies heavily on stylized controls to maintain an "Anthropic-like" premium feel. 

- **Primary Buttons**: Always feature rounded corners (`AppRadius.borderLg`), bold typography, and respond to the global theme colors.
- **Text Fields**: Utilize filled backgrounds with subtle borders, prioritizing readability and clear error states during validation (e.g., used in `LoginPage` and `ProfileEditForm`).

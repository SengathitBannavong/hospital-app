---
id: widget-types
title: Widget Types & Patterns
sidebar_position: 4
---

# Widget Types & Patterns

Our Flutter application separates UI components by their scope and reusability to maintain a clean widget tree.

## 1. Global / Core Widgets
Located in `lib/core/widgets/`. These are highly reusable components utilized across multiple features. They do not contain any feature-specific business logic.

- **Examples**:
  - `CustomPrimaryButton`
  - `CustomTextField`
  - `FadeSlideTransition` (Shared animation wrapper)
  - `ToastUtility` wrappers

## 2. Page Widgets (Screens)
Located in `lib/features/{feature_name}/presentation/pages/`. These widgets represent full screen views navigable via `go_router`.

- **Responsibilities**:
  - Consume Riverpod Providers (extend `ConsumerWidget` or `ConsumerStatefulWidget`).
  - Act as the scaffold for the screen.
  - Wire up user actions to provider methods.
- **Examples**:
  - `HomePage`
  - `LoginPage`
  - `TaskListPage`

## 3. Feature-Specific Component Widgets
Located in `lib/features/{feature_name}/presentation/widgets/`. These are sub-components constructed specifically for a single feature.

- **Responsibilities**:
  - Keep the Page widgets clean by offloading UI layout code.
  - Require data objects (models) passed down via constructor, rather than reading providers directly (unless deeply nested).
- **Examples**:
  - `MapGridPainter` (Inside Map Feature)
  - `TaskCard` (Inside Medical Feature)
  - `QueueItem` (Inside Medical Feature)

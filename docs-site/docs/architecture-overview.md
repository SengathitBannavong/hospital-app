---
id: architecture-overview
title: Architecture Overview
sidebar_position: 1
---

# Architecture Overview

The Hospital App follows a **Feature-First** (Domain-Driven Design inspired) architecture. This approach scales exceptionally well for complex applications by encapsulating features rather than grouping by technical concerns.

## High-Level Separation

The application code inside `lib/` is strictly separated into two main directories:

1. **`core/`**
   Contains all shared, domain-agnostic code. This includes network clients, routing definitions, global error handling, shared widgets, and styling themes.
2. **`features/`**
   Contains all domain-specific code. Each feature is self-contained. For example, everything related to `auth` (pages, providers, models, repositories) lives inside `lib/features/auth`.

## Core Modules Overview

- **Auth**: Manages user sessions, login, registration, OTP flows, and token persistence.
- **Home**: The central dashboard for the mobile app, providing quick actions, summary metrics, and entry points to all other features.
- **Map**: Provides a custom grid-based 2D map renderer, route preview,
  simulated navigation, QR/manual current-position setting, and POI search.
- **Medical**: Handles clinical tasks, active queue management, and prescription views for patients.
- **Notification**: Unified inbox for system alerts and medical updates.
- **Profile**: Manages the user's personal details and preferences.

## UI Shell & Navigation

The app shell is built using `go_router`. It implements a
`StatefulShellRoute.indexedStack` bottom navigation shell that allows seamless
switching between the primary feature branches (Home, Medical, Notification,
Info, Map, and Profile) while maintaining navigation state.

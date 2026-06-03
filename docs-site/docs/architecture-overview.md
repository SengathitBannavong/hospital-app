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
- **Map**: Provides a custom grid-based 2D map renderer, routing, turn-by-turn navigation, and location services (floor switching, POI search).
- **Medical**: Handles clinical tasks, active queue management, and prescription views for patients.
- **Notification**: Unified inbox for system alerts and medical updates.
- **Profile**: Manages the user's personal details and preferences.
- **Chat**: Patient/staff room list and realtime per-room messaging.

## UI Shell & Navigation

The app shell is built using `go_router`. It implements a 5-tab bottom
navigation shell — in order **Home, Medical (labeled "Utilities"), Map, Chat,
Profile** — that allows seamless switching between the primary feature branches
while maintaining navigation state, with a swipe gesture to move between tabs.
Secondary destinations (Notification, Info, FAQ, About, Contact, SOS, Settings,
Feedback, and chat room details) are pushed routes.

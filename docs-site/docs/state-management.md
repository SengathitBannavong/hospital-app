---
id: state-management
title: State Management
sidebar_position: 2
---

# State Management

The Hospital App utilizes **Riverpod** (`flutter_riverpod`) as its primary state management solution. Riverpod provides a compile-safe, robust, and testable way to manage global and feature-scoped state.

## Provider Architecture

We follow a unidirectional data flow using Riverpod's modern syntax (e.g., `@riverpod` via `riverpod_generator` or standard `NotifierProvider`/`StateNotifierProvider`).

### 1. Data Providers
Simple providers that expose data sources, such as Repositories or Network Clients. They rarely hold mutable state on their own.
*Example: `authRepositoryProvider`*

### 2. State Providers (Notifiers)
These are responsible for orchestrating business logic and holding mutable UI state. They consume Data Providers.
*Example: `authProvider`*
- Reads `authRepositoryProvider`.
- Exposes `AsyncValue<User>` or `AuthState`.
- Provides methods like `login(email, password)` which mutate the state from `loading` -> `data` / `error`.

## Scoping State by Feature

State is strictly grouped by the feature it supports.
- `lib/features/auth/presentation/providers/auth_provider.dart`
- `lib/features/map/presentation/providers/map_provider.dart`
- `lib/features/medical/presentation/providers/task_provider.dart`

## Benefits
- **Compile-Time Safety**: Providers are tracked statically, preventing "ProviderNotFound" runtime errors.
- **Dependency Injection**: Riverpod acts as a robust service locator, easily mocked for unit tests.
- **Async Handling**: Native support for loading/error/data states out of the box via `AsyncValue`.

## Provider Lifecycle: Chat Example

Most feature providers are `autoDispose` and live only while their screen is
mounted. The chat rooms provider is a deliberate exception worth calling out:

- **`chatRoomsProvider`** is **root-anchored** (non-`autoDispose`) and watched
  from `MyApp` whenever a user is logged in, so it stays alive app-wide and can
  poll `get_rooms` every 60s for unread/last-message updates across all rooms.
- It mixes in `WidgetsBindingObserver` and pauses its poll timer **only on real
  backgrounding** (`paused`/`detached`/`hidden`), not on the transient
  `inactive` event. Cancelling on `inactive` would recreate the timer on the
  following `resume` and reset `Timer.periodic`'s countdown, so the poll would
  never fire — a subtle bug worth remembering for any lifecycle-driven timer.
- **`chatMessagesProvider`** is an `autoDispose` family keyed by room id. It is
  WebSocket-primary (realtime + catch-up on reconnect + a 25s backstop poll) and
  is torn down when the conversation closes, after which the global rooms poll is
  the only active chat sync.

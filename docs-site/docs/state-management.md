---
id: state-management
title: State Management
sidebar_position: 2
---

# State Management

The Hospital App utilizes **Riverpod** (`flutter_riverpod`) as its primary state management solution. Riverpod provides a compile-safe, robust, and testable way to manage global and feature-scoped state.

## Provider Architecture

The codebase uses Riverpod's standard provider APIs directly. The current app
does not use `riverpod_generator` or generated `@riverpod` providers.

### 1. Data Providers
Simple providers that expose data sources, such as Repositories or Network Clients. They rarely hold mutable state on their own.
*Example: `authRepositoryProvider`*

### 2. State Providers (Notifiers)
These are responsible for orchestrating business logic and holding mutable UI
state. They consume Data Providers.
*Example: `authProvider`*
*Examples: `authStateProvider`, `notificationProvider`, `profileProvider`*
- Read their corresponding repository providers.
- Expose feature state such as `AuthUser?` or `AsyncValue<List<T>>`.
- Provide methods like `login`, `logout`, `markAsRead`, and `updateProfile`.

### 3. Future Providers
Several feature screens use `FutureProvider` or `FutureProvider.family` for
straightforward server-state reads.
*Examples: `medicalTasksProvider`, `mapNodesProvider(mapId)`*

## Scoping State by Feature

State is strictly grouped by the feature it supports.
- `lib/features/auth/presentation/providers/auth_provider.dart`
- `lib/features/map/presentation/providers/map_provider.dart`
- `lib/features/medical/presentation/providers/medical_providers.dart`

## Benefits
- **Compile-Time Safety**: Providers are tracked statically, preventing "ProviderNotFound" runtime errors.
- **Dependency Injection**: Riverpod acts as a robust service locator, easily mocked for unit tests.
- **Async Handling**: Native support for loading/error/data states out of the box via `AsyncValue`.

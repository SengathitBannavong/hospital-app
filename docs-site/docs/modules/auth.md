---
id: auth
title: Auth Module
sidebar_position: 1
---

# Auth Module

The **Auth Module** (`lib/features/auth`) is responsible for managing user sessions, robust multi-step authentication flows (including OTP), and secure token persistence.

:::info[Architecture Context]
This module strictly follows the separation of concerns by utilizing Riverpod for state orchestration and delegating network calls to the `AuthRepository`.
:::

## State Management

State orchestration is highly granular to prevent unnecessary rebuilds. 

| Provider | Type | Description |
| :--- | :--- | :--- |
| `authStateProvider` | `StateNotifierProvider` | The core provider exposing an `AuthUser` object. Handles complex flows like `verifyCredentials`, `login`, and `logout`. |

## Widget Types & Patterns

The module is composed of several specialized screens utilizing shared core components. Below is the structural composition of the primary `LoginPage`:

```text
📦 LoginPage
└── 📜 SingleChildScrollView
    └── 🏗️ Column
        ├── 🖼️ Image (App Logo)
        ├── 🌟 FadeSlideTransition
        │   └── 📝 CustomTextField (Phone Number)
        ├── 🌟 FadeSlideTransition
        │   └── 📝 CustomTextField (Password)
        ├── 🌟 FadeSlideTransition
        │   └── 🔘 CustomPrimaryButton (Login)
        └── 🌟 FadeSlideTransition
            └── 🔀 Row
                ├── 🔗 TextButton (Forgot Password)
                └── 🔗 TextButton (Register)
```

- **Authentication Flow:** `WelcomePage`, `LoginPage`, `RegisterPage`.
- **Recovery & Verification:** `OTPVerificationPage`, `ForgotPasswordPage`, `ResetPasswordPage`, `ChangePasswordPage`.

:::tip[Navigation Pattern]
Unauthenticated users attempting to access protected routes are automatically redirected to the `LoginPage` via the global `go_router` configuration listening to the `authStateProvider`.
:::

:::info[Strong-password policy]
Register, reset-password, and change-password all enforce a shared
**strong-password policy** via `FormValidators.isStrongPassword`: at least 8
characters containing an uppercase letter, a lowercase letter, a digit, and a
symbol (previously a flat 6-character minimum). A failing field surfaces the
localized `authPasswordWeak` message (en/vi).
:::

## State Taxonomy

Before diving into the flow, it's crucial to understand where data lives in the Auth module:
- **Local UI State**: Form input controllers, validation error strings (e.g., inside `LoginPage`).
- **Global State**: The `authStateProvider` holds the `AuthUser` object. It is global because the entire app shell (`go_router`) depends on it to determine route access.
- **Persistent State**: The JWT token securely stored on the device via `TokenRepository`.

## The Execution Lifecycle (Login)

import AuthFlowDiagram from '@site/static/img/diagrams/auth-flow.svg';

<div style={{ textAlign: 'center', margin: '2rem 0' }}>
  <AuthFlowDiagram width="100%" style={{ borderRadius: '16px', boxShadow: '0 4px 20px rgba(0,0,0,0.15)' }} />
</div>

The authentication flow leverages a strict unidirectional pattern. Below is the lifecycle of a successful Login action:

### 1. 💻 Trigger (UI Layer)
The user enters their phone number and password on the `LoginPage` and taps "Login". The UI dispatches the intent to the provider.
```dart
ref.read(authStateProvider.notifier).verifyCredentials(phone, password);
```

### 2. ⚙️ Orchestration (Provider Layer)
The `AuthNotifier` transitions its state to `loading` and delegates the heavy lifting to the repository.
```dart
// Inside AuthNotifier
state = const AsyncLoading();
final user = await _repository.login(phoneNumber: phone, password: password);
```

### 3. 🌐 Execution (Repository Layer)
The `AuthRepository` formats the request and utilizes the Dio client to hit the backend API.
```dart
// Inside AuthRepository
final response = await dioClient.post('/auth/login', data: {...});
```

### 4. 💾 Persistence (Storage Layer)
Upon a successful JSON response, the token is extracted and stored securely on the device before updating the state.
```dart
// Inside AuthNotifier
await TokenRepository.saveToken(user.token);
```

### 5. 🔄 Reactivity (UI Layer)
The `AuthNotifier` mutates its state to the `AuthUser` object. The `go_router`, which is actively listening, detects this change and redirects to the `HomePage`.
```dart
// go_router configuration
redirect: (context, state) {
  final isAuth = ref.read(authStateProvider) != null;
  if (isAuth && state.matchedLocation == '/login') return '/home';
  return null;
}
```

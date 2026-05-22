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
| `authRepositoryProvider` | `Provider` | Exposes `AuthRepository` to auth state and flows. |
| `authStateProvider` | `StateNotifierProvider` | The core provider exposing `AuthUser?`. `null` means the user is not logged in. |
| `versionCheckProvider` | `FutureProvider.family` | Validates the current app version against the backend upon initialization. |
| `deleteAccountProvider` | `FutureProvider.family` | Manages the destructive account deletion workflow. |

## Widget Types & Patterns

The module is composed of several specialized screens utilizing shared core
components and auth-specific form controls. Below is the structural composition
of the primary login page:

```text
📦 LoginOtpPage
└── 📜 SingleChildScrollView
    └── 🏗️ Column
        ├── 🌟 FadeSlideTransition (Header)
        │   └── 🛡️ Health Icon + welcome text
        └── 🌟 FadeSlideTransition (Login Card)
            ├── 📝 AuthTextField (Phone Number)
            ├── 📝 AuthTextField (Password)
            ├── 🔗 TextButton (Forgot Password)
            ├── 🔘 FilledButton (Login)
            └── 🔗 TextButton (Register)
```

- **Authentication Flow:** `WelcomePage`, `LoginOtpPage`, `RegisterPage`.
- **Recovery & Verification:** `OTPVerificationPage`, `ForgotPasswordPage`, `ResetPasswordPage`, `ChangePasswordPage`.

:::tip[Navigation Pattern]
Unauthenticated users attempting to access protected routes are automatically
redirected to `LoginOtpPage` via the global `go_router` configuration listening
to `authStateProvider`.
:::

## State Taxonomy

Before diving into the flow, it's crucial to understand where data lives in the Auth module:
- **Local UI State**: Form input controllers, validation error strings, and
  submit loading flags (for example inside `LoginOtpPage`).
- **Global State**: The `authStateProvider` holds `AuthUser?`. It is global
  because `go_router` listens to it to determine route access.
- **Persistent State**: The JWT token securely stored on the device via `TokenRepository`.

## The Execution Lifecycle (Login)

import AuthFlowDiagram from '@site/static/img/diagrams/auth-flow.svg';

<div style={{ textAlign: 'center', margin: '2rem 0' }}>
  <AuthFlowDiagram width="100%" style={{ borderRadius: '16px', boxShadow: '0 4px 20px rgba(0,0,0,0.15)' }} />
</div>

The authentication flow leverages a direct provider-to-repository pattern. Below
is the lifecycle of a successful login action:

### 1. 💻 Trigger (UI Layer)
The user enters their phone number and password on `LoginOtpPage` and taps
"Login". The UI dispatches the intent to the provider.
```dart
await ref.read(authStateProvider.notifier).login(phoneNumber, password);
```

### 2. ⚙️ Orchestration (Provider Layer)
The `AuthNotifier` delegates login to the repository. Loading/error state for
the login button is local UI state in the page, not part of `authStateProvider`.
```dart
// Inside AuthNotifier
final user = await _repository.login(
  phoneNumber: phoneNumber,
  password: password,
);
await saveTokenAndSetUser(user);
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
The `AuthNotifier` mutates its state to the `AuthUser` object. The login page
then navigates to `/`, and the router also listens to auth changes for protected
route redirects.
```dart
// go_router configuration
redirect: (context, state) {
  final isLoggedIn = ref.read(authStateProvider) != null;
  if (!isLoggedIn && !isLoggingIn) return '/login';
  return null;
}
```

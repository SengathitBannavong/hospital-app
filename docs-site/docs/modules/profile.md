---
id: profile
title: Profile Module
sidebar_position: 6
---

# Profile Module

The **Profile Module** (`lib/features/profile`) allows users to view, manage, and update their personal demographic information and application preferences.

## State Management

| Provider | Description |
| :--- | :--- |
| **`profileRepositoryProvider`** | Exposes `ProfileRepository` to profile state. |
| **`profileProvider`** | Auto-disposed `StateNotifierProvider` that fetches and updates the current user's profile as `AsyncValue<UserProfile>`. |

## Widget Types & Patterns

The Profile module handles dense user input forms and avatar management.

```text
📦 ProfilePage
└── 📜 SingleChildScrollView
    ├── 👤 ProfileAvatar (InkWell wrapper)
    │   └── 📷 ImagePicker Integration
    └── 📝 ProfileForm
        ├── 🏗️ Form (GlobalKey<FormState>)
        │   ├── 📝 Text field (Name)
        │   ├── 📝 Date field
        │   └── 📝 Gender field
        └── 🔘 Save / Cancel actions
```

:::info[Hardware Integrations]
The `ProfileAvatar` seamlessly integrates with the `image_picker` package, allowing users to select a new photo from their gallery or capture one directly from the device camera.
:::

## State Taxonomy

- **Server State**: `profileProvider` holds the user's demographic data fetched
  from `/user/get_profile`.
- **Local Page State**: `ProfilePage` tracks whether the screen is currently in
  edit mode.
- **Local Form State**: `ProfileForm` uses standard Flutter form state and
  controllers before submitting changes.

## The Execution Lifecycle (Editing Profile)

import ProfileFlowDiagram from '@site/static/img/diagrams/profile-flow.svg';

<div style={{ textAlign: 'center', margin: '2rem 0' }}>
  <ProfileFlowDiagram width="100%" style={{ borderRadius: '16px', boxShadow: '0 4px 20px rgba(0,0,0,0.15)' }} />
</div>

### 1. 💻 Interaction (UI Layer)
The user enters edit mode, fills out `ProfileForm`, and taps "Save".
```dart
ProfileForm(
  initialProfile: profile,
  onSave: (fullName, dob, gender) async { ... },
)
```

### 2. 🛡️ Validation (Controller Layer)
Client-side validation runs inside `ProfileForm` before invoking `onSave`.

### 3. 🌐 Execution (Repository Layer)
The page calls `ProfileNotifier.updateProfile`, which delegates to the
repository.
```dart
await ref.read(profileProvider.notifier).updateProfile(
  fullName: fullName,
  dob: dob,
  gender: gender,
);
```

### 4. 🔄 State Replacement (Provider Layer)
Upon a successful response, the notifier replaces its `AsyncValue` with the
updated profile returned by the repository.
```dart
state = await AsyncValue.guard(() async {
  return _repository.updateProfile(...);
});
```

### 5. 🔄 Rebuild (UI Layer)
`ProfilePage`, which watches `profileProvider`, rebuilds from the new provider
state.
```dart
// Inside ProfilePage
final profile = ref.watch(profileProvider);
```

---
id: profile
title: Profile Module
sidebar_position: 6
---

# Profile Module

The **Profile Module** (`lib/features/profile`) allows users to view, manage, and update their personal demographic information and application preferences.

:::note[App preferences live in Settings]
App preferences (theme, notifications, language) are **not** on the Profile page
itself — the Profile app bar has a ⚙️ gear that opens the shared
[Settings page](./settings) (`context.push('/settings')`).
:::

:::info[Đánh giá ứng dụng]
The Profile menu also exposes an **"Đánh giá ứng dụng"** entry that pushes
`/feedback`. See the [Util Module](./util) for the feedback page details and
the backend contract.
:::

## State Management

| Provider | Description |
| :--- | :--- |
| **`profileProvider`** | Caches the user's fetched profile data locally. This prevents unnecessary network calls when switching between bottom navigation tabs. |
| **`profileFormController`** | (Optional) specialized controllers utilized specifically during edit mode to track unsaved form states and validation errors. |

## Widget Types & Patterns

The Profile module handles dense user input forms and avatar management.

```text
📦 ProfilePage
└── 📜 SingleChildScrollView
    ├── 👤 ProfileAvatar (InkWell wrapper)
    │   └── 📷 ImagePicker Integration
    └── 📝 ProfileEditForm
        ├── 🏗️ Form (GlobalKey<FormState>)
        │   ├── 📝 CustomTextField (Name)
        │   ├── 📝 CustomTextField (Phone)
        │   └── 📝 CustomTextField (Email)
        └── 🔘 CustomPrimaryButton (Save)
```

:::info[Hardware Integrations]
The `ProfileAvatar` seamlessly integrates with the `image_picker` package, allowing users to select a new photo from their gallery or capture one directly from the device camera.
:::

## State Taxonomy

- **Server State (Cached)**: `profileProvider` holds the user's demographic data fetched from `/user/get_profile`.
- **Local Form State**: `ProfileEditForm` utilizes standard Flutter `TextEditingController` instances and `GlobalKey<FormState>` to manage active input strings and validation errors before submission.

## The Execution Lifecycle (Editing Profile)

import ProfileFlowDiagram from '@site/static/img/diagrams/profile-flow.svg';

<div style={{ textAlign: 'center', margin: '2rem 0' }}>
  <ProfileFlowDiagram width="100%" style={{ borderRadius: '16px', boxShadow: '0 4px 20px rgba(0,0,0,0.15)' }} />
</div>

### 1. 💻 Interaction (UI Layer)
The user enters the edit view, fills out the `ProfileEditForm`, and taps "Save".
```dart
// Inside ProfileEditForm
if (_formKey.currentState!.validate()) {
  _submitProfile();
}
```

### 2. 🛡️ Validation (Controller Layer)
Client-side regex checking ensures data (like phone numbers) is formatted correctly before hitting the network.

### 3. 🌐 Execution (Repository Layer)
The form data is packaged into a DTO and sent via the repository to the backend.
```dart
// Inside ProfileRepository
await dioClient.put('/user/set_profile', data: formData.toJson());
```

### 4. 🗑️ Invalidation (Provider Layer)
Upon a successful response, instead of manually piecing the state back together, the `profileProvider` is intentionally invalidated.
```dart
ref.invalidate(profileProvider);
```

### 5. 🔄 Rebuild (UI Layer)
The invalidation completely dumps the old cache and forces a fresh fetch from the server. The `ProfilePage`, which is actively watching the provider, cleanly rebuilds with the new source-of-truth data.
```dart
// Inside ProfilePage
final profile = ref.watch(profileProvider);
```

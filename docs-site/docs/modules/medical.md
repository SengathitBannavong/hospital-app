---
id: medical
title: Medical Module
sidebar_position: 4
---

# Medical Module

The **Medical Module** (`lib/features/medical`) is dedicated to patient-facing clinical workflows. It aggregates upcoming appointments, manages live queue statuses, and displays medical prescriptions.

## State Management

State logic is consolidated within `medical_providers.dart`, leveraging Riverpod to handle asynchronous data streams seamlessly.

| Provider | Description |
| :--- | :--- |
| **`taskProvider`** | Fetches and caches the user's active medical tasks (appointments, tests). Handles loading and error states via `AsyncValue`. |
| **`queueProvider`** | Monitors the real-time queue status for the user's current department. |
| **`prescriptionProvider`** | Manages the loaded prescription data for completed visits. |

## Widget Types & Patterns

The module is broken down into distinct tab-like views, each supported by highly reusable list items.

```text
📦 MedicalShell (TabBarView)
├── 📑 TaskListPage
│   └── 📜 ListView.builder
│       └── 🌟 FadeSlideTransition
│           └── 📇 TaskCard (Check-in flow)
├── 📑 QueuePage
│   └── 📜 ListView.builder
│       └── 🎫 QueueItem (Live Status)
└── 📑 PrescriptionPage
    └── 📜 ListView
        └── 💊 MedicationCard
```

:::tip[Optimistic UI Updates]
For actions like "Check-in", the module often relies on local state mutation to provide instant feedback before the API confirms the action, ensuring the app feels incredibly fast.
:::

## State Taxonomy

- **Server State (Cached)**: `taskProvider`, `queueProvider`, and `prescriptionProvider`. These hold the source of truth fetched from the backend.
- **Local UI State**: Minor states like expanded/collapsed cards or internal list view scroll offsets.

## The Execution Lifecycle (Check-in Process)

import MedicalFlowDiagram from '@site/static/img/diagrams/medical-flow.svg';

<div style={{ textAlign: 'center', margin: '2rem 0' }}>
  <MedicalFlowDiagram width="100%" style={{ borderRadius: '16px', boxShadow: '0 4px 20px rgba(0,0,0,0.15)' }} />
</div>

The most critical flow in this module is checking into an appointment, prioritizing **Optimistic UI Updates** to make the app feel incredibly fast.

### 1. 💻 Trigger (UI Layer)
The user taps the "Check-in" button on a `TaskCard`.
```dart
// Inside TaskCard widget
onTap: () => ref.read(taskProvider.notifier).checkIn(task.id)
```

### 2. ⚙️ Orchestration (Provider Layer)
The provider receives the intent, updates its internal state to `loading`, and delegates the network call.
```dart
// Inside TaskNotifier
state = const AsyncLoading();
await _repository.checkIn(taskId);
```

### 3. 🌐 Execution (Repository Layer)
The repository formats the request and uses Dio to hit the backend endpoint.
```dart
// Inside MedicalRepository
await dioClient.post('/medical/checkin', data: {'id': taskId});
```

### 4. 🔄 Reactivity & Optimism (UI Layer)
Upon a successful 200 OK response, the provider mutates the local state array directly to reflect the "Checked In" status, avoiding an expensive full-list re-fetch.
```dart
// Inside TaskNotifier (Optimistic mutation)
final updatedTasks = state.value!.map((t) => 
  t.id == taskId ? t.copyWith(status: 'CHECKED_IN') : t
).toList();

state = AsyncData(updatedTasks);
```

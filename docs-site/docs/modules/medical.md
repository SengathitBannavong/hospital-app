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
| **`medicalRepositoryProvider`** | Exposes `MedicalRepository` to the feature. |
| **`medicalTasksProvider`** | Fetches the user's active medical tasks and exposes loading/error/data via `AsyncValue`. |
| **`medicalHistoryProvider`** | Fetches completed or historical medical tasks. |
| **`medicalQueueProvider(poiId)`** | Fetches the queue status for a department/room POI. |
| **`medicalRoomOpenProvider(poiId)`** | Fetches whether a room is currently open. |
| **`medicalResultStatusProvider(treatmentId)`** | Fetches result availability for a treatment. |
| **`medicalPrescriptionProvider`** | Fetches the user's prescription data. |

## Widget Types & Patterns

The module is broken down into distinct tab-like views, each supported by highly reusable list items.

```text
📦 Medical routes
├── 📑 TaskListPage
│   └── 📜 ListView.builder
│       └── 🌟 FadeSlideTransition
│           └── 📇 TaskCard
├── 📑 QueuePage
│   └── 📜 ListView.builder
│       └── 🎫 QueueItem (Live Status)
└── 📑 PrescriptionPage
    └── 📜 ListView
        └── 💊 PrescriptionItemTile
```

## State Taxonomy

- **Server State**: `medicalTasksProvider`, `medicalHistoryProvider`,
  `medicalQueueProvider`, `medicalRoomOpenProvider`,
  `medicalResultStatusProvider`, and `medicalPrescriptionProvider` fetch data
  through `MedicalRepository`.
- **Local UI State**: Minor states like expanded/collapsed cards or internal list view scroll offsets.

## The Execution Lifecycle (Task List)

import MedicalFlowDiagram from '@site/static/img/diagrams/medical-flow.svg';

<div style={{ textAlign: 'center', margin: '2rem 0' }}>
  <MedicalFlowDiagram width="100%" style={{ borderRadius: '16px', boxShadow: '0 4px 20px rgba(0,0,0,0.15)' }} />
</div>

The task list flow is a straightforward provider-backed fetch.

### 1. 💻 Trigger (UI Layer)
`TaskListPage` watches the task provider.
```dart
final tasksState = ref.watch(medicalTasksProvider);
```

### 2. ⚙️ Orchestration (Provider Layer)
The provider delegates the fetch to the repository.
```dart
final medicalTasksProvider = FutureProvider<List<MedicalTask>>((ref) async {
  final repository = ref.watch(medicalRepositoryProvider);
  return repository.getTasks();
});
```

### 3. 🌐 Execution (Repository Layer)
The repository uses the shared Dio client and API endpoint constants.
```dart
final response = await ApiClient.instance.get(ApiEndpoints.getTasks);
```

### 4. 🔄 Reactivity (UI Layer)
The page renders loading, error, or data states from `AsyncValue`.
```dart
tasksState.when(
  data: (tasks) => ListView.builder(...),
  loading: () => const CircularProgressIndicator(),
  error: (error, _) => ErrorView(error),
);
```

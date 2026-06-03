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
| **`medicalTasksProvider`** | Fetches and caches the user's active medical tasks via `AsyncValue`. |
| **`medicalHistoryProvider`** | Backs the "Lịch sử hôm nay" history section. |
| **`medicalRepositoryProvider`** | Exposes the repository (check-in/out, cancel, result status, sync) used by `TaskDetailPage` and the Sync HIS action. |

## Widget Types & Patterns

`TaskListPage` is the Medical bottom-nav branch root. Rather than a tab shell, it
is a single scroll view: a 2-per-row **utility action grid**, the live task list,
and a collapsible "Lịch sử hôm nay" history section. Queue, prescription, and the
per-task actions are reached as **pushed routes** off `/medical`, each with its
own back button.

```text
📦 TaskListPage  (branch root, /medical)
├── 🧭 AppBar (🔄 Sync HIS → medicalRepository.syncNow())
├── 🟦 Utility action grid (_ActionCard, 2-per-row)
│   ├── "Hàng đợi"        → push('/medical/queue')
│   ├── "Đơn thuốc"       → push('/medical/prescription')
│   ├── "Trạm xe lăn"     → push('/asset/stations')
│   ├── "Tìm xe lăn gần đây" → push('/asset/search')
│   ├── "Hỗ trợ nhân viên"   → push('/staff')
│   ├── "Báo cáo vật cản"    → push('/flow/report-obstacle')
│   └── "Thông tin & FAQ"    → push('/info')
├── 📜 Task list — TaskCard (tap → push('/medical/task', extra: task))
└── 🔽 ExpansionTile "Lịch sử hôm nay" → history TaskCards

📄 Pushed routes
├── /medical/task        → TaskDetailPage  (check-in/out, result, cancel)
├── /medical/queue       → QueuePage       (PoiPickerField → live status)
└── /medical/prescription → PrescriptionPage
```

:::note[Task actions moved to a detail page]
The per-task **check-in / check-out / result / cancel** actions used to live
inline on the list card. They now live on a dedicated `TaskDetailPage`
(`/medical/task`, the task passed via `state.extra`); the list `TaskCard` is
purely informational and taps through to detail. Each action runs, invalidates
`medicalTasksProvider` + `medicalHistoryProvider`, then pops back so the refreshed
list is visible. Action buttons are gated by status (`cancelled`/`completed`
tasks only expose "Kết quả").
:::

:::tip[Location picker over code entry]
`QueuePage` (and the wheelchair/staff flows) use the shared `PoiPickerField` /
`showPoiPicker` from the Map module, so users **select a location** from the
active map's POIs instead of typing a raw code.
:::

## State Taxonomy

- **Server State (Cached)**: `taskProvider`, `queueProvider`, and `prescriptionProvider`. These hold the source of truth fetched from the backend.
- **Local UI State**: Minor states like expanded/collapsed cards or internal list view scroll offsets.

## The Execution Lifecycle (Check-in Process)

import MedicalFlowDiagram from '@site/static/img/diagrams/medical-flow.svg';

<div style={{ textAlign: 'center', margin: '2rem 0' }}>
  <MedicalFlowDiagram width="100%" style={{ borderRadius: '16px', boxShadow: '0 4px 20px rgba(0,0,0,0.15)' }} />
</div>

The most critical flow is checking into a task. It now runs from `TaskDetailPage`
via a shared `_runAction` helper: call the repository, **invalidate** the task +
history providers, then pop back so the refreshed list is visible. This favors a
correct re-fetch over an optimistic local mutation.

### 1. 💻 Trigger (UI Layer)
The user opens a task (`TaskCard` → `push('/medical/task', extra: task)`) and taps "Check-in" on `TaskDetailPage`.
```dart
FilledButton.icon(
  onPressed: () => _runAction(
    context, ref,
    () => ref.read(medicalRepositoryProvider)
        .checkinRoom(treatmentId: task.treatmentId),
    'Check-in thành công',
  ),
  ...
)
```

### 2. 🌐 Execution (Repository Layer)
`_runAction` awaits the repository call, which hits the backend check-in endpoint.
```dart
await action(); // medicalRepository.checkinRoom(treatmentId: ...)
```

### 3. 🔄 Invalidate + pop (UI Layer)
On success it invalidates the cached providers so the list re-fetches the source
of truth, shows a confirmation snackbar, and pops back to the task list.
```dart
ref
  ..invalidate(medicalTasksProvider)
  ..invalidate(medicalHistoryProvider);
_showSnackBar(context, successMessage);
if (context.canPop()) context.pop();
```

### 4. ⚠️ Failure
Any thrown error is caught and surfaced as an error snackbar; the page stays open so the user can retry.

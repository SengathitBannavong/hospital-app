---
id: data-flow
title: Data Flow
sidebar_position: 5
---

# Data Flow

Our Flutter application strictly adheres to a unidirectional data flow. This pattern ensures that the UI is always a reflection of the current State, and changes to the State are predictable and trackable.

## The Cycle

1. **User Interaction**: The user interacts with the UI (e.g., taps a "Login" button).
2. **Provider Action**: The UI either calls a method on a Riverpod notifier
   (for example `ref.read(authStateProvider.notifier).login(phone, pass)`) or
   watches a `FutureProvider` for server state.
3. **Repository Execution**: The notifier or provider validates local state and
   calls the corresponding repository method.
4. **Network Request**: The Repository uses the global `Dio` HTTP client to communicate with the REST API.
5. **Data Parsing**: The Repository parses the raw JSON response into strongly typed Freezed models.
6. **State Mutation**: The provider receives the model and updates its exposed
   state, such as `AuthUser?`, `AsyncValue<T>`, or a simple `StateProvider`
   value.
7. **UI Rebuild**: The UI, which is listening to the provider with `ref.watch`,
   automatically rebuilds to reflect the new state.

## Diagram Representation

import GlobalFlowDiagram from '@site/static/img/diagrams/global-dataflow.svg';

<div style={{ textAlign: 'center', margin: '2rem 0' }}>
  <GlobalFlowDiagram width="100%" style={{ borderRadius: '16px', boxShadow: '0 4px 20px rgba(0,0,0,0.15)' }} />
</div>

## Error Handling Data Flow
- If the **API** fails, the **Repository** catches the `DioException` and throws a Domain-specific Error.
- A **Notifier** or **FutureProvider** surfaces the error as `AsyncValue.error`
  when it owns async state. For local page actions, the page catches the error
  and displays a toast.
- The **UI** listens to the error state and displays a `Toast` or Snackbar.

---
id: data-flow
title: Data Flow
sidebar_position: 5
---

# Data Flow

Our Flutter application strictly adheres to a unidirectional data flow. This pattern ensures that the UI is always a reflection of the current State, and changes to the State are predictable and trackable.

## The Cycle

1. **User Interaction**: The user interacts with the UI (e.g., taps a "Login" button).
2. **Provider Action**: The UI calls a method on a Riverpod Notifier (e.g., `ref.read(authProvider.notifier).login(email, pass)`).
3. **Repository Execution**: The Notifier validates local state and calls the corresponding Repository method (e.g., `authRepository.login()`).
4. **Network Request**: The Repository uses the global `Dio` HTTP client to communicate with the REST API.
5. **Data Parsing**: The Repository parses the raw JSON response into strongly typed Freezed models.
6. **State Mutation**: The Notifier receives the Model, mutates its internal state (e.g., updates `AsyncValue` to `.data(user)`).
7. **UI Rebuild**: The UI, which is listening to the Provider (`ref.watch(authProvider)`), automatically rebuilds to reflect the new state.

## Diagram Representation

import GlobalFlowDiagram from '@site/static/img/diagrams/global-dataflow.svg';

<div style={{ textAlign: 'center', margin: '2rem 0' }}>
  <GlobalFlowDiagram width="100%" style={{ borderRadius: '16px', boxShadow: '0 4px 20px rgba(0,0,0,0.15)' }} />
</div>

## Error Handling Data Flow
- If the **API** fails, the **Repository** catches the `DioException` and throws a Domain-specific Error.
- The **Notifier** catches this error and sets its state to `AsyncValue.error`.
- The **UI** listens to the error state and displays a `Toast` or Snackbar.

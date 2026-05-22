---
id: map
title: Map Module
sidebar_position: 3
---

# Map Module

The **Map Module** (`lib/features/map`) is the most technologically complex component of the application. It handles custom 2D grid rendering, graph-based pathfinding, and turn-by-turn simulated navigation within the hospital.

:::warning[Performance Considerations]
To ensure 60fps rendering even on lower-end devices, the map bypasses traditional Flutter Widget trees for its core view. Instead, it utilizes a custom `CustomPainter` (`MapGridPainter`) to paint directly to the canvas.
:::

## State Management

The module relies heavily on `map_provider.dart` to maintain granular state, separating view coordinates from active routing logic.

| Provider | Type | Description |
| :--- | :--- | :--- |
| `currentPositionProvider` | `StateProvider` | Tracks the "You are here" pin. Updatable via QR scan or long-press. |
| `destinationProvider` | `StateProvider` | Tracks the currently selected Point of Interest (POI). |
| `routeModeProvider` | `StateProvider` | Maintains the selected transportation mode (Walking, Wheelchair, Stretcher). |
| `activeNavigationProvider` | `StateNotifierProvider` | Manages the live state of a running simulation (animating dot, distance remaining, ETA). |

## Widget Types & Patterns

The Map module heavily relies on custom canvas painting over standard widget trees for optimal 60fps performance.

```text
📦 MapPage
├── 🏗️ Stack
│   ├── 🖌️ CustomPaint (MapGridPainter)
│   │   └── 🗺️ Renders Nodes, Edges, Route Path
│   ├── 🔍 SearchPanel (Floating Top)
│   ├── 🔘 FloatingActionButton (Recenter)
│   └── 🗂️ SlidingUpPanel (Route Details Sheet)
│       └── 🏗️ Column
│           ├── ⏱️ ETA Display
│           └── ⏯️ Playback Controls (Play/Pause)
└── 📷 Scanner Overlay (mobile_scanner)
```

## State Taxonomy

Due to the real-time requirements of navigation, state is highly granular:
- **Local UI State**: Minor animation tickers or sheet expansion statuses.
- **Provider State**: `currentPositionProvider` (User location), `destinationProvider` (Target POI), and `routeModeProvider` (Walking/Wheelchair).
- **Transient State**: `activeNavigationProvider` holds the high-frequency metrics (ETA, remaining distance) updated during simulation.

## The Execution Lifecycle (Route Preview)

import MapFlowDiagram from '@site/static/img/diagrams/map-flow.svg';

<div style={{ textAlign: 'center', margin: '2rem 0' }}>
  <MapFlowDiagram width="100%" style={{ borderRadius: '16px', boxShadow: '0 4px 20px rgba(0,0,0,0.15)' }} />
</div>

### 1. 💻 Trigger (UI Layer)
The user selects a destination POI from the search sheet and taps "Preview Route". The UI updates the target provider.
```dart
ref.read(destinationProvider.notifier).state = selectedPoi;
```

### 2. ⚙️ Orchestration (Provider Layer)
The UI triggers the repository to fetch the route data.
```dart
final routeData = await ref.read(mapRepositoryProvider).previewRoute(
  start: currentPos, 
  end: selectedPoi, 
  mode: currentMode
);
```

### 3. 🌐 Execution (Backend Layer)
The API calculates the A* or Dijkstra path over the cached graph, returning the sequence of nodes and a `speed_factor`.
```dart
// Backend response mapped to Freezed model
return RoutePreviewResponse.fromJson(response.data);
```

### 4. 🔄 Canvas Reactivity (Rendering Layer)
The Riverpod state is mutated with the new node array. The custom canvas, which actively watches the routing state, immediately triggers a high-performance repaint, drawing the highlighted path.
```dart
// Inside MapGridPainter
if (routeNodes != null) {
  _drawHighlightedPath(canvas, routeNodes);
}
```

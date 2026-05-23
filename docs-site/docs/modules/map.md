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

## Caching Architecture

To support resilient offline navigation inside the hospital, the Map module
employs a localized Hive-based cache. All cached objects are managed by
`MapCacheService` (`lib/features/map/data/services/map_cache_service.dart`) under
the `map_sync_full_cache` box.

### 1. Cached Elements

| Data Element | Cache Key Pattern | Description |
| :--- | :--- | :--- |
| **Sync Full** | `map:<mapId>:sync_full` | Entire bulk-synced graph snapshot. |
| **Floors** | `map:floors` | List of all floor metadata and grid dimensions. |
| **Granular Nodes** | `map:<mapId>:nodes` | Point of interest grid locations (`MapPoi`). |
| **Granular Edges** | `map:<mapId>:edges` | Walkable grid path links (`MapEdge`). |
| **Granular Meta** | `map:<mapId>:meta` | Floor configurations and boundaries. |
| **Obstacles** | `map:<mapId>:obstacles` | Dynamic path blockages and reports. |
| **Flow Snapshot** | `map:<mapId>:flow_snapshot` | Crowd density, edge congestion, and active alerts. |
| **Route Results** | `route:<mapId>:<start>:<dest>:<mode>` | Serialized calculated route paths. |
| **Active Route** | `route:active` | In-progress active guidance route path. |

### 2. Route Cache & Offline Replay Flow

When calculating routes, `RoutingService` optimizes for speed and reliability:

1. **Online (Network Available)**:
   * Requests a route preview from the remote backend.
   * On success, maps the response and caches the calculated `RouteResult`
     directional path under `route:<mapId>:<start>:<dest>:<mode>`.
   * Returns the live backend path.

2. **Offline (No Network) / Request Timeout**:
   * Attempts to load a previously cached `RouteResult` matching the precise
     `(mapId, start, dest, mode)` key.
   * If a cached route is found, it is replayed verbatim to preserve the exact
     same path returned online.
   * If a cache miss occurs, the system falls back to recalculating the path
     locally using the `RoutingEngine`'s Dijkstra pathfinding algorithm.

## Positioning Abstraction (`PositionSource`)

To facilitate seamless testing and future-proof the codebase for actual physical deployments, the Map module employs a polymorphic positioning abstraction. 

Because the hospital environment is an indoor space where GPS is unavailable, the current application version uses a **client-side simulation** to move the user along the active path. However, the navigation engine itself is completely decoupled from this simulation via the `PositionSource` abstraction.

### 1. Architectural Seam

By introducing a dedicated interface for positioning, the entire turn-by-turn guidance and dynamic rerouting logic consumes position updates uniformly, whether they originate from a simulated timer or future real-world hardware sensors.

```mermaid
classDiagram
    class PositionSource {
        <<abstract>>
        +int? currentLocation
        +double progress
    }
    class SimulatedPositionSource {
        +int? currentLocation
        +double progress
    }
    class RealSensorPositionSource {
        +int? currentLocation
        +double progress
    }
    PositionSource <|-- SimulatedPositionSource : implements
    PositionSource <|-- RealSensorPositionSource : implements (Future)
    
    class StepTracker {
        +track(PositionSource position, RouteResult route) StepTrackingState
    }
    class RerouteWatcher {
        +evaluate(PositionSource position, RouteResult route, edgeStatuses) RerouteDecision
    }
    class PassNodeReporter {
        +reportFrom(PositionSource position, RouteResult route) Future~void~
    }
    
    StepTracker --> PositionSource : consumes
    RerouteWatcher --> PositionSource : consumes
    PassNodeReporter --> PositionSource : consumes
```

### 2. Interface Definition

Defined in `lib/features/map/presentation/navigation/position_source.dart`:

```dart
abstract class PositionSource {
  /// The index of the current grid cell occupied by the user.
  /// Null if the user's position cannot be mapped to the grid.
  int? get currentLocation;

  /// Normalized value from 0.0 to 1.0 representing progress along the path.
  double get progress;
}
```

### 3. Implementations

* **`SimulatedPositionSource` (Current)**:
  Constructed by the navigation state notifier (Ticker-driven `NavigationController`). As the animation tick increases, it reports the interpolated cell index and fractional progress along the computed route.
  
* **`RealPositionSource` (Future Expansion)**:
  Will combine hardware inputs (e.g., Bluetooth Low Energy (BLE) beacon trilateration, Wi-Fi RTT, or UWB sensors) to determine the coordinates, run map-matching algorithms to snapping coordinates to the nearest valid walkable cell, and calculate progress relative to the active `RouteResult`.

### 4. Downstream Subsystems (Consumers)

The following components depend purely on the `PositionSource` contract, remaining agnostic to whether the user is physically walking or running a simulation:

| Subsystem | File Reference | Purpose |
| :--- | :--- | :--- |
| **Step Tracking** | [step_tracker.dart](file:///home/jerry/project/hospital-project/hospital-app/lib/features/map/presentation/navigation/step_tracker.dart) | Inspects the current path index to yield the current step, the next turn maneuver, and the distance remaining to the next instruction. |
| **Dynamic Rerouting** | [reroute_watcher.dart](file:///home/jerry/project/hospital-project/hospital-app/lib/features/map/presentation/navigation/reroute_watcher.dart) | Watches upcoming cells along the *remaining* path (starting from `PositionSource`'s current location). If any upcoming cell becomes congested or blocked, it triggers a recalculated detour. |
| **Telemetry Reporting** | [pass_node_reporter.dart](file:///home/jerry/project/hospital-project/hospital-app/lib/features/map/presentation/navigation/pass_node_reporter.dart) | Listens to the current position grid cell updates and pings the `route/pass_node` telemetry endpoint (queued locally when offline) to report travel milestones. |

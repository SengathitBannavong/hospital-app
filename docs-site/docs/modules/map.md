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

The module relies heavily on `map_provider.dart` to maintain granular state,
separating map data, search state, route preview state, and navigation
simulation state.

| Provider | Type | Description |
| :--- | :--- | :--- |
| `mapMetaProvider(mapId)` | `FutureProvider.family` | Fetches floor metadata such as `rows` and `cols`. |
| `mapNodesProvider(mapId)` | `FutureProvider.family` | Fetches POIs/nodes for the selected map. |
| `mapEdgesProvider(mapId)` | `FutureProvider.family` | Fetches graph edges and exposes their edge list. |
| `searchKeywordProvider` | `StateProvider` | Stores the current search input. |
| `searchResultsProvider(mapId)` | `FutureProvider.family` | Filters loaded POIs by normalized keyword. |
| `userPositionProvider` | `StateProvider` | Tracks the "You are here" grid location. It is set from the entrance fallback, QR scan, POI action, or long-press. |
| `locationSourceProvider` | `StateProvider` | Records how the current position was selected. |
| `routeDestProvider` | `StateProvider` | Tracks the selected destination POI. |
| `routeModeProvider` | `StateProvider` | Stores the selected route mode id, defaulting to `walking`. |
| `routeResultProvider` | `FutureProvider.autoDispose` | Calls `MapRepository.previewRoute` when start, destination, and mode are available. |
| `routeLocationsProvider` | `Provider.autoDispose` | Extracts a defensive list of grid locations from the route preview response. |
| `navPhaseProvider` | `StateProvider` | Tracks `idle`, `navigating`, `paused`, and `arrived`. |
| `navProgressProvider` | `StateProvider` | Tracks simulated route progress from `0.0` to `1.0`. |
| `navigationControllerProvider` | `Provider.autoDispose` | Owns the ticker-backed navigation simulation and updates nav state providers. |

## Widget Types & Patterns

The Map module heavily relies on custom canvas painting over standard widget trees for optimal 60fps performance.

```text
📦 MapPage
├── 🏗️ Stack
│   ├── 🖌️ CustomPaint (MapGridPainter)
│   │   └── 🗺️ Renders Nodes, Edges, Route Path
│   ├── 🔍 MapTopBar + MapSearchResultsPanel
│   ├── 🔘 FloatingActionButtons (QR, legend, recenter, route)
│   ├── 🧾 Modal bottom sheets (POI details, route options, legend)
│   └── 🧭 MapNavigationSheet (shown while navigating)
└── 📷 MapQrScannerPage (mobile_scanner)
```

## State Taxonomy

Due to the real-time requirements of navigation, state is highly granular:
- **Local UI State**: Search expansion, route sheet collapse, map transform, route
  reveal animation, and debug hit-test markers live in `MapPage`.
- **Provider State**: `userPositionProvider`, `routeDestProvider`,
  `routeModeProvider`, and the route/nav providers hold cross-widget map state.
- **Transient Navigation State**: `NavigationController` owns the ticker and
  updates `navPhaseProvider`, `navProgressProvider`,
  `navMetersRemainingProvider`, and `navSecondsRemainingProvider`.

## The Execution Lifecycle (Route Preview)

import MapFlowDiagram from '@site/static/img/diagrams/map-flow.svg';

<div style={{ textAlign: 'center', margin: '2rem 0' }}>
  <MapFlowDiagram width="100%" style={{ borderRadius: '16px', boxShadow: '0 4px 20px rgba(0,0,0,0.15)' }} />
</div>

### 1. 💻 Trigger (UI Layer)
The user selects a destination POI from search, a POI detail sheet, or the route
picker. The UI updates the route destination provider.
```dart
ref.read(routeDestProvider.notifier).state = selectedPoi;
```

### 2. ⚙️ Orchestration (Provider Layer)
`routeResultProvider` reacts to the start position, destination, and route mode.
```dart
return repository.previewRoute(
  startLocation: start,
  destLocation: dest.gridLocation,
  modeId: mode,
);
```

### 3. 🌐 Execution (Backend Layer)
The API calculates the route and returns route data. The app currently parses
the response defensively because `route/preview` may expose the path under
different keys (`steps`, `path`, `path_locations`, `locations`, or `nodes`).
```dart
final apiResponse = AuthApiResponse<dynamic>.fromJson(
  response.data,
  (json) => json,
);
```

### 4. 🔄 Canvas Reactivity (Rendering Layer)
`routeLocationsProvider` extracts grid locations from the preview response.
`MapPage` passes those locations and the current navigation dot to
`MapGridPainter`.
```dart
MapGridPainter(
  routeLocations: routeLocations,
  userDot: navDot,
  navProgress: navProgress,
)
```

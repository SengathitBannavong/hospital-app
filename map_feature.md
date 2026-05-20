# Map Feature Checklist

Target branch: `feat/map`

Last checked: 2026-05-14

## Current Evidence

- `swagger.yaml` defines the public map floor endpoint: `GET /api/map/get_floors`.
- `swagger.yaml` does not hardcode the number of floors; it only documents the endpoint as `Danh sách tầng`.
- `map_reponse_data.txt` contains a saved successful response for `GET /api/map/get_floors` with 2 entries:
  - `map_id: 1`, `map_name: Hospital Main Floor`, `rows: 33`, `cols: 57`
  - `map_id: 7`, `map_name: test_map`, `rows: 10`, `cols: 10`
- Current Flutter map UI uses only one hardcoded map: `_defaultMapId = 1` in `lib/features/map/presentation/pages/map_page.dart`.

## Existing Map Implementation

- [x] Map feature folder exists: `lib/features/map/`.
- [x] Map data models exist for floors, POIs, edges, sync, route history, route mode, and route clear history.
- [x] Map repository exists: `lib/features/map/data/map_repository.dart`.
- [x] Repository supports `getFloors()`.
- [x] Repository supports `getMeta(mapId)`.
- [x] Repository supports `getNodes(mapId)`.
- [x] Repository supports `getEdges(mapId)`.
- [x] Repository supports `searchLocation(keyword, mapId)`.
- [x] Repository supports `getLandmarks(mapId)`.
- [x] Repository supports `syncFull(mapId)`.
- [x] Repository supports route mode, preview, order, multi-order, unordered order, history, and clear history APIs.
- [x] Map providers exist in `lib/features/map/presentation/providers/map_provider.dart`.
- [x] Grid rendering exists through `MapGridPainter`.
- [x] POIs are drawn on a grid.
- [x] Walkable cells are derived from edges.
- [x] POI lookup by cell exists.
- [x] Search keyword provider exists.
- [x] Search results provider exists.
- [x] Route start and destination state providers exist.
- [x] Route mode provider exists.
- [x] Route preview provider exists.
- [x] Route locations extraction helper exists.
- [x] Map page supports zoom/pan through `InteractiveViewer`.
- [x] Map page supports POI tap and metadata bottom sheet.
- [x] Map page supports choosing route start/destination from POI sheet.
- [x] Map page supports search and picking route points from search results.
- [x] Map page supports route preview rendering/animation.
- [x] Map page supports legend and recenter controls.
- [x] Map tests exist under `test/features/map/`.

## Missing Or Incomplete

- [ ] Floor switching UI is not implemented.
- [ ] Active `mapId` is hardcoded to `1`.
- [ ] `getFloors()` is not currently used by `MapPage`.
- [ ] Search, POI lookup, metadata, edges, and route preview need to react to selected floor/map.
- [ ] Route start/destination should reset or validate when the user switches floor.
- [ ] Loading/error UI for floor list should be added.
- [ ] Empty floor list state should be handled.
- [ ] Route preview error state should be visible to the user.
- [ ] Route order/history APIs are not exposed in UI.
- [ ] Active navigation/turn-by-turn mode is not implemented; current behavior is route preview plus animated path.

## Recommended `feat/map` Scope

1. Add selected map/floor state.
2. Fetch floors using `MapRepository.getFloors()`.
3. Show floor switcher in `MapPage`.
4. Replace `_defaultMapId` usage with selected floor `mapId`.
5. Make meta, nodes, edges, search, route, POI lookup, and walkable cells depend on selected `mapId`.
6. Clear route and search state on floor change.
7. Add loading, error, and empty states for floor switching.
8. Add or update tests for selected floor state and route reset behavior.

## Implementation Checklist

- [ ] Create a selected floor/map provider, for example `selectedMapIdProvider`.
- [ ] Add a floors provider using `MapRepository.getFloors()`.
- [ ] Update `MapPage` to watch selected map id instead of `_defaultMapId`.
- [ ] Replace all `mapMetaProvider(_defaultMapId)` calls.
- [ ] Replace all `mapNodesProvider(_defaultMapId)` calls.
- [ ] Replace all `mapEdgesProvider(_defaultMapId)` calls.
- [ ] Replace all `searchResultsProvider(_defaultMapId)` calls.
- [ ] Replace all `poiByCellProvider(_defaultMapId)` calls.
- [ ] Replace all `normalizedPoiNamesProvider(_defaultMapId)` calls.
- [ ] Replace all `walkableCellsProvider(_defaultMapId)` calls.
- [ ] Add a compact floor selector UI near the map top bar or route controls.
- [ ] Clear `routeStartProvider` and `routeDestProvider` on floor change.
- [ ] Clear `searchKeywordProvider` and search text controller on floor change.
- [ ] Invalidate route preview when floor changes.
- [ ] Handle floor API loading state.
- [ ] Handle floor API error state with retry.
- [ ] Handle no floors available.
- [ ] Confirm `map_id: 1` and `map_id: 7` both render correctly with their own metadata.
- [ ] Run `dart format lib/features/map test/features/map`.
- [ ] Run `dart analyze lib/features/map test/features/map`.
- [ ] Run `flutter test test/features/map`.

## Manual QA

- [ ] Open Map tab.
- [ ] Confirm first available floor loads.
- [ ] Switch to `Hospital Main Floor`.
- [ ] Confirm grid size is `33 x 57`.
- [ ] Search for a POI on `Hospital Main Floor`.
- [ ] Pick route start and destination on `Hospital Main Floor`.
- [ ] Confirm route preview renders.
- [ ] Switch to `test_map`.
- [ ] Confirm grid size changes to `10 x 10`.
- [ ] Confirm old route is cleared after floor switch.
- [ ] Search for a POI on `test_map`.
- [ ] Confirm POI taps still open metadata sheet.
- [ ] Confirm legend and recenter controls still work.

## Suggested Commit Plan

- [ ] Commit 1: add selected floor providers and wire floor list.
- [ ] Commit 2: replace hardcoded map id in `MapPage`.
- [ ] Commit 3: add floor switcher UI and state reset behavior.
- [ ] Commit 4: add tests and final polish.

## Useful Commands

```bash
git checkout -b feat/map
dart format lib/features/map test/features/map
dart analyze lib/features/map test/features/map
flutter test test/features/map
git status --short
```

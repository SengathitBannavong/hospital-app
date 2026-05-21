import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/features/map/data/models/edge_status.dart';
import 'package:hospital_app/features/map/data/models/location_source.dart';
import 'package:hospital_app/features/map/data/models/map_poi.dart';
import 'package:hospital_app/features/map/data/models/nav_state.dart';
import 'package:hospital_app/features/map/presentation/controllers/navigation_controller.dart';
import 'package:hospital_app/features/map/presentation/pages/map_qr_scanner_page.dart';
import 'package:hospital_app/features/map/presentation/providers/map_provider.dart';
import 'package:hospital_app/features/map/presentation/theme/map_tokens.dart';
import 'package:hospital_app/features/map/presentation/utils/search_utils.dart';
import 'package:hospital_app/features/map/presentation/widgets/map_grid_painter.dart';
import 'package:hospital_app/features/map/presentation/widgets/map_legend_sheet.dart';
import 'package:hospital_app/features/map/presentation/widgets/map_navigation_sheet.dart';
import 'package:hospital_app/features/map/presentation/widgets/map_poi_metadata_panel.dart';
import 'package:hospital_app/features/map/presentation/widgets/map_route_panel.dart';
import 'package:hospital_app/features/map/presentation/widgets/map_search_results_panel.dart';
import 'package:hospital_app/features/map/presentation/widgets/map_top_bar.dart';

// debug
// import 'package:hospital_app/features/map/presentation/widgets/map_debug_grid_painter.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage>
    with SingleTickerProviderStateMixin {
  static const int _defaultMapId = 1;
  static const int _defaultRows = 33;
  static const int _defaultCols = 57;
  static const double _minMapScale = 1;
  static const double _maxMapScale = 4;
  static const Duration _searchDebounceDuration = Duration(milliseconds: 500);

  late final TextEditingController _searchController;
  Timer? _searchDebounceTimer;
  late final AnimationController _routeAnim;
  TransformationController? _transformController;
  Size _lastViewportSize = Size.zero;
  Size _lastGridSize = Size.zero;
  double _lastMinScale = 0;
  int _lastRouteSignature = 0;
  bool _searchExpanded = true;
  bool _arrivalOrderCommitted = false;
  bool _navCollapsed = false;
  bool _rerouteInFlight = false;
  final Set<String> _detouredEdgeKeys = <String>{};
  final bool _showDebugHitTest = kDebugMode;
  Offset? _debugTapScene;
  Offset? _debugPoiCenter;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController()..addListener(_onSearchChanged);
    _routeAnim = AnimationController(
      vsync: this,
      duration: MapMotion.long,
      value: 1,
    );
    _ensureTransformController();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    _searchDebounceTimer?.cancel();
    _routeAnim.dispose();
    _transformController?.dispose();
    _transformController = null;
    super.dispose();
  }

  void _onSearchChanged() {
    _setSearchKeyword(_searchController.text);
  }

  void _setSearchKeyword(String value, {bool immediate = false}) {
    _searchDebounceTimer?.cancel();
    if (immediate || value.trim().isEmpty) {
      ref.read(searchKeywordProvider.notifier).state = value;
      return;
    }
    _searchDebounceTimer = Timer(_searchDebounceDuration, () {
      if (!mounted) return;
      ref.read(searchKeywordProvider.notifier).state = value;
    });
  }

  TransformationController _ensureTransformController() {
    final existing = _transformController;
    if (existing != null) return existing;
    final controller = TransformationController();
    _transformController = controller;
    return controller;
  }

  void _syncTransformToLayout({
    required Size viewportSize,
    required Size gridSize,
    required double minScale,
  }) {
    if (_lastViewportSize == viewportSize &&
        _lastGridSize == gridSize &&
        _lastMinScale == minScale) {
      return;
    }
    _lastViewportSize = viewportSize;
    _lastGridSize = gridSize;
    _lastMinScale = minScale;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = _transformController;
      if (controller == null) return;
      final current = controller.value;
      final scale = current.getMaxScaleOnAxis().clamp(minScale, _maxMapScale);
      final tx = _clampTranslate(
        current.storage[12],
        viewportSize.width,
        gridSize.width * scale,
      );
      final ty = _clampTranslate(
        current.storage[13],
        viewportSize.height,
        gridSize.height * scale,
      );
      controller.value = Matrix4.identity()
        ..translateByDouble(tx, ty, 0, 1)
        ..scaleByDouble(scale, scale, 1, 1);
    });
  }

  void _maybeAnimateRoute(List<int> routeLocations) {
    final sig = routeLocations.isEmpty ? 0 : Object.hashAll(routeLocations);
    if (sig == _lastRouteSignature) return;
    _lastRouteSignature = sig;
    if (routeLocations.isEmpty) {
      _routeAnim.value = 0;
    } else {
      _routeAnim
        ..value = 0
        ..forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final metaAsync = ref.watch(mapMetaProvider(_defaultMapId));
    final nodesLoading = ref.watch(
      mapNodesProvider(_defaultMapId).select((a) => a.isLoading),
    );
    final edgesLoading = ref.watch(
      mapEdgesProvider(_defaultMapId).select((a) => a.isLoading),
    );
    final keyword = ref.watch(searchKeywordProvider);
    final searchResultsAsync = ref.watch(searchResultsProvider(_defaultMapId));
    final userPosition = ref.watch(userPositionProvider);
    final userPositionPoi = ref.watch(
      poiByCellProvider(_defaultMapId),
    )[userPosition];
    final dest = ref.watch(routeDestProvider);
    final routeResultAsync = ref.watch(activeRouteResultProvider);
    final nodes =
        ref.watch(mapNodesProvider(_defaultMapId)).value ?? const <MapPoi>[];
    final walkable = ref.watch(walkableCellsProvider(_defaultMapId));
    final rows = metaAsync.value?.rows ?? _defaultRows;
    final cols = metaAsync.value?.cols ?? _defaultCols;
    final routeLocations = ref.watch(routeLocationsProvider);
    final navDot = ref.watch(navDotProvider);
    final navPhase = ref.watch(navPhaseProvider);
    final navProgress = ref.watch(navProgressProvider);
    final flowVisible = ref.watch(flowOverlayVisibleProvider);
    final flowSnapshot = ref.watch(flowSnapshotProvider(_defaultMapId));
    final flow = flowSnapshot.valueOrNull;
    ref.watch(navigationControllerProvider);
    final defaultUserPosition = ref.watch(
      defaultUserPositionProvider(_defaultMapId),
    );

    if (userPosition == null && defaultUserPosition != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || ref.read(userPositionProvider) != null) return;
        ref.read(userPositionProvider.notifier).state = defaultUserPosition;
      });
    }

    ref
      ..listen<NavPhase>(navPhaseProvider, (_, next) {
        if (next == NavPhase.navigating) {
          _routeAnim.value = 1;
        } else if (next == NavPhase.arrived) {
          _handleNavigationArrived();
        }
      })
      ..listen<double>(navProgressProvider, (_, _) {
        if (ref.read(navPhaseProvider) != NavPhase.navigating) return;
        _followNavigationDot(rows: rows, cols: cols);
      })
      ..listen(activeRouteResultProvider, (_, next) {
        ref.read(passNodeReporterProvider).syncRoute(next.valueOrNull);
      })
      ..listen(positionSourceProvider, (_, next) {
        if (ref.read(navPhaseProvider) != NavPhase.navigating) return;
        final route = ref.read(activeRouteResultProvider).valueOrNull;
        unawaited(ref.read(passNodeReporterProvider).reportFrom(next, route));
      })
      ..listen(flowEdgeStatusMapProvider(_defaultMapId), (_, next) {
        if (ref.read(navPhaseProvider) != NavPhase.navigating) return;
        unawaited(_maybeReroute(next));
      });

    if (navPhase == NavPhase.navigating && _routeAnim.value != 1) {
      _routeAnim.value = 1;
    } else if (navPhase != NavPhase.navigating) {
      _maybeAnimateRoute(routeLocations);
    }

    final loading = metaAsync.isLoading || nodesLoading || edgesLoading;
    final searching = keyword.trim().isNotEmpty;
    final mediaTop = MediaQuery.of(context).padding.top;
    final mediaBottom = MediaQuery.of(context).padding.bottom;

    final hasRoute = dest != null;
    final showNavigationSheet =
        navPhase == NavPhase.navigating ||
        navPhase == NavPhase.paused ||
        navPhase == NavPhase.arrived;

    return Scaffold(
      backgroundColor: MapSurface.background,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            // Keep the map viewport above the system navigation bar so POIs
            // along the bottom edge stay tappable.
            bottom: mediaBottom,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cellWidth = constraints.maxWidth / cols;
                final cellHeight = constraints.maxHeight / rows;
                final cellSize = math.max(cellWidth, cellHeight);
                final gridWidth = cols * cellSize;
                final gridHeight = rows * cellSize;
                const minScale = _minMapScale;

                final controller = _ensureTransformController();
                _syncTransformToLayout(
                  viewportSize: Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  ),
                  gridSize: Size(gridWidth, gridHeight),
                  minScale: minScale,
                );

                return InteractiveViewer(
                  transformationController: controller,
                  alignment: Alignment.topLeft,
                  clipBehavior: Clip.hardEdge,
                  constrained: false,
                  minScale: minScale,
                  maxScale: _maxMapScale,
                  boundaryMargin: EdgeInsets.zero,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) =>
                        _handleTap(details.localPosition, rows, cols, cellSize),
                    onLongPressStart: (details) => _handleLongPressStart(
                      details.localPosition,
                      rows,
                      cols,
                      cellSize,
                    ),
                    child: SizedBox(
                      width: gridWidth,
                      height: gridHeight,
                      child: RepaintBoundary(
                        child: AnimatedBuilder(
                          animation: Listenable.merge([controller, _routeAnim]),
                          builder: (context, _) {
                            final visibleRect = _visibleRectFor(
                              controller.value,
                              Size(constraints.maxWidth, constraints.maxHeight),
                              Size(gridWidth, gridHeight),
                            );
                            return CustomPaint(
                              size: Size(gridWidth, gridHeight),
                              painter: MapGridPainter(
                                rows: rows,
                                cols: cols,
                                walkableLocations: walkable,
                                pois: nodes,
                                flowCells: flow?.cells ?? const [],
                                showFlowOverlay: flowVisible,
                                routeLocations: routeLocations,
                                routeProgress: _routeAnim.value,
                                userDot: navDot,
                                navProgress: navProgress,
                                visibleRect: visibleRect,
                                debugTap: _debugTapScene,
                                debugPoiCenter: _debugPoiCenter,
                                showDebug: _showDebugHitTest,
                              ),
                              // foregroundPainter: MapDebugGridPainter(
                              //   rows: rows,
                              //   cols: cols,
                              //   visibleRect: visibleRect,
                              //   // labelCells: true,
                              // ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Top: collapsible search
          Positioned(
            top: mediaTop + AppSpacing.md,
            left: AppSpacing.md,
            right: AppSpacing.md,
            child: AnimatedSize(
              duration: MapMotion.medium,
              curve: MapMotion.resize,
              alignment: Alignment.topRight,
              child: _searchExpanded
                  ? Column(
                      key: const ValueKey('search-expanded'),
                      children: [
                        MapTopBar(
                          controller: _searchController,
                          isLoading: loading,
                          onCollapse: () => setState(() {
                            _searchController.clear();
                            _setSearchKeyword('', immediate: true);
                            _searchExpanded = false;
                          }),
                        ),
                        AnimatedSwitcher(
                          duration: MapMotion.medium,
                          switchInCurve: MapMotion.enter,
                          switchOutCurve: MapMotion.enter,
                          child: searching
                              ? Padding(
                                  key: const ValueKey('results'),
                                  padding: const EdgeInsets.only(
                                    top: AppSpacing.sm,
                                  ),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxHeight: 320,
                                    ),
                                    child: MapSearchResultsPanel(
                                      results: searchResultsAsync,
                                      query: keyword.trim(),
                                      suggestions: nodes.take(3).toList(),
                                      onSelect: _selectPoiFromSearch,
                                      onRetry: () => ref.invalidate(
                                        searchResultsProvider(_defaultMapId),
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(key: ValueKey('idle')),
                        ),
                      ],
                    )
                  : Align(
                      key: const ValueKey('search-collapsed'),
                      alignment: Alignment.topRight,
                      child: _MapFab(
                        icon: Icons.search_rounded,
                        tooltip: 'Search',
                        onPressed: () => setState(() => _searchExpanded = true),
                      ),
                    ),
            ),
          ),

          // Top-left: route progress pill (only when route in progress)
          if (hasRoute)
            Positioned(
              top: mediaTop + AppSpacing.md + 52,
              left: AppSpacing.md,
              child: _RoutePill(
                startName: userPositionPoi?.poiName ?? 'You are here',
                dest: dest,
                onTap: _showRoutePanel,
                onClear: _clearRoute,
                onDone: (userPosition != null && routeResultAsync.hasValue)
                    ? _completeRoute
                    : null,
              ),
            ),

          if (flow != null && (flow.alerts.isNotEmpty || flow.isStale))
            Positioned(
              top: mediaTop + AppSpacing.md + 104,
              left: AppSpacing.md,
              right: AppSpacing.md,
              child: _FlowAlertBanner(
                isStale: flow.isStale,
                updatedAt: flow.updatedAt,
                message: flow.alerts.isEmpty ? null : flow.alerts.first.message,
              ),
            ),

          if (flowVisible)
            Positioned(
              left: AppSpacing.md,
              bottom: mediaBottom + 204,
              child: _FlowLegend(isStale: flow?.isStale ?? false),
            ),

          // Bottom-left FAB cluster: legend + recenter
          Positioned(
            left: AppSpacing.md,
            bottom: mediaBottom + AppSpacing.md,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MapFab(
                  icon: Icons.qr_code_scanner_rounded,
                  tooltip: 'Scan QR code',
                  onPressed: _showQrScanner,
                ),
                const SizedBox(height: AppSpacing.sm),
                _MapFab(
                  icon: Icons.map_outlined,
                  tooltip: 'Map legend',
                  onPressed: _showLegend,
                ),
                const SizedBox(height: AppSpacing.sm),
                _MapFab(
                  icon: flowVisible
                      ? Icons.thermostat_rounded
                      : Icons.thermostat_outlined,
                  tooltip: flowVisible ? 'Hide flow heatmap' : 'Show heatmap',
                  onPressed: () {
                    ref.read(flowOverlayVisibleProvider.notifier).state =
                        !flowVisible;
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                _MapFab(
                  icon: Icons.center_focus_strong_rounded,
                  tooltip: 'Recenter',
                  onPressed: _recenter,
                ),
              ],
            ),
          ),

          if (showNavigationSheet && dest != null)
            // Compact card anchored bottom-right so the map stays visible.
            // Collapses to a small button when the user wants it hidden.
            Positioned(
              right: AppSpacing.md,
              bottom: mediaBottom + AppSpacing.md,
              child: _navCollapsed
                  ? _MapFab(
                      icon: Icons.navigation_rounded,
                      tooltip: 'Show navigation',
                      onPressed: () => setState(() => _navCollapsed = false),
                    )
                  : MapNavigationSheet(
                      destinationName: dest.poiName,
                      onDone: _handleNavigationDone,
                      onStop: _stopNavigation,
                      onCollapse: () => setState(() => _navCollapsed = true),
                    ),
            )
          else if (dest != null &&
              userPosition != null &&
              routeResultAsync.hasValue)
            // Route is ready: one-tap Start, with a small Route options button
            // above it for changing the mode or clearing.
            Positioned(
              right: AppSpacing.md,
              bottom: mediaBottom + AppSpacing.md,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _MapFab(
                    icon: Icons.tune_rounded,
                    tooltip: 'Route options',
                    onPressed: _showRoutePanel,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FloatingActionButton.extended(
                    heroTag: 'map-start-fab',
                    onPressed: _startNavigation,
                    icon: const Icon(Icons.navigation_rounded),
                    label: const Text('Start'),
                  ),
                ],
              ),
            )
          else
            // Bottom-right: route plan FAB
            Positioned(
              right: AppSpacing.md,
              bottom: mediaBottom + AppSpacing.md,
              child: FloatingActionButton.extended(
                heroTag: 'map-route-fab',
                onPressed: _showRoutePanel,
                icon: Icon(
                  hasRoute
                      ? Icons.edit_location_alt_rounded
                      : Icons.alt_route_rounded,
                ),
                label: Text(hasRoute ? 'Route' : 'Plan route'),
              ),
            ),
        ],
      ),
    );
  }

  void _handleTap(Offset scenePosition, int rows, int cols, double cellSize) {
    final byCell = ref.read(poiByCellProvider(_defaultMapId));
    if (byCell.isEmpty) return;
    final tapCol = (scenePosition.dx / cellSize).floor();
    final tapRow = (scenePosition.dy / cellSize).floor();
    MapPoi? nearest;
    Offset? nearestCenter;
    double bestDistanceSq = double.infinity;
    for (var dr = -1; dr <= 1; dr++) {
      final row = tapRow + dr;
      if (row < 0 || row >= rows) continue;
      for (var dc = -1; dc <= 1; dc++) {
        final col = tapCol + dc;
        if (col < 0 || col >= cols) continue;
        final poi = byCell[row * cols + col];
        if (poi == null) continue;
        final center = _poiCenter(poi, cellSize, cellSize);
        final dx = center.dx - scenePosition.dx;
        final dy = center.dy - scenePosition.dy;
        final distSq = dx * dx + dy * dy;
        if (distSq < bestDistanceSq) {
          bestDistanceSq = distSq;
          nearest = poi;
          nearestCenter = center;
        }
      }
    }
    if (_showDebugHitTest) {
      setState(() {
        _debugTapScene = scenePosition;
        _debugPoiCenter = nearestCenter;
      });
    }
    final maxR = cellSize * 1.2;
    if (nearest == null || bestDistanceSq > maxR * maxR) return;
    _showPoiSheet(nearest);
  }

  void _handleLongPressStart(
    Offset scenePosition,
    int rows,
    int cols,
    double cellSize,
  ) {
    final tapCol = (scenePosition.dx / cellSize).floor();
    final tapRow = (scenePosition.dy / cellSize).floor();
    if (tapRow < 0 || tapRow >= rows || tapCol < 0 || tapCol >= cols) {
      return;
    }

    final walkable = ref.read(walkableCellsProvider(_defaultMapId));
    final tappedLocation = tapRow * cols + tapCol;
    final location = walkable.contains(tappedLocation)
        ? tappedLocation
        : _nearestWalkableInNeighborhood(
            scenePosition,
            tapRow,
            tapCol,
            rows,
            cols,
            cellSize,
            walkable,
          );
    if (location == null) return;

    ref.read(navigationControllerProvider).stop();
    ref.read(userPositionProvider.notifier).state = location;
    ref.read(locationSourceProvider.notifier).state =
        LocationSource.simulatedPin;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('You are here')));
  }

  int? _nearestWalkableInNeighborhood(
    Offset scenePosition,
    int tapRow,
    int tapCol,
    int rows,
    int cols,
    double cellSize,
    Set<int> walkable,
  ) {
    int? nearest;
    double bestDistanceSq = double.infinity;
    for (var dr = -1; dr <= 1; dr++) {
      final row = tapRow + dr;
      if (row < 0 || row >= rows) continue;
      for (var dc = -1; dc <= 1; dc++) {
        final col = tapCol + dc;
        if (col < 0 || col >= cols) continue;
        final location = row * cols + col;
        if (!walkable.contains(location)) continue;
        final center = Offset(
          col * cellSize + cellSize / 2,
          row * cellSize + cellSize / 2,
        );
        final dx = center.dx - scenePosition.dx;
        final dy = center.dy - scenePosition.dy;
        final distSq = dx * dx + dy * dy;
        if (distSq < bestDistanceSq) {
          bestDistanceSq = distSq;
          nearest = location;
        }
      }
    }
    return nearest;
  }

  Future<void> _showPoiSheet(MapPoi poi) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: false,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: MapPoiMetadataPanel(
            poi: poi,
            onClose: () => Navigator.of(sheetContext).maybePop(),
            onSetDestination: () {
              Navigator.of(sheetContext).maybePop();
              _setRouteDestination(poi);
            },
            onSetCurrentLocation: poi.isLandmark
                ? () {
                    Navigator.of(sheetContext).maybePop();
                    _setCurrentLocationFromPoi(poi);
                  }
                : null,
          ),
        );
      },
    );
  }

  Rect _visibleRectFor(Matrix4 transform, Size viewport, Size grid) {
    final scale = transform.getMaxScaleOnAxis();
    if (scale <= 0) return Rect.fromLTWH(0, 0, grid.width, grid.height);
    final tx = transform.storage[12];
    final ty = transform.storage[13];
    final left = (-tx / scale).clamp(0.0, grid.width);
    final top = (-ty / scale).clamp(0.0, grid.height);
    final right = ((viewport.width - tx) / scale).clamp(0.0, grid.width);
    final bottom = ((viewport.height - ty) / scale).clamp(0.0, grid.height);
    return Rect.fromLTRB(left, top, right, bottom);
  }

  void _setCurrentLocationFromPoi(MapPoi poi) {
    ref.read(navigationControllerProvider).stop();
    ref.read(userPositionProvider.notifier).state = poi.gridLocation;
    ref.read(locationSourceProvider.notifier).state = LocationSource.manual;
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text("You are here · ${poi.poiName}")));
  }

  void _selectPoiFromSearch(MapPoi poi) {
    _setRouteDestination(poi);
    _searchController.clear();
    _setSearchKeyword('', immediate: true);
  }

  void _clearRoute() {
    ref.read(navigationControllerProvider).stop();
    _arrivalOrderCommitted = false;
    _resetRerouteState();
    ref.read(routeDestProvider.notifier).state = null;
    setState(() {});
  }

  void _completeRoute() {
    ref.read(navigationControllerProvider).stop();
    _arrivalOrderCommitted = false;
    _resetRerouteState();
    ref.read(routeDestProvider.notifier).state = null;
    ref.invalidate(routeResultProvider);
    setState(() {});
  }

  void _recenter() {
    final controller = _transformController;
    if (controller == null) return;
    controller.value = Matrix4.identity()
      ..scaleByDouble(_minMapScale, _minMapScale, 1, 1);
  }

  Future<void> _showLegend() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: false,
      builder: (_) => const MapLegendSheet(),
    );
  }

  Future<void> _showQrScanner() async {
    final positioned = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const MapQrScannerPage(mapId: _defaultMapId),
      ),
    );
    if (!mounted || positioned != true) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('You are here')));
  }

  Future<void> _showRoutePanel() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: false,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Consumer(
          builder: (context, ref, _) {
            final userPosition = ref.watch(userPositionProvider);
            final userPositionPoi = ref.watch(
              poiByCellProvider(_defaultMapId),
            )[userPosition];
            final dest = ref.watch(routeDestProvider);
            final mode = ref.watch(routeModeProvider);
            final routeResult = ref.watch(activeRouteResultProvider);
            final routeLocations = ref.watch(routeLocationsProvider);
            final nodes =
                ref.watch(mapNodesProvider(_defaultMapId)).value ??
                const <MapPoi>[];
            return SafeArea(
              top: false,
              child: MapRoutePanel(
                userPosition: userPosition,
                userPositionName: userPositionPoi?.poiName,
                dest: dest,
                mode: mode,
                routeResult: routeResult,
                routeLocations: routeLocations,
                onClear: () {
                  _clearRoute();
                  Navigator.of(sheetContext).maybePop();
                },
                onModeChanged: (v) => _setRouteMode(v),
                onPickDestination: () => _showRoutePoiPicker(nodes),
                onStartNavigation:
                    userPosition != null && dest != null && routeResult.hasValue
                    ? () {
                        if (_startNavigation()) {
                          Navigator.of(sheetContext).maybePop();
                        }
                      }
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showRoutePoiPicker(List<MapPoi> pois) async {
    final normalized = ref.read(normalizedPoiNamesProvider(_defaultMapId));
    final selected = await showModalBottomSheet<MapPoi>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _RoutePoiPickerSheet(
        title: 'Pick a destination',
        pois: pois,
        normalizedNames: normalized,
      ),
    );
    if (!mounted || selected == null) return;
    _setRouteDestination(selected);
  }

  void _setRouteDestination(MapPoi poi) {
    ref.read(navigationControllerProvider).stop();
    _resetRerouteState();
    final start = ref.read(userPositionProvider);
    ref.read(routeDestProvider.notifier).state = poi;
    if (start == poi.gridLocation) {
      ref.read(routeDestProvider.notifier).state = null;
    }
    setState(() {});
  }

  void _setRouteMode(String mode) {
    ref.read(navigationControllerProvider).stop();
    _resetRerouteState();
    ref.read(routeModeProvider.notifier).state = mode;
  }

  void _resetRerouteState() {
    _rerouteInFlight = false;
    _detouredEdgeKeys.clear();
    ref.read(rerouteResultProvider.notifier).state = null;
  }

  Future<void> _maybeReroute(Map<String, EdgeStatus> edgeStatuses) async {
    if (_rerouteInFlight || edgeStatuses.isEmpty) {
      return;
    }

    final route = ref.read(activeRouteResultProvider).valueOrNull;
    final position = ref.read(positionSourceProvider);
    final decision = ref.read(rerouteWatcherProvider).evaluate(
          routeResult: route,
          position: position,
          edgeStatuses: edgeStatuses,
          ignoredEdgeKeys: _detouredEdgeKeys,
        );
    final edgeKey = decision.edgeKey;
    if (!decision.shouldReroute || edgeKey == null) {
      return;
    }

    _rerouteInFlight = true;
    _detouredEdgeKeys.add(edgeKey);

    try {
      final currentLocation =
          position.currentLocation ??
          ref.read(navigationControllerProvider).currentLocationApprox;
      final dest = ref.read(routeDestProvider);
      if (currentLocation == null || dest == null) {
        return;
      }

      final meta = await ref.read(mapMetaProvider(_defaultMapId).future);
      await ref.read(mapEdgesProvider(_defaultMapId).future);
      final adjacency = ref.read(adjacencyProvider(_defaultMapId));
      final mode = ref.read(routeModeProvider);
      final reroute = await ref.read(routingServiceProvider).reroute(
            currentLocation: currentLocation,
            destLocation: dest.gridLocation,
            modeId: mode,
            adjacency: adjacency,
            cols: meta.cols,
            edgeStatuses: edgeStatuses,
          );
      if (reroute.path.length < 2) {
        _showRerouteSnack('No detour is available');
        return;
      }

      ref.read(userPositionProvider.notifier).state = currentLocation;
      ref.read(rerouteResultProvider.notifier).state = reroute;
      _routeAnim.value = 1;
      final reseated = ref.read(navigationControllerProvider).start();
      if (!reseated) {
        _showRerouteSnack('No detour is available');
        return;
      }
      _showRerouteSnack('Route blocked. Detour applied.');
    } catch (_) {
      _showRerouteSnack('No detour is available');
    } finally {
      _rerouteInFlight = false;
    }
  }

  void _showRerouteSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  bool _startNavigation() {
    _arrivalOrderCommitted = false;
    _navCollapsed = false;
    _resetRerouteState();
    _routeAnim.value = 1;
    final started = ref.read(navigationControllerProvider).start();
    if (!started) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Route preview has no path yet')),
        );
    }
    return started;
  }

  void _stopNavigation() {
    ref.read(navigationControllerProvider).stop();
  }

  void _handleNavigationDone() {
    // The user has walked the route, so their new position is the destination.
    final dest = ref.read(routeDestProvider);
    ref.read(navigationControllerProvider).stop();
    _arrivalOrderCommitted = false;
    _resetRerouteState();
    if (dest != null) {
      ref.read(userPositionProvider.notifier).state = dest.gridLocation;
      ref.read(locationSourceProvider.notifier).state = LocationSource.manual;
    }
    ref.read(routeDestProvider.notifier).state = null;
    ref.invalidate(routeResultProvider);
    setState(() {});
  }

  Future<void> _handleNavigationArrived() async {
    if (_arrivalOrderCommitted) return;
    _arrivalOrderCommitted = true;
    final start = ref.read(userPositionProvider);
    final dest = ref.read(routeDestProvider);
    final mode = ref.read(routeModeProvider);
    if (start == null || dest == null) return;

    try {
      await ref
          .read(mapRepositoryProvider)
          .orderRoute(
            startLocation: start,
            destLocation: dest.gridLocation,
            modeId: mode,
          );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Arrival log failed')));
    }
  }

  void _followNavigationDot({required int rows, required int cols}) {
    final controller = _transformController;
    final dot = ref.read(navDotProvider);
    if (!mounted ||
        controller == null ||
        dot == null ||
        _lastViewportSize == Size.zero ||
        _lastGridSize == Size.zero) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final currentController = _transformController;
      if (currentController == null) return;

      final sceneCenter = _dotSceneCenter(dot, rows, cols, _lastGridSize);
      final transform = currentController.value;
      final scale = transform.getMaxScaleOnAxis().clamp(
        _minMapScale,
        _maxMapScale,
      );
      final tx = transform.storage[12];
      final ty = transform.storage[13];
      final viewportPoint = Offset(
        sceneCenter.dx * scale + tx,
        sceneCenter.dy * scale + ty,
      );
      final centralRect = Rect.fromLTRB(
        _lastViewportSize.width * 0.2,
        _lastViewportSize.height * 0.2,
        _lastViewportSize.width * 0.8,
        _lastViewportSize.height * 0.8,
      );
      if (centralRect.contains(viewportPoint)) return;

      final nextTx = _clampTranslate(
        _lastViewportSize.width / 2 - sceneCenter.dx * scale,
        _lastViewportSize.width,
        _lastGridSize.width * scale,
      );
      final nextTy = _clampTranslate(
        _lastViewportSize.height / 2 - sceneCenter.dy * scale,
        _lastViewportSize.height,
        _lastGridSize.height * scale,
      );
      currentController.value = Matrix4.identity()
        ..translateByDouble(nextTx, nextTy, 0, 1)
        ..scaleByDouble(scale.toDouble(), scale.toDouble(), 1, 1);
    });
  }

  Offset _dotSceneCenter(NavDot dot, int rows, int cols, Size gridSize) {
    final cellWidth = gridSize.width / cols;
    final cellHeight = gridSize.height / rows;
    final from = _cellCenter(dot.fromLocation, cols, cellWidth, cellHeight);
    final to = _cellCenter(dot.toLocation, cols, cellWidth, cellHeight);
    return Offset.lerp(from, to, dot.t.clamp(0.0, 1.0).toDouble()) ?? from;
  }

  Offset _cellCenter(
    int location,
    int cols,
    double cellWidth,
    double cellHeight,
  ) {
    final row = location ~/ cols;
    final col = location % cols;
    return Offset(
      col * cellWidth + cellWidth / 2,
      row * cellHeight + cellHeight / 2,
    );
  }

  Offset _poiCenter(MapPoi poi, double cellWidth, double cellHeight) {
    return Offset(
      poi.gridCol * cellWidth + cellWidth / 2,
      poi.gridRow * cellHeight + cellHeight / 2,
    );
  }

  double _clampTranslate(
    double translate,
    double viewportExtent,
    double gridExtent,
  ) {
    if (gridExtent <= viewportExtent) return 0;
    return translate.clamp(viewportExtent - gridExtent, 0).toDouble();
  }
}

class _RoutePill extends StatelessWidget {
  final String startName;
  final MapPoi? dest;
  final VoidCallback? onTap;
  final VoidCallback? onClear;
  final VoidCallback? onDone;

  const _RoutePill({
    required this.startName,
    required this.dest,
    required this.onTap,
    required this.onClear,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    if (dest == null) return const SizedBox.shrink();
    final scheme = context.colorScheme;
    final destName = dest?.poiName ?? 'Pick destination';

    return Semantics(
      container: true,
      button: onTap != null,
      label: 'Route from $startName to $destName. Tap to edit.',
      child: Material(
        color: scheme.surface,
        elevation: 2,
        shadowColor: scheme.shadow,
        borderRadius: AppRadius.borderFull,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderFull,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.xs,
              AppSpacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.my_location_rounded,
                  size: 14,
                  color: scheme.primary,
                ),
                const SizedBox(width: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 96),
                  child: Text(
                    startName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Icon(Icons.flag_rounded, size: 14, color: scheme.secondary),
                const SizedBox(width: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 96),
                  child: Text(
                    destName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                if (onDone != null)
                  IconButton(
                    iconSize: 18,
                    visualDensity: VisualDensity.compact,
                    onPressed: onDone,
                    icon: Icon(
                      Icons.check_circle_rounded,
                      color: scheme.primary,
                    ),
                    tooltip: 'Finish route',
                  )
                else if (onClear != null)
                  IconButton(
                    iconSize: 18,
                    visualDensity: VisualDensity.compact,
                    onPressed: onClear,
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Clear route',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MapFab extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _MapFab({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Semantics(
      button: true,
      label: tooltip,
      child: Material(
        color: scheme.surface,
        elevation: 2,
        shadowColor: scheme.shadow,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, size: 22, color: scheme.onSurface),
          ),
        ),
      ),
    );
  }
}

class _FlowAlertBanner extends StatelessWidget {
  final bool isStale;
  final DateTime updatedAt;
  final String? message;

  const _FlowAlertBanner({
    required this.isStale,
    required this.updatedAt,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final text = message ?? 'Offline flow snapshot';
    return Material(
      color: isStale ? scheme.tertiaryContainer : scheme.errorContainer,
      elevation: 2,
      shadowColor: scheme.shadow,
      borderRadius: AppRadius.borderMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(
              isStale
                  ? Icons.cloud_off_rounded
                  : Icons.warning_amber_rounded,
              size: 18,
              color: isStale
                  ? scheme.onTertiaryContainer
                  : scheme.onErrorContainer,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                isStale ? '$text · ${_formatUpdatedAt(updatedAt)}' : text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.labelMedium?.copyWith(
                  color: isStale
                      ? scheme.onTertiaryContainer
                      : scheme.onErrorContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatUpdatedAt(DateTime value) {
    if (value.millisecondsSinceEpoch == 0) {
      return 'no cached time';
    }
    final local = value.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return 'updated $hour:$minute';
  }
}

class _FlowLegend extends StatelessWidget {
  final bool isStale;

  const _FlowLegend({required this.isStale});

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    return Material(
      color: scheme.surface,
      elevation: 2,
      shadowColor: scheme.shadow,
      borderRadius: AppRadius.borderSm,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isStale ? 'Flow heatmap · stale' : 'Flow heatmap',
              style: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _LegendSwatch(color: Color(0xFFFFD166)),
                const SizedBox(width: 4),
                Text('0', style: context.textTheme.labelSmall),
                const SizedBox(width: AppSpacing.sm),
                const _LegendSwatch(color: Color(0xFFE63946)),
                const SizedBox(width: 4),
                Text('1 density', style: context.textTheme.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendSwatch extends StatelessWidget {
  final Color color;

  const _LegendSwatch({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _RoutePoiPickerSheet extends StatefulWidget {
  final String title;
  final List<MapPoi> pois;
  final Map<int, String> normalizedNames;

  const _RoutePoiPickerSheet({
    required this.title,
    required this.pois,
    required this.normalizedNames,
  });

  @override
  State<_RoutePoiPickerSheet> createState() => _RoutePoiPickerSheetState();
}

class _RoutePoiPickerSheetState extends State<_RoutePoiPickerSheet> {
  late final TextEditingController _controller;
  String _query = '';
  String? _cachedFilterKey;
  List<MapPoi> _cachedFiltered = const <MapPoi>[];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController()..addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onQueryChanged)
      ..dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    final next = _controller.text.trim();
    if (next == _query) return;
    setState(() => _query = next);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final scheme = context.colorScheme;
    final filteredPois = _filteredPois();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg + bottomInset,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: AppRadius.borderFull,
                ),
              ),
              Text(
                widget.title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _controller,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search a place',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: filteredPois.isEmpty
                    ? Center(
                        child: Text(
                          _query.isEmpty
                              ? 'Start typing to find a place.'
                              : 'No matches for "$_query".',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: filteredPois.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final poi = filteredPois[index];
                          final color = MapPoiPalette.colorFor(poi.poiType);
                          return ListTile(
                            leading: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            title: Text(
                              poi.poiName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${MapPoiPalette.labelFor(poi.poiType)} · '
                              '${poi.poiCode}',
                            ),
                            onTap: () => Navigator.pop(context, poi),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<MapPoi> _filteredPois() {
    if (_query.isEmpty) return widget.pois;
    if (_cachedFilterKey == _query) return _cachedFiltered;
    final normalizedQuery = normalizeForSearch(_query);
    final result = widget.pois.where((poi) {
      final text =
          widget.normalizedNames[poi.poiId] ?? normalizeForSearch(poi.poiName);
      return text.contains(normalizedQuery);
    }).toList();
    _cachedFilterKey = _query;
    _cachedFiltered = result;
    return result;
  }
}

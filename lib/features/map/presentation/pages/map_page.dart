import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/features/map/data/models/flow_cell.dart';
import 'package:hospital_app/features/map/data/models/flow_snapshot.dart';
import 'package:hospital_app/features/map/data/models/location_source.dart';
import 'package:hospital_app/features/map/data/models/map_floor.dart';
import 'package:hospital_app/features/map/data/models/map_poi.dart';
import 'package:hospital_app/features/map/data/models/nav_state.dart';
import 'package:hospital_app/features/map/data/models/route_history.dart';
import 'package:hospital_app/features/map/data/models/route_history_entry.dart';
import 'package:hospital_app/features/map/data/models/route_result.dart';
import 'package:hospital_app/features/map/presentation/controllers/navigation_controller.dart';
import 'package:hospital_app/features/map/presentation/pages/map_qr_scanner_page.dart';
import 'package:hospital_app/features/map/data/services/map_perf_debug.dart';
import 'package:hospital_app/features/map/presentation/providers/map_provider.dart';
import 'package:hospital_app/features/map/presentation/theme/map_tokens.dart';
import 'package:hospital_app/features/map/presentation/utils/search_utils.dart';
import 'package:hospital_app/features/map/presentation/widgets/map_async_message.dart';
import 'package:hospital_app/features/map/presentation/widgets/map_grid_painter.dart';
import 'package:hospital_app/features/map/presentation/widgets/map_legend_sheet.dart';
import 'package:hospital_app/features/map/presentation/widgets/map_navigation_sheet.dart';
import 'package:hospital_app/features/map/presentation/widgets/map_poi_metadata_panel.dart';
import 'package:hospital_app/features/map/presentation/widgets/map_route_panel.dart';
import 'package:hospital_app/features/map/presentation/widgets/map_search_results_panel.dart';
import 'package:hospital_app/features/map/presentation/widgets/map_top_bar.dart';

part '../widgets/map_page/route_pill.dart';
part '../widgets/map_page/map_fab.dart';
part '../widgets/map_page/floor_selector.dart';
part '../widgets/map_page/route_history_sheet.dart';
part '../widgets/map_page/map_status_cluster.dart';
part '../widgets/map_page/status_pill.dart';
part '../widgets/map_page/pill_data.dart';
part '../widgets/map_page/flow_legend.dart';
part '../widgets/map_page/legend_swatch.dart';
part '../widgets/map_page/flow_analytics_panel.dart';
part '../widgets/map_page/analytics_row.dart';
part '../widgets/map_page/obstacle_report_draft.dart';
part '../widgets/map_page/obstacle_report_sheet.dart';
part '../widgets/map_page/route_poi_picker_sheet.dart';

// debug
// import 'package:hospital_app/features/map/presentation/widgets/map_debug_grid_painter.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage>
    with SingleTickerProviderStateMixin {
  static const int _defaultRows = 33;
  static const int _defaultCols = 57;
  static const double _minMapScale = 1;
  static const double _maxMapScale = 4;
  static const Duration _searchDebounceDuration = Duration(milliseconds: 500);
  static const Duration _walkableLayerDelay = Duration(milliseconds: 50);

  late final TextEditingController _searchController;
  Timer? _searchDebounceTimer;
  Timer? _walkableLayerTimer;
  late final AnimationController _routeAnim;
  TransformationController? _transformController;
  Size _lastViewportSize = Size.zero;
  Size _lastGridSize = Size.zero;
  double _lastMinScale = 0;
  int _lastRouteSignature = 0;
  bool _searchExpanded = true;
  bool _arrivalOrderCommitted = false;
  bool _navCollapsed = false;
  bool _floorSwitchKeepsNavigation = false;
  bool _showAnalyticsPanel = false;
  bool _loadWalkableLayer = false;
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
    _scheduleWalkableLayerLoad();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    _searchDebounceTimer?.cancel();
    _walkableLayerTimer?.cancel();
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

  void _scheduleWalkableLayerLoad() {
    _walkableLayerTimer?.cancel();
    perfLog(
      'walkableLayer scheduled '
      '(delay=${_walkableLayerDelay.inMilliseconds}ms)',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _loadWalkableLayer) return;
      perfLog('walkableLayer first frame painted -> starting delay timer');
      _walkableLayerTimer = Timer(_walkableLayerDelay, () {
        if (!mounted || _loadWalkableLayer) return;
        perfLog('walkableLayer timer fired -> watching mapEdgesProvider now');
        setState(() => _loadWalkableLayer = true);
      });
    });
  }

  TransformationController _ensureTransformController() {
    final existing = _transformController;
    if (existing != null) return existing;
    final controller = TransformationController();
    _transformController = controller;
    return controller;
  }

  int? _activeMapId() {
    return ref.read(selectedFloorProvider) ??
        ref.read(floorsProvider).valueOrNull?.firstOrNull?.mapId;
  }

  int get _defaultMapId => _activeMapId() ?? 1;

  void _resetForFloorSwitch() {
    ref.read(navigationControllerProvider).stop();
    ref.read(routeDestProvider.notifier).state = null;
    _arrivalOrderCommitted = false;
    _lastRouteSignature = 0;
    _routeAnim.value = 0;
    _loadWalkableLayer = false;
    _scheduleWalkableLayerLoad();
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
    final floorsAsync = ref.watch(floorsProvider);
    final floors = floorsAsync.valueOrNull ?? const <MapFloor>[];
    final selectedFloorId = ref.watch(selectedFloorProvider);
    final activeMapId =
        selectedFloorId != null &&
            (floors.isEmpty ||
                floors.any((floor) => floor.mapId == selectedFloorId))
        ? selectedFloorId
        : floors.firstOrNull?.mapId ?? _defaultMapId;
    ref.listen<int?>(selectedFloorProvider, (previous, next) {
      if (previous == null || next == null || previous == next) {
        return;
      }
      if (_floorSwitchKeepsNavigation) {
        _floorSwitchKeepsNavigation = false;
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _resetForFloorSwitch();
        }
      });
    });

    final metaAsync = ref.watch(mapMetaProvider(activeMapId));
    final nodesLoading = ref.watch(
      mapNodesProvider(activeMapId).select((a) => a.isLoading),
    );
    final edgesLoading = _loadWalkableLayer
        ? ref.watch(mapEdgesProvider(activeMapId).select((a) => a.isLoading))
        : false;
    final keyword = ref.watch(searchKeywordProvider);
    final searchResultsAsync = ref.watch(searchResultsProvider(_defaultMapId));
    final userPosition = ref.watch(userPositionProvider);
    final userPositionPoi = ref.watch(
      poiByCellProvider(_defaultMapId),
    )[userPosition];
    final dest = ref.watch(routeDestProvider);
    final isOnline = ref.watch(mapConnectivityProvider).valueOrNull;
    final lastSyncedAt = ref
        .watch(mapLastSyncedAtProvider(activeMapId))
        .valueOrNull;
    final inlineNotice = ref.watch(mapInlineNoticeProvider);
    final locationSource = ref.watch(locationSourceProvider);
    final flowVisible = ref.watch(flowOverlayVisibleProvider);
    final edgeStatusVisible = ref.watch(edgeStatusVisibleProvider);
    final bottlenecksVisible = ref.watch(bottlenecksVisibleProvider);
    final forecastVisible = ref.watch(forecastVisibleProvider);
    final forecastHours = ref.watch(forecastHoursProvider);
    final navPhase = ref.watch(navPhaseProvider);
    final shouldWatchRoute =
        dest != null ||
        navPhase == NavPhase.navigating ||
        navPhase == NavPhase.paused ||
        navPhase == NavPhase.arrived;
    final routeResultAsync = shouldWatchRoute
        ? ref.watch(activeRouteResultProvider)
        : const AsyncValue.data(null);
    final needsFlowSnapshot =
        _showAnalyticsPanel || flowVisible || edgeStatusVisible;
    final flowSnapshot = needsFlowSnapshot
        ? ref.watch(flowSnapshotProvider(activeMapId))
        : AsyncValue<FlowSnapshot>.data(FlowSnapshot.empty());
    final flow = flowSnapshot.valueOrNull;
    final needsBottlenecks = _showAnalyticsPanel || bottlenecksVisible;
    final bottlenecks = needsBottlenecks
        ? ref.watch(bottlenecksProvider(activeMapId)).valueOrNull ??
              const <FlowCell>[]
        : const <FlowCell>[];
    final needsForecast = _showAnalyticsPanel || forecastVisible;
    final forecast = needsForecast
        ? ref.watch(forecastProvider(activeMapId)).valueOrNull ??
              const <FlowCell>[]
        : const <FlowCell>[];
    final nodes =
        ref.watch(mapNodesProvider(activeMapId)).value ?? const <MapPoi>[];
    final walkable = _loadWalkableLayer
        ? ref.watch(walkableCellsProvider(activeMapId))
        : const <int>{};
    final rows = metaAsync.value?.rows ?? _defaultRows;
    final cols = metaAsync.value?.cols ?? _defaultCols;
    final routeLocations = shouldWatchRoute
        ? ref.watch(routeLocationsProvider)
        : const <int>[];
    final navDot = shouldWatchRoute ? ref.watch(navDotProvider) : null;
    final navProgress = ref.watch(navProgressProvider);
    ref.watch(navigationControllerProvider);
    final defaultUserPosition = userPosition == null && nodes.isNotEmpty
        ? _defaultUserPositionFromNodes(nodes)
        : null;
    if (defaultUserPosition != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || ref.read(userPositionProvider) != null) return;
        ref.read(userPositionProvider.notifier).state = defaultUserPosition;
      });
    }

    ref
      ..listen<NavPhase>(navPhaseProvider, (previous, next) {
        if (next == NavPhase.navigating) {
          _routeAnim.value = 1;
          // Persist the active route on a fresh start (not on resume) so the
          // in-progress trip survives a mid-trip connection drop / restart.
          if (previous != NavPhase.paused) {
            final route = ref.read(routeResultProvider).valueOrNull;
            if (route != null && route.path.isNotEmpty) {
              ref.read(mapCacheProvider).saveActiveRoute(route);
            }
          }
        } else if (next == NavPhase.arrived) {
          _handleNavigationArrived();
        } else if (next == NavPhase.idle) {
          ref.read(mapCacheProvider).clearActiveRoute();
        }
      })
      ..listen<double>(navProgressProvider, (_, _) {
        if (ref.read(navPhaseProvider) != NavPhase.navigating) return;
        _followNavigationDot(rows: rows, cols: cols);
      })
      ..listen<AsyncValue<bool>>(mapConnectivityProvider, (previous, next) {
        final wasOnline = previous?.valueOrNull;
        final isOnline = next.valueOrNull;
        if (wasOnline == false && isOnline == true) {
          unawaited(_refreshMapDataOnReconnect());
        }
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
          _buildMapViewport(
            mediaBottom: mediaBottom,
            rows: rows,
            cols: cols,
            walkable: walkable,
            nodes: nodes,
            forecastVisible: forecastVisible,
            forecast: forecast,
            flow: flow,
            flowVisible: flowVisible,
            edgeStatusVisible: edgeStatusVisible,
            bottlenecks: bottlenecks,
            bottlenecksVisible: bottlenecksVisible,
            routeLocations: routeLocations,
            navDot: navDot,
            navProgress: navProgress,
          ),

          _buildSearchOverlay(
            mediaTop: mediaTop,
            loading: loading,
            searching: searching,
            searchResultsAsync: searchResultsAsync,
            keyword: keyword,
            nodes: nodes,
            activeMapId: activeMapId,
          ),

          if (hasRoute)
            _buildRoutePillOverlay(
              mediaTop: mediaTop,
              userPositionPoi: userPositionPoi,
              dest: dest,
            ),

          _buildStatusOverlay(
            mediaTop: mediaTop,
            hasRoute: hasRoute,
            flowSnapshot: flowSnapshot,
            isOnline: isOnline,
            lastSyncedAt: lastSyncedAt,
            locationSource: locationSource,
            inlineNotice: inlineNotice,
            activeMapId: activeMapId,
          ),

          _buildFloorSelectorOverlay(
            mediaTop: mediaTop,
            floors: floors,
            activeMapId: activeMapId,
          ),

          if (_showAnalyticsPanel || flowVisible)
            _buildAnalyticsOverlay(
              mediaBottom: mediaBottom,
              flow: flow,
              flowVisible: flowVisible,
              edgeStatusVisible: edgeStatusVisible,
              bottlenecksVisible: bottlenecksVisible,
              forecastVisible: forecastVisible,
              forecastHours: forecastHours,
              bottlenecks: bottlenecks,
              forecast: forecast,
            ),

          _buildMapActionCluster(mediaBottom),

          _buildRouteActionOverlay(
            mediaBottom: mediaBottom,
            showNavigationSheet: showNavigationSheet,
            dest: dest,
            userPosition: userPosition,
            routeResultAsync: routeResultAsync,
            hasRoute: hasRoute,
          ),
        ],
      ),
    );
  }

  Widget _buildMapViewport({
    required double mediaBottom,
    required int rows,
    required int cols,
    required Set<int> walkable,
    required List<MapPoi> nodes,
    required bool forecastVisible,
    required List<FlowCell> forecast,
    required FlowSnapshot? flow,
    required bool flowVisible,
    required bool edgeStatusVisible,
    required List<FlowCell> bottlenecks,
    required bool bottlenecksVisible,
    required List<int> routeLocations,
    required NavDot? navDot,
    required double navProgress,
  }) {
    return Positioned(
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
            viewportSize: Size(constraints.maxWidth, constraints.maxHeight),
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
                          flowCells: forecastVisible
                              ? forecast
                              : (flow?.cells ?? const []),
                          edgeStatuses: flow?.edgeStatuses ?? const [],
                          showFlowOverlay: forecastVisible || flowVisible,
                          showEdgeStatus: edgeStatusVisible,
                          bottlenecks: bottlenecks,
                          showBottlenecks: bottlenecksVisible,
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
    );
  }

  Widget _buildSearchOverlay({
    required double mediaTop,
    required bool loading,
    required bool searching,
    required AsyncValue<List<MapPoi>> searchResultsAsync,
    required String keyword,
    required List<MapPoi> nodes,
    required int activeMapId,
  }) {
    return Positioned(
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
                            padding: const EdgeInsets.only(top: AppSpacing.sm),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 320),
                              child: MapSearchResultsPanel(
                                results: searchResultsAsync,
                                query: keyword.trim(),
                                suggestions: nodes.take(3).toList(),
                                onSelect: _selectPoiFromSearch,
                                onRetry: () => ref.invalidate(
                                  searchResultsProvider(activeMapId),
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
    );
  }

  Widget _buildRoutePillOverlay({
    required double mediaTop,
    required MapPoi? userPositionPoi,
    required MapPoi? dest,
  }) {
    return Positioned(
      top: mediaTop + AppSpacing.md + 52,
      left: AppSpacing.md,
      child: _RoutePill(
        startName: userPositionPoi?.poiName ?? 'You are here',
        dest: dest,
        onTap: _showRoutePanel,
        onClear: _clearRoute,
      ),
    );
  }

  Widget _buildStatusOverlay({
    required double mediaTop,
    required bool hasRoute,
    required AsyncValue<FlowSnapshot> flowSnapshot,
    required bool? isOnline,
    required DateTime? lastSyncedAt,
    required LocationSource locationSource,
    required String? inlineNotice,
    required int activeMapId,
  }) {
    return Positioned(
      top: mediaTop + AppSpacing.md + (hasRoute ? 104 : 52),
      left: AppSpacing.md,
      child: _MapStatusCluster(
        snapshot: flowSnapshot,
        isOnline: isOnline,
        lastSyncedAt: lastSyncedAt,
        locationSource: locationSource,
        notice: inlineNotice,
        onRetry: () => ref.invalidate(flowSnapshotProvider(activeMapId)),
      ),
    );
  }

  Widget _buildFloorSelectorOverlay({
    required double mediaTop,
    required List<MapFloor> floors,
    required int activeMapId,
  }) {
    return Positioned(
      top: mediaTop + AppSpacing.md + 56,
      right: AppSpacing.md,
      child: _FloorSelector(
        floors: floors,
        selectedMapId: activeMapId,
        onChanged: (mapId) {
          if (mapId == null || mapId == activeMapId) return;
          ref.read(selectedFloorProvider.notifier).state = mapId;
        },
      ),
    );
  }

  Widget _buildAnalyticsOverlay({
    required double mediaBottom,
    required FlowSnapshot? flow,
    required bool flowVisible,
    required bool edgeStatusVisible,
    required bool bottlenecksVisible,
    required bool forecastVisible,
    required int forecastHours,
    required List<FlowCell> bottlenecks,
    required List<FlowCell> forecast,
  }) {
    if (_showAnalyticsPanel) {
      return Positioned(
        left: AppSpacing.md,
        bottom: mediaBottom + 252,
        child: _FlowAnalyticsPanel(
          isStale: flow?.isStale ?? false,
          heatmapActive: flowVisible,
          edgeStatusActive: edgeStatusVisible,
          bottlenecksActive: bottlenecksVisible,
          forecastActive: forecastVisible,
          forecastHours: forecastHours,
          noLiveHeatmapData: flow == null || flow.cells.isEmpty,
          noLiveBottlenecksData: bottlenecks.isEmpty,
          noLiveForecastData: forecast.isEmpty,
          onHeatmapChanged: (active) {
            ref.read(flowOverlayVisibleProvider.notifier).state = active;
          },
          onEdgeStatusChanged: (active) {
            ref.read(edgeStatusVisibleProvider.notifier).state = active;
          },
          onBottlenecksChanged: (active) {
            ref.read(bottlenecksVisibleProvider.notifier).state = active;
          },
          onForecastChanged: (active) {
            ref.read(forecastVisibleProvider.notifier).state = active;
          },
          onForecastHoursChanged: (hours) {
            ref.read(forecastHoursProvider.notifier).state = hours;
          },
        ),
      );
    }

    return Positioned(
      left: AppSpacing.md,
      bottom: mediaBottom + 204,
      child: _FlowLegend(
        isStale: flow?.isStale ?? false,
        noData: flow == null || flow.cells.isEmpty,
      ),
    );
  }

  Widget _buildMapActionCluster(double mediaBottom) {
    return Positioned(
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
            icon: _showAnalyticsPanel
                ? Icons.analytics_rounded
                : Icons.analytics_outlined,
            tooltip: 'Flow Analytics Options',
            active: _showAnalyticsPanel,
            onPressed: () {
              setState(() {
                _showAnalyticsPanel = !_showAnalyticsPanel;
              });
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
    );
  }

  Widget _buildRouteActionOverlay({
    required double mediaBottom,
    required bool showNavigationSheet,
    required MapPoi? dest,
    required int? userPosition,
    required AsyncValue<RouteResult?> routeResultAsync,
    required bool hasRoute,
  }) {
    if (showNavigationSheet && dest != null) {
      return Positioned(
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
                onStop: _stopNavigation,
                onCollapse: () => setState(() => _navCollapsed = true),
              ),
      );
    }

    if (dest != null && userPosition != null && routeResultAsync.hasValue) {
      return Positioned(
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
      );
    }

    return Positioned(
      right: AppSpacing.md,
      bottom: mediaBottom + AppSpacing.md,
      child: FloatingActionButton.extended(
        heroTag: 'map-route-fab',
        onPressed: _showRoutePanel,
        icon: Icon(
          hasRoute ? Icons.edit_location_alt_rounded : Icons.alt_route_rounded,
        ),
        label: Text(hasRoute ? 'Route' : 'Plan route'),
      ),
    );
  }

  int? _defaultUserPositionFromNodes(List<MapPoi> nodes) {
    for (final poi in nodes) {
      if (poi.poiCode.toUpperCase().startsWith('ENT')) {
        return poi.gridLocation;
      }
    }
    for (final poi in nodes) {
      if (poi.poiName.toLowerCase().contains('entrance')) {
        return poi.gridLocation;
      }
    }
    for (final poi in nodes) {
      if (poi.isLandmark) {
        return poi.gridLocation;
      }
    }
    return null;
  }

  void _handleTap(Offset scenePosition, int rows, int cols, double cellSize) {
    final mapId = _activeMapId();
    if (mapId == null) return;
    final byCell = ref.read(poiByCellProvider(mapId));
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
    ref.read(mapInlineNoticeProvider.notifier).state = 'Position set manually';
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
    ref.read(mapInlineNoticeProvider.notifier).state =
        'Position set: ${poi.poiName}';
  }

  void _selectPoiFromSearch(MapPoi poi) {
    _setRouteDestination(poi);
    _searchController.clear();
    _setSearchKeyword('', immediate: true);
  }

  void _clearRoute() {
    ref.read(navigationControllerProvider).stop();
    _arrivalOrderCommitted = false;
    ref.read(routeDestProvider.notifier).state = null;
    setState(() {});
  }

  void _completeRoute() {
    ref.read(navigationControllerProvider).stop();
    _arrivalOrderCommitted = false;
    ref.read(routeDestProvider.notifier).state = null;
    ref.invalidate(routeResultProvider);
    setState(() {});
  }

  Future<void> _refreshMapDataOnReconnect() async {
    if (ref.read(navPhaseProvider) == NavPhase.navigating) {
      return;
    }
    final id = _defaultMapId;
    // Clear the in-memory + on-disk edge cache first; otherwise invalidating
    // mapEdgesProvider is a no-op because loadEdges short-circuits on the cache
    // and edge geometry never refreshes until the next app launch.
    await ref.read(mapCacheProvider).forgetEdges(mapId: id);
    if (!mounted) return;
    ref
      ..invalidate(mapMetaProvider(id))
      ..invalidate(mapNodesProvider(id))
      ..invalidate(mapEdgesProvider(id))
      ..invalidate(flowSnapshotProvider(id))
      ..invalidate(mapObstaclesProvider(id))
      ..invalidate(mapLastSyncedAtProvider(id))
      ..invalidate(routeResultProvider);
    ref.read(mapInlineNoticeProvider.notifier).state = 'Map synced';
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
      MaterialPageRoute(builder: (_) => MapQrScannerPage(mapId: _defaultMapId)),
    );
    if (!mounted || positioned != true) return;
    ref.read(mapInlineNoticeProvider.notifier).state = 'Position set by QR';
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
            final routeResult = ref.watch(routeResultProvider);
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
                onRetry: () => ref.invalidate(routeResultProvider),
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
    final start = ref.read(userPositionProvider);
    ref.read(routeDestProvider.notifier).state = poi;
    if (start == poi.gridLocation) {
      ref.read(routeDestProvider.notifier).state = null;
    }
    setState(() {});
  }

  void _setRouteMode(String mode) {
    ref.read(navigationControllerProvider).stop();
    ref.read(routeModeProvider.notifier).state = mode;
  }

  bool _startNavigation() {
    _arrivalOrderCommitted = false;
    _navCollapsed = false;
    _routeAnim.value = 1;
    final started = ref.read(navigationControllerProvider).start();
    if (!started) {
      ref.read(mapInlineNoticeProvider.notifier).state =
          'Route preview has no path';
    }
    return started;
  }

  void _stopNavigation() {
    final current =
        ref.read(navCurrentLocationProvider) ??
        ref.read(navigationControllerProvider).currentLocationApprox;
    ref.read(navigationControllerProvider).stop();
    if (current != null) {
      ref.read(userPositionProvider.notifier).state = current;
      ref.read(locationSourceProvider.notifier).state = LocationSource.manual;
    }
    _arrivalOrderCommitted = false;
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
      ref.read(mapInlineNoticeProvider.notifier).state =
          'Arrival log not synced';
    }

    // Commit position to destination on arrival.
    ref.read(userPositionProvider.notifier).state = dest.gridLocation;
    ref.read(locationSourceProvider.notifier).state = LocationSource.manual;

    // Auto-dismiss the arrived card after a brief pause.
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      if (ref.read(navPhaseProvider) != NavPhase.arrived) {
        return;
      }
      _completeRoute();
    });
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

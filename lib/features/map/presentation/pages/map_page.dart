import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/features/map/data/models/map_poi.dart';
import 'package:hospital_app/features/map/presentation/providers/map_provider.dart';
import 'package:hospital_app/features/map/presentation/theme/map_tokens.dart';
import 'package:hospital_app/features/map/presentation/utils/search_utils.dart';
import 'package:hospital_app/features/map/presentation/widgets/map_grid_painter.dart';
import 'package:hospital_app/features/map/presentation/widgets/map_legend_sheet.dart';
import 'package:hospital_app/features/map/presentation/widgets/map_poi_metadata_panel.dart';
import 'package:hospital_app/features/map/presentation/widgets/map_route_panel.dart';
import 'package:hospital_app/features/map/presentation/widgets/map_search_results_panel.dart';
import 'package:hospital_app/features/map/presentation/widgets/map_top_bar.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

enum _RoutePickTarget { start, destination }

class _MapPageState extends ConsumerState<MapPage>
    with SingleTickerProviderStateMixin {
  static const int _defaultMapId = 1;
  static const int _defaultRows = 33;
  static const int _defaultCols = 57;
  static const double _minMapScale = 1;
  static const double _maxMapScale = 4;

  late final TextEditingController _searchController;
  late final AnimationController _routeAnim;
  TransformationController? _transformController;
  Size _lastViewportSize = Size.zero;
  Size _lastGridSize = Size.zero;
  double _lastMinScale = 0;
  int _lastRouteSignature = 0;
  bool _searchExpanded = true;
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
    _routeAnim.dispose();
    _transformController?.dispose();
    _transformController = null;
    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(searchKeywordProvider.notifier).state = _searchController.text;
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
    final sig =
        routeLocations.isEmpty ? 0 : Object.hashAll(routeLocations);
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
    final start = ref.watch(routeStartProvider);
    final dest = ref.watch(routeDestProvider);
    final routeResultAsync = ref.watch(routeResultProvider);
    final nodes =
        ref.watch(mapNodesProvider(_defaultMapId)).value ?? const <MapPoi>[];
    final walkable = ref.watch(walkableCellsProvider(_defaultMapId));
    final rows = metaAsync.value?.rows ?? _defaultRows;
    final cols = metaAsync.value?.cols ?? _defaultCols;
    final routeLocations = ref.watch(routeLocationsProvider);

    _maybeAnimateRoute(routeLocations);

    final loading = metaAsync.isLoading || nodesLoading || edgesLoading;
    final searching = keyword.trim().isNotEmpty;
    final mediaTop = MediaQuery.of(context).padding.top;
    final mediaBottom = MediaQuery.of(context).padding.bottom;

    final hasRoute = start != null || dest != null;

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
                  viewportSize:
                      Size(constraints.maxWidth, constraints.maxHeight),
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
                    onTapDown: (details) => _handleTap(
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
                          animation: Listenable.merge([
                            controller,
                            _routeAnim,
                          ]),
                          builder: (context, _) {
                            final visibleRect = _visibleRectFor(
                              controller.value,
                              Size(
                                constraints.maxWidth,
                                constraints.maxHeight,
                              ),
                              Size(gridWidth, gridHeight),
                            );
                            return CustomPaint(
                              size: Size(gridWidth, gridHeight),
                              painter: MapGridPainter(
                                rows: rows,
                                cols: cols,
                                walkableLocations: walkable,
                                pois: nodes,
                                routeLocations: routeLocations,
                                routeProgress: _routeAnim.value,
                                visibleRect: visibleRect,
                                debugTap: _debugTapScene,
                                debugPoiCenter: _debugPoiCenter,
                                showDebug: _showDebugHitTest,
                              ),
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
                                      onSelect: (poi) =>
                                          _selectPoiFromSearch(poi, start),
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
                        onPressed: () =>
                            setState(() => _searchExpanded = true),
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
                start: start,
                dest: dest,
                onTap: _showRoutePanel,
                onClear: _clearRoute,
                onDone: (start != null &&
                        dest != null &&
                        routeResultAsync.hasValue)
                    ? _completeRoute
                    : null,
              ),
            ),

          // Bottom-left FAB cluster: legend + recenter
          Positioned(
            left: AppSpacing.md,
            bottom: mediaBottom + AppSpacing.md,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MapFab(
                  icon: Icons.map_outlined,
                  tooltip: 'Map legend',
                  onPressed: _showLegend,
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

          // Bottom-right: route plan FAB
          Positioned(
            right: AppSpacing.md,
            bottom: mediaBottom + AppSpacing.md,
            child: FloatingActionButton.extended(
              heroTag: 'map-route-fab',
              onPressed: _showRoutePanel,
              icon: Icon(hasRoute
                  ? Icons.edit_location_alt_rounded
                  : Icons.alt_route_rounded),
              label: Text(hasRoute ? 'Route' : 'Plan route'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleTap(
    Offset scenePosition,
    int rows,
    int cols,
    double cellSize,
  ) {
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
            onSetStart: () {
              Navigator.of(sheetContext).maybePop();
              _setRouteStart(poi);
            },
            onSetDestination: () {
              Navigator.of(sheetContext).maybePop();
              _setRouteDestination(poi);
            },
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

  void _selectPoiFromSearch(MapPoi poi, MapPoi? start) {
    if (start == null) {
      _setRouteStart(poi);
    } else {
      _setRouteDestination(poi);
    }
    _searchController.clear();
    ref.read(searchKeywordProvider.notifier).state = '';
  }

  void _clearRoute() {
    ref.read(routeStartProvider.notifier).state = null;
    ref.read(routeDestProvider.notifier).state = null;
    setState(() {});
  }

  void _completeRoute() {
    ref.read(routeStartProvider.notifier).state = null;
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

  Future<void> _showRoutePanel() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: false,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Consumer(
          builder: (context, ref, _) {
            final start = ref.watch(routeStartProvider);
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
                start: start,
                dest: dest,
                mode: mode,
                routeResult: routeResult,
                routeLocations: routeLocations,
                onClear: () {
                  _clearRoute();
                  Navigator.of(sheetContext).maybePop();
                },
                onModeChanged: (v) =>
                    ref.read(routeModeProvider.notifier).state = v,
                onPickStart: () =>
                    _showRoutePoiPicker(_RoutePickTarget.start, nodes),
                onPickDestination: () => _showRoutePoiPicker(
                  _RoutePickTarget.destination,
                  nodes,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showRoutePoiPicker(
    _RoutePickTarget target,
    List<MapPoi> pois,
  ) async {
    final normalized = ref.read(normalizedPoiNamesProvider(_defaultMapId));
    final selected = await showModalBottomSheet<MapPoi>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _RoutePoiPickerSheet(
        title: target == _RoutePickTarget.start
            ? 'Pick a start point'
            : 'Pick a destination',
        pois: pois,
        normalizedNames: normalized,
      ),
    );
    if (!mounted || selected == null) return;
    if (target == _RoutePickTarget.start) {
      _setRouteStart(selected);
    } else {
      _setRouteDestination(selected);
    }
  }

  void _setRouteStart(MapPoi poi) {
    final dest = ref.read(routeDestProvider);
    ref.read(routeStartProvider.notifier).state = poi;
    if (dest?.gridLocation == poi.gridLocation) {
      ref.read(routeDestProvider.notifier).state = null;
    }
    setState(() {});
  }

  void _setRouteDestination(MapPoi poi) {
    final start = ref.read(routeStartProvider);
    ref.read(routeDestProvider.notifier).state = poi;
    if (start?.gridLocation == poi.gridLocation) {
      ref.read(routeStartProvider.notifier).state = null;
    }
    setState(() {});
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
  final MapPoi? start;
  final MapPoi? dest;
  final VoidCallback? onTap;
  final VoidCallback? onClear;
  final VoidCallback? onDone;

  const _RoutePill({
    required this.start,
    required this.dest,
    required this.onTap,
    required this.onClear,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    if (start == null && dest == null) return const SizedBox.shrink();
    final scheme = context.colorScheme;
    final startName = start?.poiName ?? 'Pick start';
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
              Icon(Icons.my_location_rounded,
                  size: 14, color: scheme.primary),
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
              Icon(Icons.arrow_forward_rounded,
                  size: 14, color: scheme.onSurfaceVariant),
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
                  icon: Icon(Icons.check_circle_rounded,
                      color: scheme.primary),
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
                          final color =
                              MapPoiPalette.colorFor(poi.poiType);
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
      final text = widget.normalizedNames[poi.poiId] ??
          normalizeForSearch(poi.poiName);
      return text.contains(normalizedQuery);
    }).toList();
    _cachedFilterKey = _query;
    _cachedFiltered = result;
    return result;
  }
}

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/features/map/data/models/map_edge.dart';
import 'package:hospital_app/features/map/data/models/map_poi.dart';
import 'package:hospital_app/features/map/presentation/providers/map_provider.dart';
import 'package:hospital_app/features/map/presentation/widgets/map_grid_painter.dart';
import 'package:hospital_app/features/map/presentation/widgets/map_route_panel.dart';
import 'package:hospital_app/features/map/presentation/widgets/map_search_results_panel.dart';
import 'package:hospital_app/features/map/presentation/widgets/map_top_bar.dart';
import 'package:hospital_app/features/map/presentation/widgets/poi_metadata_sheet.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage>
    with TickerProviderStateMixin {
  static const int _defaultMapId = 1;
  static const int _defaultRows = 33;
  static const int _defaultCols = 57;
  static const double _searchPanelHeight = 240;

  late final TextEditingController _searchController;
  TransformationController? _transformController;
  late final AnimationController _cameraAnimationController;
  Animation<Matrix4>? _cameraAnimation;
  Size _viewportSize = Size.zero;
  Size _childSize = Size.zero;
  bool _showTopBar = true;
  bool _showRoutePanel = true;
  final bool _showDebugHitTest = kDebugMode;
  Offset? _debugTapScene;
  Offset? _debugPoiCenter;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController()..addListener(_onSearchChanged);
    _cameraAnimationController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 400),
        )..addListener(() {
          if (_cameraAnimation != null && _transformController != null) {
            _transformController!.value = _cameraAnimation!.value;
          }
        });
    _ensureTransformController();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    _cameraAnimationController.dispose();
    _transformController?.dispose();
    _transformController = null;
    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(searchKeywordProvider.notifier).state = _searchController.text;
  }

  TransformationController _ensureTransformController() {
    final existing = _transformController;
    if (existing != null) {
      return existing;
    }

    final controller = TransformationController();
    _transformController = controller;
    return controller;
  }

  void _updateSizes(Size viewportSize, Size childSize) {
    _viewportSize = viewportSize;
    _childSize = childSize;
  }

  @override
  Widget build(BuildContext context) {
    final metaAsync = ref.watch(mapMetaProvider(_defaultMapId));
    final nodesAsync = ref.watch(mapNodesProvider(_defaultMapId));
    final edgesAsync = ref.watch(mapEdgesProvider(_defaultMapId));
    final keyword = ref.watch(searchKeywordProvider);
    final searchResultsAsync = ref.watch(searchResultsProvider(_defaultMapId));
    final start = ref.watch(routeStartProvider);
    final dest = ref.watch(routeDestProvider);
    final mode = ref.watch(routeModeProvider);
    final routeResultAsync = ref.watch(routeResultProvider);

    final nodes = nodesAsync.value ?? <MapPoi>[];
    final edges = edgesAsync.value ?? <MapEdge>[];
    final rows = metaAsync.value?.rows ?? _defaultRows;
    final cols = metaAsync.value?.cols ?? _defaultCols;
    final routeLocations = _extractRouteLocations(routeResultAsync.value);

    final showSearchPanel = _showTopBar && keyword.trim().isNotEmpty;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Fit the full backend grid into the viewport using square cells.
                // Every painter, tap hitbox, and camera calculation below uses
                // this same cell size so POI coordinates stay aligned.
                final cellWidth = constraints.maxWidth / cols;
                final cellHeight = constraints.maxHeight / rows;
                final cellSize = math.min(cellWidth, cellHeight);

                final gridWidth = cols * cellSize;
                final gridHeight = rows * cellSize;

                _updateSizes(
                  Size(constraints.maxWidth, constraints.maxHeight),
                  Size(gridWidth, gridHeight),
                );

                final controller = _ensureTransformController();

                return InteractiveViewer(
                  transformationController: controller,
                  alignment: Alignment.topLeft,
                  clipBehavior: Clip.hardEdge,
                  // The child must keep the exact painted grid size; otherwise
                  // InteractiveViewer can stretch the tap coordinate space.
                  constrained: false,
                  minScale: 0.5,
                  maxScale: 4,
                  boundaryMargin: EdgeInsets.zero,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) => _handleTap(
                      details.localPosition,
                      rows,
                      cols,
                      cellSize,
                      cellSize,
                      nodes,
                    ),
                    child: SizedBox(
                      width: gridWidth,
                      height: gridHeight,
                      child: CustomPaint(
                        size: Size(gridWidth, gridHeight),
                        painter: MapGridPainter(
                          rows: rows,
                          cols: cols,
                          edges: edges,
                          pois: nodes,
                          routeLocations: routeLocations,
                          debugTap: _debugTapScene,
                          debugPoiCenter: _debugPoiCenter,
                          showDebug: _showDebugHitTest,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (metaAsync.isLoading ||
              nodesAsync.isLoading ||
              edgesAsync.isLoading)
            const Positioned.fill(
              child: IgnorePointer(
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          if (_showTopBar)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 12,
              right: 12,
              child: MapTopBar(
                controller: _searchController,
                onHide: () => setState(() => _showTopBar = false),
              ),
            )
          else
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 12,
              child: MapTopBarCollapsedButton(
                onShow: () => setState(() => _showTopBar = true),
              ),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            top: MediaQuery.of(context).padding.top + 68,
            left: 12,
            right: 12,
            height: showSearchPanel ? _searchPanelHeight : 0,
            child: IgnorePointer(
              ignoring: !showSearchPanel,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: showSearchPanel ? 1 : 0,
                child: MapSearchResultsPanel(
                  results: searchResultsAsync,
                  onSelect: (poi) => _selectPoiFromSearch(poi, start),
                ),
              ),
            ),
          ),
          if (_showRoutePanel)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MapRoutePanel(
                start: start,
                dest: dest,
                mode: mode,
                routeResult: routeResultAsync,
                routeLocations: routeLocations,
                onClear: _clearRoute,
                onModeChanged: (value) =>
                    ref.read(routeModeProvider.notifier).state = value,
                onHide: () => setState(() => _showRoutePanel = false),
              ),
            )
          else
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: Center(
                child: MapRoutePanelCollapsed(
                  onShow: () => setState(() => _showRoutePanel = true),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleTap(
    Offset scenePosition,
    int rows,
    int cols,
    double cellWidth,
    double cellHeight,
    List<MapPoi> pois,
  ) async {
    if (pois.isEmpty) {
      return;
    }

    MapPoi? nearest;
    Offset? nearestCenter;
    double bestDistanceSq = double.infinity;

    for (final poi in pois) {
      if (!_isPoiInBounds(poi, rows, cols)) {
        continue;
      }

      final center = _poiCenter(poi, cellWidth, cellHeight);

      final dx = center.dx - scenePosition.dx;
      final dy = center.dy - scenePosition.dy;
      final distSq = dx * dx + dy * dy;

      if (distSq < bestDistanceSq) {
        bestDistanceSq = distSq;
        nearest = poi;
        nearestCenter = center;
      }
    }

    if (_showDebugHitTest) {
      setState(() {
        _debugTapScene = scenePosition;
        _debugPoiCenter = nearestCenter;
      });
    }

    final maxHitboxRadius = math.max(cellWidth, cellHeight) * 1.2;

    if (nearest == null || bestDistanceSq > maxHitboxRadius * maxHitboxRadius) {
      return;
    }

    await _focusAndShowSheet(nearest, cellWidth, cellHeight);
  }

  Future<void> _animateCameraToPoi(
    MapPoi poi,
    double cellWidth,
    double cellHeight,
  ) async {
    final controller = _ensureTransformController();

    if (_viewportSize == Size.zero) {
      return;
    }

    final scale = controller.value.getMaxScaleOnAxis();
    final center = _poiCenter(poi, cellWidth, cellHeight);

    // Matrix translation is in viewport pixels, so scale the scene-space POI
    // center before moving it to the viewport center.
    final targetTranslateX = _clampTranslate(
      _viewportSize.width / 2 - center.dx * scale,
      _viewportSize.width,
      _childSize.width * scale,
    );
    final targetTranslateY = _clampTranslate(
      _viewportSize.height / 2 - center.dy * scale,
      _viewportSize.height,
      _childSize.height * scale,
    );

    final targetMatrix = Matrix4.identity()
      ..translateByDouble(targetTranslateX, targetTranslateY, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);

    if (_cameraAnimationController.isAnimating) {
      _cameraAnimationController.stop();
    }

    _cameraAnimation = Matrix4Tween(begin: controller.value, end: targetMatrix)
        .animate(
          CurvedAnimation(
            parent: _cameraAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    await _cameraAnimationController.forward(from: 0);
  }

  Future<void> _focusAndShowSheet(
    MapPoi poi,
    double cellWidth,
    double cellHeight,
  ) async {
    await _animateCameraToPoi(poi, cellWidth, cellHeight);

    if (!mounted) {
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PoiMetadataSheet(
        poi: poi,
        onSetStart: () {
          ref.read(routeStartProvider.notifier).state = poi;
          Navigator.pop(context);
        },
        onSetDestination: () {
          ref.read(routeDestProvider.notifier).state = poi;
          Navigator.pop(context);
        },
      ),
    );
  }

  void _selectPoiFromSearch(MapPoi poi, MapPoi? start) {
    if (start == null) {
      ref.read(routeStartProvider.notifier).state = poi;
    } else {
      ref.read(routeDestProvider.notifier).state = poi;
    }

    _searchController.clear();
    ref.read(searchKeywordProvider.notifier).state = '';
  }

  void _clearRoute() {
    ref.read(routeStartProvider.notifier).state = null;
    ref.read(routeDestProvider.notifier).state = null;
  }

  List<int> _extractRouteLocations(dynamic data) {
    if (data == null) {
      return [];
    }

    if (data is List) {
      return _coerceLocationsList(data);
    }

    if (data is Map<String, dynamic>) {
      const keys = ['path', 'path_locations', 'locations', 'nodes'];
      for (final key in keys) {
        final value = data[key];
        if (value is List) {
          return _coerceLocationsList(value);
        }
      }
    }

    return [];
  }

  List<int> _coerceLocationsList(List<dynamic> raw) {
    final locations = <int>[];
    for (final item in raw) {
      if (item is int) {
        locations.add(item);
      } else if (item is num) {
        locations.add(item.toInt());
      } else if (item is Map<String, dynamic>) {
        final location = item['location'] ?? item['grid_location'];
        if (location is int) {
          locations.add(location);
        } else if (location is num) {
          locations.add(location.toInt());
        }
      }
    }
    return locations;
  }

  Offset _poiCenter(MapPoi poi, double cellWidth, double cellHeight) {
    // Backend POI coordinates point to grid cells, not raw pixels.
    // Render and hit-test at the cell center to avoid half-cell offset bugs.
    return Offset(
      poi.gridCol * cellWidth + cellWidth / 2,
      poi.gridRow * cellHeight + cellHeight / 2,
    );
  }

  bool _isPoiInBounds(MapPoi poi, int rows, int cols) {
    return poi.gridRow >= 0 &&
        poi.gridRow < rows &&
        poi.gridCol >= 0 &&
        poi.gridCol < cols;
  }

  double _clampTranslate(
    double translate,
    double viewportExtent,
    double childExtent,
  ) {
    // Keep camera movement inside the map bounds after zoom is applied.
    if (childExtent <= viewportExtent) {
      return (viewportExtent - childExtent) / 2;
    }

    return translate.clamp(viewportExtent - childExtent, 0).toDouble();
  }
}

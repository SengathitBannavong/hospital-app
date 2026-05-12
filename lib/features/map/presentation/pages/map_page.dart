import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/features/map/data/models/map_edge.dart';
import 'package:hospital_app/features/map/data/models/map_poi.dart';
import 'package:hospital_app/features/map/presentation/providers/map_provider.dart';
import 'package:hospital_app/features/map/presentation/widgets/map_grid_painter.dart';
import 'package:hospital_app/features/map/presentation/widgets/map_route_panel.dart';
import 'package:hospital_app/features/map/presentation/widgets/map_search_results_panel.dart';
import 'package:hospital_app/features/map/presentation/widgets/map_top_bar.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  static const int _defaultMapId = 1;
  static const int _defaultRows = 33;
  static const int _defaultCols = 57;
  static const double _searchPanelHeight = 240;

  late final TextEditingController _searchController;
  TransformationController? _transformController;
  Size _viewportSize = Size.zero;
  Size _childSize = Size.zero;
  bool _isClamping = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController()..addListener(_onSearchChanged);
    _ensureTransformController();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    _transformController
      ?..removeListener(_onTransformChanged)
      ..dispose();
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

    final controller = TransformationController()
      ..addListener(_onTransformChanged);
    _transformController = controller;
    return controller;
  }

  void _onTransformChanged() {
    _clampTransform();
  }

  void _updateSizes(Size viewportSize, Size childSize) {
    if (_viewportSize == viewportSize && _childSize == childSize) {
      return;
    }

    _viewportSize = viewportSize;
    _childSize = childSize;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _clampTransform();
      }
    });
  }

  void _clampTransform() {
    if (_isClamping || _viewportSize == Size.zero || _childSize == Size.zero) {
      return;
    }

    _isClamping = true;

    final controller = _transformController;
    if (controller == null) {
      _isClamping = false;
      return;
    }

    final matrix = controller.value;
    final scale = matrix.getMaxScaleOnAxis();
    final translation = matrix.getTranslation();

    final scaledWidth = _childSize.width * scale;
    final scaledHeight = _childSize.height * scale;

    final viewportWidth = _viewportSize.width;
    final viewportHeight = _viewportSize.height;

    final minX = scaledWidth <= viewportWidth
        ? (viewportWidth - scaledWidth) / 2
        : viewportWidth - scaledWidth;
    final maxX = scaledWidth <= viewportWidth ? minX : 0.0;
    final minY = scaledHeight <= viewportHeight
        ? (viewportHeight - scaledHeight) / 2
        : viewportHeight - scaledHeight;
    final maxY = scaledHeight <= viewportHeight ? minY : 0.0;

    final clampedX = translation.x.clamp(minX, maxX);
    final clampedY = translation.y.clamp(minY, maxY);

    if (clampedX != translation.x || clampedY != translation.y) {
      controller.value = Matrix4.identity()
        ..translateByDouble(clampedX, clampedY, 0.0, 1.0)
        ..scaleByDouble(scale, scale, scale, 1.0);
    }

    _isClamping = false;
  }

  @override
  Widget build(BuildContext context) {
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
    final routeLocations = _extractRouteLocations(routeResultAsync.value);

    final showSearchPanel = keyword.trim().isNotEmpty;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cellWidth = constraints.maxWidth / _defaultCols;
                final cellHeight = constraints.maxHeight / _defaultRows;
                final cellSize = math.min(cellWidth, cellHeight);

                final gridWidth = _defaultCols * cellSize;
                final gridHeight = _defaultRows * cellSize;

                _updateSizes(
                  Size(constraints.maxWidth, constraints.maxHeight),
                  Size(gridWidth, gridHeight),
                );

                return InteractiveViewer(
                  transformationController: _ensureTransformController(),
                  alignment: Alignment.topLeft,
                  clipBehavior: Clip.hardEdge,
                  minScale: 0.5,
                  maxScale: 4,
                  boundaryMargin: EdgeInsets.zero,
                  child: SizedBox(
                    width: gridWidth,
                    height: gridHeight,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (details) => _handleTap(
                        details.localPosition,
                        cellSize,
                        cellSize,
                        nodes,
                      ),
                      child: CustomPaint(
                        size: Size(gridWidth, gridHeight),
                        painter: MapGridPainter(
                          rows: _defaultRows,
                          cols: _defaultCols,
                          edges: edges,
                          pois: nodes,
                          routeLocations: routeLocations,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (nodesAsync.isLoading || edgesAsync.isLoading)
            const Positioned.fill(
              child: IgnorePointer(
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 12,
            right: 12,
            child: MapTopBar(controller: _searchController),
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
                  onSelect: (poi) => _selectPoiFromSearch(poi, start, dest),
                ),
              ),
            ),
          ),
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
            ),
          ),
        ],
      ),
    );
  }

  void _handleTap(
    Offset localPosition,
    double cellWidth,
    double cellHeight,
    List<MapPoi> pois,
  ) {
    if (pois.isEmpty) {
      return;
    }

    final row = (localPosition.dy / cellHeight).floor().clamp(
      0,
      _defaultRows - 1,
    );
    final col = (localPosition.dx / cellWidth).floor().clamp(
      0,
      _defaultCols - 1,
    );

    MapPoi? nearest;
    double bestDistance = double.infinity;

    for (final poi in pois) {
      final dx = (poi.gridCol - col).toDouble();
      final dy = (poi.gridRow - row).toDouble();
      final dist = dx * dx + dy * dy;
      if (dist < bestDistance) {
        bestDistance = dist;
        nearest = poi;
      }
    }

    if (nearest == null) {
      return;
    }

    final start = ref.read(routeStartProvider);
    final dest = ref.read(routeDestProvider);

    if (start == null) {
      ref.read(routeStartProvider.notifier).state = nearest;
    } else if (dest == null) {
      ref.read(routeDestProvider.notifier).state = nearest;
    } else {
      ref.read(routeStartProvider.notifier).state = nearest;
      ref.read(routeDestProvider.notifier).state = null;
    }
  }

  void _selectPoiFromSearch(MapPoi poi, MapPoi? start, MapPoi? dest) {
    if (start == null) {
      ref.read(routeStartProvider.notifier).state = poi;
    } else if (dest == null) {
      ref.read(routeDestProvider.notifier).state = poi;
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
}

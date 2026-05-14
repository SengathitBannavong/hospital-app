import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hospital_app/core/theme/hospital_theme.dart';
import 'package:hospital_app/features/map/data/models/map_edge.dart';
import 'package:hospital_app/features/map/data/models/map_poi.dart';
import 'package:hospital_app/features/map/presentation/providers/map_provider.dart';
import 'package:hospital_app/features/map/presentation/widgets/map_grid_painter.dart';
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

class _MapPageState extends ConsumerState<MapPage> {
  static const int _defaultMapId = 1;
  static const int _defaultRows = 33;
  static const int _defaultCols = 57;
  static const double _searchPanelHeight = 240;
  static const double _minMapScale = 1;
  static const double _maxMapScale = 4;
  static const double _overlayGap = 8;

  late final TextEditingController _searchController;
  TransformationController? _transformController;
  Size _lastViewportSize = Size.zero;
  Size _lastGridSize = Size.zero;
  double _lastMinScale = 0;
  MapPoi? _selectedPoi;
  bool _showTopBar = true;
  bool _showRoutePanel = true;
  final bool _showDebugHitTest = kDebugMode;
  Offset? _debugTapScene;
  Offset? _debugPoiCenter;

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
      if (!mounted) {
        return;
      }

      final controller = _transformController;
      if (controller == null) {
        return;
      }

      final current = controller.value;
      final scale = current.getMaxScaleOnAxis().clamp(minScale, _maxMapScale);
      final translateX = _clampTranslate(
        current.storage[12],
        viewportSize.width,
        gridSize.width * scale,
      );
      final translateY = _clampTranslate(
        current.storage[13],
        viewportSize.height,
        gridSize.height * scale,
      );

      controller.value = Matrix4.identity()
        ..translateByDouble(translateX, translateY, 0, 1)
        ..scaleByDouble(scale, scale, 1, 1);
    });
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
    final hasCompleteRoute = start != null && dest != null;
    final routeStatusTop =
        MediaQuery.of(context).padding.top +
        (_showTopBar ? 68 : 12) +
        (showSearchPanel ? _searchPanelHeight + _overlayGap : 0);
    final showRouteStatusOverlay = start != null || dest != null;
    final poiPanelTop =
        routeStatusTop + (showRouteStatusOverlay ? 64 + _overlayGap : 0);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Cover the viewport with square cells. Wide maps can overflow
                // horizontally, but the map never starts with empty bands.
                // Painter and tap hitbox calculations use this same cell size
                // so POI coordinates stay aligned.
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
                  // The child must keep the exact painted grid size; otherwise
                  // InteractiveViewer can stretch the tap coordinate space.
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
                  query: keyword.trim(),
                  onSelect: (poi) => _selectPoiFromSearch(poi, start),
                ),
              ),
            ),
          ),
          if (showRouteStatusOverlay)
            Positioned(
              top: routeStatusTop,
              left: 12,
              right: 12,
              child: Align(
                alignment: Alignment.topLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: _RouteSelectionOverlay(
                    start: start,
                    dest: dest,
                    routeResult: routeResultAsync,
                    routeLocations: routeLocations,
                    onDoneRoute: hasCompleteRoute ? _completeRoute : null,
                  ),
                ),
              ),
            ),
          if (_selectedPoi != null)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              top: poiPanelTop,
              left: 12,
              right: 12,
              child: Align(
                alignment: Alignment.topLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: MapPoiMetadataPanel(
                    poi: _selectedPoi!,
                    onClose: () => setState(() => _selectedPoi = null),
                    onSetStart: () => _setRouteStart(_selectedPoi!),
                    onSetDestination: () => _setRouteDestination(_selectedPoi!),
                  ),
                ),
              ),
            ),
          if (_showRoutePanel && !hasCompleteRoute)
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
                onPickStart: () =>
                    _showRoutePoiPicker(_RoutePickTarget.start, nodes),
                onPickDestination: () =>
                    _showRoutePoiPicker(_RoutePickTarget.destination, nodes),
                onHide: () => setState(() => _showRoutePanel = false),
              ),
            )
          else if (!hasCompleteRoute)
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

  void _handleTap(
    Offset scenePosition,
    int rows,
    int cols,
    double cellWidth,
    double cellHeight,
    List<MapPoi> pois,
  ) {
    if (pois.isEmpty) {
      setState(() => _selectedPoi = null);
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
      setState(() => _selectedPoi = null);
      return;
    }

    setState(() => _selectedPoi = nearest);
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
    setState(() {
      _showRoutePanel = true;
      _showTopBar = true;
    });
  }

  void _completeRoute() {
    ref.read(routeStartProvider.notifier).state = null;
    ref.read(routeDestProvider.notifier).state = null;
    ref.invalidate(routeResultProvider);
    setState(() {
      _selectedPoi = null;
      _showRoutePanel = true;
      _showTopBar = true;
    });
  }

  Future<void> _showRoutePoiPicker(
    _RoutePickTarget target,
    List<MapPoi> pois,
  ) async {
    final selected = await showModalBottomSheet<MapPoi>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _RoutePoiPickerSheet(
        title: target == _RoutePickTarget.start
            ? 'Select start point'
            : 'Select destination',
        pois: pois,
      ),
    );

    if (!mounted || selected == null) {
      return;
    }

    if (target == _RoutePickTarget.start) {
      _setRouteStart(selected);
    } else {
      _setRouteDestination(selected);
    }
  }

  void _setRouteStart(MapPoi poi) {
    final dest = ref.read(routeDestProvider);
    ref.read(routeStartProvider.notifier).state = poi;
    final routeIsComplete =
        dest != null && dest.gridLocation != poi.gridLocation;
    if (dest?.gridLocation == poi.gridLocation) {
      ref.read(routeDestProvider.notifier).state = null;
    }
    setState(() {
      _showRoutePanel = !routeIsComplete;
      _showTopBar = !routeIsComplete;
      _selectedPoi = null;
    });
  }

  void _setRouteDestination(MapPoi poi) {
    final start = ref.read(routeStartProvider);
    ref.read(routeDestProvider.notifier).state = poi;
    final routeIsComplete =
        start != null && start.gridLocation != poi.gridLocation;
    if (start?.gridLocation == poi.gridLocation) {
      ref.read(routeStartProvider.notifier).state = null;
    }
    setState(() {
      _showRoutePanel = !routeIsComplete;
      _showTopBar = !routeIsComplete;
      _selectedPoi = null;
    });
  }

  List<int> _extractRouteLocations(dynamic data) {
    if (data == null) {
      return [];
    }

    if (data is List) {
      return _coerceLocationsList(data);
    }

    if (data is Map<String, dynamic>) {
      const keys = ['steps', 'path', 'path_locations', 'locations', 'nodes'];
      for (final key in keys) {
        final value = data[key];
        if (value is List) {
          if (key == 'steps') {
            return _coerceRouteSteps(value);
          }
          return _coerceLocationsList(value);
        }
      }
    }

    return [];
  }

  List<int> _coerceRouteSteps(List<dynamic> raw) {
    final steps = raw.whereType<Map>().toList()
      ..sort((a, b) {
        final aOrder = a['step_order'];
        final bOrder = b['step_order'];
        if (aOrder is num && bOrder is num) {
          return aOrder.compareTo(bOrder);
        }
        return 0;
      });
    return _coerceLocationsList(steps);
  }

  List<int> _coerceLocationsList(List<dynamic> raw) {
    final locations = <int>[];
    for (final item in raw) {
      if (item is int) {
        locations.add(item);
      } else if (item is num) {
        locations.add(item.toInt());
      } else if (item is Map) {
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
    double gridExtent,
  ) {
    if (gridExtent <= viewportExtent) {
      return 0;
    }

    return translate.clamp(viewportExtent - gridExtent, 0).toDouble();
  }
}

class _RouteSelectionOverlay extends StatelessWidget {
  final MapPoi? start;
  final MapPoi? dest;
  final AsyncValue<dynamic> routeResult;
  final List<int> routeLocations;
  final VoidCallback? onDoneRoute;

  const _RouteSelectionOverlay({
    required this.start,
    required this.dest,
    required this.routeResult,
    required this.routeLocations,
    required this.onDoneRoute,
  });

  @override
  Widget build(BuildContext context) {
    final canFinishRoute =
        onDoneRoute != null &&
        routeResult.hasValue &&
        routeResult.value != null;

    return Material(
      color: context.colorScheme.surface,
      elevation: 6,
      shadowColor: context.colorScheme.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderLg,
        side: BorderSide(color: context.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _RouteSelectionChip(
              icon: Icons.my_location_rounded,
              label: 'Start',
              poiName: start?.poiName,
              color: context.colorScheme.primary,
            ),
            _RouteSelectionChip(
              icon: Icons.flag_rounded,
              label: 'Destination',
              poiName: dest?.poiName,
              color: context.colorScheme.secondary,
            ),
            if (onDoneRoute != null)
              _RouteDoneButton(
                isEnabled: canFinishRoute,
                routeLocations: routeLocations,
                onPressed: onDoneRoute!,
              ),
          ],
        ),
      ),
    );
  }
}

class _RouteDoneButton extends StatelessWidget {
  final bool isEnabled;
  final List<int> routeLocations;
  final VoidCallback onPressed;

  const _RouteDoneButton({
    required this.isEnabled,
    required this.routeLocations,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: isEnabled ? onPressed : null,
      icon: const Icon(Icons.check_circle_rounded),
      label: Text(
        isEnabled ? 'Done route (${routeLocations.length})' : 'Calculating...',
      ),
    );
  }
}

class _RoutePoiPickerSheet extends StatefulWidget {
  final String title;
  final List<MapPoi> pois;

  const _RoutePoiPickerSheet({required this.title, required this.pois});

  @override
  State<_RoutePoiPickerSheet> createState() => _RoutePoiPickerSheetState();
}

class _RoutePoiPickerSheetState extends State<_RoutePoiPickerSheet> {
  late final TextEditingController _controller;
  String _query = '';

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
    setState(() => _query = _controller.text.trim().toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final filteredPois = _filteredPois();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomInset),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _controller,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search POI',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: filteredPois.isEmpty
                    ? const Center(child: Text('No POIs found'))
                    : ListView.separated(
                        itemCount: filteredPois.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final poi = filteredPois[index];
                          return ListTile(
                            leading: const Icon(Icons.place_rounded),
                            title: Text(
                              poi.poiName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text('${poi.poiType} • ${poi.poiCode}'),
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
    if (_query.isEmpty) {
      return widget.pois;
    }

    final normalizedQuery = _normalizeSearchText(_query);
    return widget.pois.where((poi) {
      final text = _normalizeSearchText(poi.poiName);
      return text.contains(normalizedQuery);
    }).toList();
  }

  String _normalizeSearchText(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a')
        .replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e')
        .replaceAll(RegExp(r'[ìíịỉĩ]'), 'i')
        .replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o')
        .replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u')
        .replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y')
        .replaceAll('đ', 'd')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

class _RouteSelectionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? poiName;
  final Color color;

  const _RouteSelectionChip({
    required this.icon,
    required this.label,
    required this.poiName,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isSet = poiName != null;

    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isSet
            ? color.withValues(alpha: 0.12)
            : context.colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.borderSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSet ? color : context.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              isSet ? '$label: $poiName' : '$label not set',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelMedium?.copyWith(
                color: isSet ? color : context.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

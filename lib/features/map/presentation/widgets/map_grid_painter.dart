// ignore_for_file: lines_longer_than_80_chars, cascade_invocations
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:hospital_app/features/map/data/models/edge_status.dart';
import 'package:hospital_app/features/map/data/models/flow_cell.dart';
import 'package:hospital_app/features/map/data/models/map_obstacle.dart';
import 'package:hospital_app/features/map/data/models/map_poi.dart';
import 'package:hospital_app/features/map/presentation/controllers/navigation_controller.dart';
import 'package:hospital_app/features/map/presentation/theme/map_tokens.dart';

final Paint _backgroundPaint = Paint()..color = MapSurface.background;
final Paint _walkablePaint = Paint()..color = MapSurface.walkable;
final Paint _routeCellPaint = Paint()..color = MapSurface.routeCell;
final Paint _debugTapPaint = Paint()..color = MapTokens.debugTap;
final Paint _debugPoiPaint = Paint()..color = MapTokens.debugPoi;
final Paint _routeHaloPaint = Paint()
  ..color = MapSurface.routeLineHalo
  ..strokeCap = StrokeCap.round;
final Paint _routeLinePaint = Paint()
  ..color = MapSurface.routeLine
  ..strokeCap = StrokeCap.round;
final Paint _routeTraveledHaloPaint = Paint()
  ..color = MapSurface.routeLineHalo.withValues(alpha: 0.45)
  ..strokeCap = StrokeCap.round;
final Paint _routeTraveledLinePaint = Paint()
  ..color = MapSurface.routeLine.withValues(alpha: 0.4)
  ..strokeCap = StrokeCap.round;

final Map<String, Paint> _poiPaints = {
  for (final entry in MapPoiPalette.byType.entries)
    entry.key: Paint()..color = entry.value,
};
final Paint _poiFallbackPaint = Paint()..color = MapPoiPalette.fallback;
final Paint _userDotRingPaint = Paint()
  ..color = MapTokens.userHalo.withValues(alpha: 0.22);
final Paint _userDotPaint = Paint()..color = MapTokens.userDot;
final Paint _userDotStrokePaint = Paint()
  ..color = MapTokens.paintInk
  ..style = PaintingStyle.stroke;
final Paint _destPoiHaloPaint = Paint()..color = MapSurface.background;
final Paint _destPoiStrokePaint = Paint()
  ..color = MapTokens.paintInk
  ..style = PaintingStyle.stroke;

class MapStaticPainter extends CustomPainter {
  final int rows;
  final int cols;
  final List<Rect> walkableRuns;
  final ui.Image? mapImage;
  final List<MapPoi> pois;
  final List<FlowCell> flowCells;
  final List<EdgeStatus> edgeStatuses;
  final List<MapObstacle> obstacles;
  final bool showFlowOverlay;
  final bool showEdgeStatus;
  final List<FlowCell> bottlenecks;
  final bool showBottlenecks;

  MapStaticPainter({
    required this.rows,
    required this.cols,
    required this.walkableRuns,
    this.mapImage,
    required this.pois,
    this.flowCells = const <FlowCell>[],
    this.edgeStatuses = const <EdgeStatus>[],
    this.obstacles = const <MapObstacle>[],
    this.showFlowOverlay = false,
    this.showEdgeStatus = false,
    this.bottlenecks = const <FlowCell>[],
    this.showBottlenecks = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / cols;
    final cellHeight = size.height / rows;

    canvas.drawRect(Offset.zero & size, _backgroundPaint);

    if (mapImage != null) {
      canvas.drawImageRect(
        mapImage!,
        Rect.fromLTWH(
          0,
          0,
          mapImage!.width.toDouble(),
          mapImage!.height.toDouble(),
        ),
        Offset.zero & size,
        Paint()..filterQuality = FilterQuality.medium,
      );
    } else {
      for (final run in walkableRuns) {
        canvas.drawRect(
          Rect.fromLTWH(
            run.left * cellWidth,
            run.top * cellHeight,
            run.width * cellWidth,
            run.height * cellHeight,
          ),
          _walkablePaint,
        );
      }
    }

    if (showFlowOverlay && flowCells.isNotEmpty) {
      _paintFlowOverlay(canvas, cellWidth, cellHeight);
    }

    if (showEdgeStatus && edgeStatuses.isNotEmpty) {
      _paintEdgeStatus(canvas, cellWidth, cellHeight);
    }

    final radius = math.min(cellWidth, cellHeight) * 0.35;

    for (final poi in pois) {
      if (!_isPoiInBounds(poi)) continue;
      final center = _poiCenter(poi, cellWidth, cellHeight);
      final paint = _poiPaints[poi.poiType] ?? _poiFallbackPaint;
      canvas.drawCircle(center, radius, paint);
    }

    if (showBottlenecks && bottlenecks.isNotEmpty) {
      _paintBottlenecks(canvas, cellWidth, cellHeight);
    }
  }

  void _paintFlowOverlay(Canvas canvas, double cellWidth, double cellHeight) {
    final paint = Paint();
    for (final cell in flowCells) {
      final row = cell.location ~/ cols;
      final col = cell.location % cols;
      if (row < 0 || row >= rows || col < 0 || col >= cols) continue;
      final density = cell.density.clamp(0.0, 1.0).toDouble();
      paint.color = Color.lerp(
        MapTokens.debugPoi.withValues(alpha: 0.2),
        MapTokens.debugTap.withValues(alpha: 0.6),
        density,
      )!;
      canvas.drawRect(
        Rect.fromLTWH(col * cellWidth, row * cellHeight, cellWidth, cellHeight),
        paint,
      );
    }
  }

  void _paintEdgeStatus(Canvas canvas, double cellWidth, double cellHeight) {
    final paint = Paint()
      ..strokeWidth = math.min(cellWidth, cellHeight) * 0.28
      ..strokeCap = StrokeCap.round;

    for (final status in edgeStatuses) {
      final fromRow = status.fromLocation ~/ cols;
      final fromCol = status.fromLocation % cols;
      final toRow = status.toLocation ~/ cols;
      final toCol = status.toLocation % cols;

      if (fromRow < 0 || fromRow >= rows || fromCol < 0 || fromCol >= cols) {
        continue;
      }
      if (toRow < 0 || toRow >= rows || toCol < 0 || toCol >= cols) {
        continue;
      }

      final fromCenter = _cellCenter(
        status.fromLocation,
        cellWidth,
        cellHeight,
      );
      final toCenter = _cellCenter(status.toLocation, cellWidth, cellHeight);

      if (status.blocked) {
        paint.color = MapTokens.debugTap.withValues(alpha: 0.8);
      } else {
        paint.color = Color.lerp(
          const Color(0x22FFB74D),
          const Color(0xCCFF5722),
          status.congestion.clamp(0.0, 1.0).toDouble(),
        )!;
      }

      canvas.drawLine(fromCenter, toCenter, paint);
    }
  }

  void _paintBottlenecks(Canvas canvas, double cellWidth, double cellHeight) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var i = 0; i < bottlenecks.length; i++) {
      final cell = bottlenecks[i];
      final row = cell.location ~/ cols;
      final col = cell.location % cols;

      if (row < 0 || row >= rows || col < 0 || col >= cols) continue;

      final center = _cellCenter(cell.location, cellWidth, cellHeight);
      final radius = math.min(cellWidth, cellHeight) * 0.38;

      final pinPaint = Paint()
        ..color = MapTokens.routeStop
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = MapTokens.paintInk
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final shadowPaint = Paint()
        ..color = MapTokens.paintInkShadow
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

      canvas.drawCircle(center + const Offset(0, 1.5), radius, shadowPaint);
      canvas.drawCircle(center, radius, pinPaint);
      canvas.drawCircle(center, radius, borderPaint);

      final textSpan = TextSpan(
        text: '${i + 1}',
        style: TextStyle(
          color: MapTokens.paintInk,
          fontSize: radius * 1.1,
          fontWeight: FontWeight.bold,
        ),
      );

      textPainter.text = textSpan;
      textPainter.layout();

      final textOffset = Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      );
      textPainter.paint(canvas, textOffset);
    }
  }

  Offset _cellCenter(int location, double cellWidth, double cellHeight) {
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

  bool _isPoiInBounds(MapPoi poi) {
    return poi.gridRow >= 0 &&
        poi.gridRow < rows &&
        poi.gridCol >= 0 &&
        poi.gridCol < cols;
  }

  @override
  bool shouldRepaint(covariant MapStaticPainter oldDelegate) {
    return !identical(oldDelegate.pois, pois) ||
        !identical(oldDelegate.walkableRuns, walkableRuns) ||
        oldDelegate.mapImage != mapImage ||
        !identical(oldDelegate.flowCells, flowCells) ||
        !identical(oldDelegate.edgeStatuses, edgeStatuses) ||
        !identical(oldDelegate.obstacles, obstacles) ||
        !identical(oldDelegate.bottlenecks, bottlenecks) ||
        oldDelegate.showFlowOverlay != showFlowOverlay ||
        oldDelegate.showEdgeStatus != showEdgeStatus ||
        oldDelegate.showBottlenecks != showBottlenecks ||
        oldDelegate.rows != rows ||
        oldDelegate.cols != cols;
  }
}

class MapDynamicPainter extends CustomPainter {
  final int rows;
  final int cols;
  final List<int> routeLocations;
  final double routeProgress;
  final NavDot? userDot;
  final double navProgress;
  final Rect? visibleRect;
  final Offset? debugTap;
  final Offset? debugPoiCenter;
  final bool? showDebug;
  final MapPoi? destPoi;

  MapDynamicPainter({
    required this.rows,
    required this.cols,
    required this.routeLocations,
    this.routeProgress = 1.0,
    this.userDot,
    this.navProgress = 0,
    this.visibleRect,
    this.debugTap,
    this.debugPoiCenter,
    this.showDebug,
    this.destPoi,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / cols;
    final cellHeight = size.height / rows;

    final clip = visibleRect;
    final colStart = clip == null
        ? 0
        : (clip.left / cellWidth).floor().clamp(0, cols - 1);
    final colEnd = clip == null
        ? cols - 1
        : (clip.right / cellWidth).ceil().clamp(0, cols - 1);
    final rowStart = clip == null
        ? 0
        : (clip.top / cellHeight).floor().clamp(0, rows - 1);
    final rowEnd = clip == null
        ? rows - 1
        : (clip.bottom / cellHeight).ceil().clamp(0, rows - 1);

    if (routeLocations.isNotEmpty && routeProgress > 0) {
      _paintRoute(
        canvas,
        cellWidth,
        cellHeight,
        rowStart,
        rowEnd,
        colStart,
        colEnd,
      );
    }

    // Redraw the destination POI on top of the route line. POIs live in the
    // static layer below, so without this the route's end cap paints over the
    // destination marker and hides it.
    if (destPoi != null && routeLocations.isNotEmpty) {
      _paintDestPoi(canvas, cellWidth, cellHeight);
    }

    if (userDot != null) {
      _paintUserDot(canvas, cellWidth, cellHeight);
    }

    if (showDebug ?? false) {
      final debugRadius = math.min(cellWidth, cellHeight) * 0.2;
      if (debugTap != null) {
        canvas.drawCircle(debugTap!, debugRadius, _debugTapPaint);
      }
      if (debugPoiCenter != null) {
        canvas.drawCircle(debugPoiCenter!, debugRadius, _debugPoiPaint);
      }
    }
  }

  void _paintDestPoi(Canvas canvas, double cellWidth, double cellHeight) {
    final poi = destPoi;
    if (poi == null) return;
    if (poi.gridRow < 0 ||
        poi.gridRow >= rows ||
        poi.gridCol < 0 ||
        poi.gridCol >= cols) {
      return;
    }
    final center = Offset(
      poi.gridCol * cellWidth + cellWidth / 2,
      poi.gridRow * cellHeight + cellHeight / 2,
    );
    final radius = math.min(cellWidth, cellHeight) * 0.35;
    final paint = _poiPaints[poi.poiType] ?? _poiFallbackPaint;

    // Background-colored halo + ink stroke lift the marker clear of the route
    // line it sits on, so the destination stays legible.
    _destPoiStrokePaint.strokeWidth = math.max(1.5, radius * 0.32);
    canvas.drawCircle(center, radius + _destPoiStrokePaint.strokeWidth, _destPoiHaloPaint);
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, radius, _destPoiStrokePaint);
  }

  void _paintUserDot(Canvas canvas, double cellWidth, double cellHeight) {
    final dot = userDot;
    if (dot == null) return;
    final from = _cellCenter(dot.fromLocation, cellWidth, cellHeight);
    final to = _cellCenter(dot.toLocation, cellWidth, cellHeight);
    final t = dot.t.clamp(0.0, 1.0).toDouble();
    final center = Offset.lerp(from, to, t) ?? from;
    final baseRadius = math.min(cellWidth, cellHeight) * 0.42;

    _userDotStrokePaint.strokeWidth = math.max(1.5, baseRadius * 0.28);
    canvas.drawCircle(center, baseRadius * 1.85, _userDotRingPaint);
    canvas.drawCircle(center, baseRadius, _userDotPaint);
    canvas.drawCircle(center, baseRadius, _userDotStrokePaint);
  }

  void _paintRoute(
    Canvas canvas,
    double cellWidth,
    double cellHeight,
    int rowStart,
    int rowEnd,
    int colStart,
    int colEnd,
  ) {
    final n = routeLocations.length;
    final progress = routeProgress.clamp(0.0, 1.0).toDouble();
    final navigationProgress = navProgress.clamp(0.0, 1.0).toDouble();
    final isNavigating = navigationProgress > 0;
    final segments = (n - 1).clamp(0, n);
    final drawProgress = isNavigating ? 1.0 : progress;
    final reached = segments * drawProgress;
    final lastSegmentIndex = reached.floor();
    final partial = reached - lastSegmentIndex;
    final cellsToPaint = (lastSegmentIndex + 1).clamp(0, n);

    for (var i = 0; i < cellsToPaint; i++) {
      final location = routeLocations[i];
      final row = location ~/ cols;
      final col = location % cols;
      if (row < 0 || row >= rows || col < 0 || col >= cols) continue;
      if (row < rowStart || row > rowEnd || col < colStart || col > colEnd) {
        continue;
      }
      canvas.drawRect(
        Rect.fromLTWH(col * cellWidth, row * cellHeight, cellWidth, cellHeight),
        _routeCellPaint,
      );
    }

    final stroke = math.min(cellWidth, cellHeight) * 0.25;
    _routeHaloPaint.strokeWidth = stroke + 2;
    _routeLinePaint.strokeWidth = stroke;
    _routeTraveledHaloPaint.strokeWidth = stroke + 2;
    _routeTraveledLinePaint.strokeWidth = stroke;

    if (isNavigating) {
      _paintNavigationRoute(canvas, cellWidth, cellHeight, navigationProgress);
      return;
    }

    for (var i = 0; i < lastSegmentIndex && i < n - 1; i++) {
      final a = _cellCenter(routeLocations[i], cellWidth, cellHeight);
      final b = _cellCenter(routeLocations[i + 1], cellWidth, cellHeight);
      canvas.drawLine(a, b, _routeHaloPaint);
      canvas.drawLine(a, b, _routeLinePaint);
    }

    if (partial > 0 && lastSegmentIndex < n - 1) {
      final a = _cellCenter(
        routeLocations[lastSegmentIndex],
        cellWidth,
        cellHeight,
      );
      final b = _cellCenter(
        routeLocations[lastSegmentIndex + 1],
        cellWidth,
        cellHeight,
      );
      final mid = Offset.lerp(a, b, partial)!;
      canvas.drawLine(a, mid, _routeHaloPaint);
      canvas.drawLine(a, mid, _routeLinePaint);
    }
  }

  void _paintNavigationRoute(
    Canvas canvas,
    double cellWidth,
    double cellHeight,
    double progress,
  ) {
    final n = routeLocations.length;
    if (n < 2) return;

    final segments = n - 1;
    final reached = segments * progress;
    final splitIndex = reached.floor().clamp(0, segments - 1).toInt();
    final splitT = (reached - splitIndex).clamp(0.0, 1.0).toDouble();
    final splitStart = _cellCenter(
      routeLocations[splitIndex],
      cellWidth,
      cellHeight,
    );
    final splitEnd = _cellCenter(
      routeLocations[splitIndex + 1],
      cellWidth,
      cellHeight,
    );
    final splitPoint = Offset.lerp(splitStart, splitEnd, splitT) ?? splitStart;

    for (var i = 0; i < splitIndex; i++) {
      _drawRouteSegment(
        canvas,
        _cellCenter(routeLocations[i], cellWidth, cellHeight),
        _cellCenter(routeLocations[i + 1], cellWidth, cellHeight),
        _routeTraveledHaloPaint,
        _routeTraveledLinePaint,
      );
    }

    if (progress > 0) {
      _drawRouteSegment(
        canvas,
        splitStart,
        splitPoint,
        _routeTraveledHaloPaint,
        _routeTraveledLinePaint,
      );
    }

    if (progress < 1) {
      _drawRouteSegment(
        canvas,
        splitPoint,
        splitEnd,
        _routeHaloPaint,
        _routeLinePaint,
      );
      for (var i = splitIndex + 1; i < n - 1; i++) {
        _drawRouteSegment(
          canvas,
          _cellCenter(routeLocations[i], cellWidth, cellHeight),
          _cellCenter(routeLocations[i + 1], cellWidth, cellHeight),
          _routeHaloPaint,
          _routeLinePaint,
        );
      }
    }
  }

  void _drawRouteSegment(
    Canvas canvas,
    Offset from,
    Offset to,
    Paint haloPaint,
    Paint linePaint,
  ) {
    canvas.drawLine(from, to, haloPaint);
    canvas.drawLine(from, to, linePaint);
  }

  Offset _cellCenter(int location, double cellWidth, double cellHeight) {
    final row = location ~/ cols;
    final col = location % cols;
    return Offset(
      col * cellWidth + cellWidth / 2,
      row * cellHeight + cellHeight / 2,
    );
  }

  @override
  bool shouldRepaint(covariant MapDynamicPainter oldDelegate) {
    return !identical(oldDelegate.routeLocations, routeLocations) ||
        oldDelegate.routeProgress != routeProgress ||
        oldDelegate.userDot != userDot ||
        oldDelegate.navProgress != navProgress ||
        oldDelegate.rows != rows ||
        oldDelegate.cols != cols ||
        oldDelegate.visibleRect != visibleRect ||
        oldDelegate.debugTap != debugTap ||
        oldDelegate.debugPoiCenter != debugPoiCenter ||
        oldDelegate.destPoi != destPoi ||
        (oldDelegate.showDebug ?? false) != (showDebug ?? false);
  }
}

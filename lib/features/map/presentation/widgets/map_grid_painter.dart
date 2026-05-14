// ignore_for_file: lines_longer_than_80_chars, cascade_invocations
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hospital_app/features/map/data/models/map_poi.dart';
import 'package:hospital_app/features/map/presentation/theme/map_tokens.dart';

final Paint _backgroundPaint = Paint()..color = MapSurface.background;
final Paint _walkablePaint = Paint()..color = MapSurface.walkable;
final Paint _routeCellPaint = Paint()..color = MapSurface.routeCell;
final Paint _debugTapPaint = Paint()..color = const Color(0xFFE53935);
final Paint _debugPoiPaint = Paint()..color = const Color(0xFF43A047);
final Paint _routeHaloPaint = Paint()
  ..color = MapSurface.routeLineHalo
  ..strokeCap = StrokeCap.round;
final Paint _routeLinePaint = Paint()
  ..color = MapSurface.routeLine
  ..strokeCap = StrokeCap.round;

final Map<String, Paint> _poiPaints = {
  for (final entry in MapPoiPalette.byType.entries)
    entry.key: Paint()..color = entry.value,
};
final Paint _poiFallbackPaint = Paint()..color = MapPoiPalette.fallback;

class MapGridPainter extends CustomPainter {
  final int rows;
  final int cols;
  final Set<int> walkableLocations;
  final List<MapPoi> pois;
  final List<int> routeLocations;
  final double routeProgress;
  final Rect? visibleRect;
  final Offset? debugTap;
  final Offset? debugPoiCenter;
  final bool? showDebug;

  MapGridPainter({
    required this.rows,
    required this.cols,
    required this.walkableLocations,
    required this.pois,
    required this.routeLocations,
    this.routeProgress = 1.0,
    this.visibleRect,
    this.debugTap,
    this.debugPoiCenter,
    this.showDebug,
  }) : super(repaint: null);

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / cols;
    final cellHeight = size.height / rows;

    canvas.drawRect(Offset.zero & size, _backgroundPaint);

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

    for (final location in walkableLocations) {
      final row = location ~/ cols;
      final col = location % cols;
      if (row < rowStart || row > rowEnd || col < colStart || col > colEnd) {
        continue;
      }
      canvas.drawRect(
        Rect.fromLTWH(col * cellWidth, row * cellHeight, cellWidth, cellHeight),
        _walkablePaint,
      );
    }

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

    final radius = math.min(cellWidth, cellHeight) * 0.35;

    for (final poi in pois) {
      if (!_isPoiInBounds(poi)) continue;
      if (poi.gridRow < rowStart ||
          poi.gridRow > rowEnd ||
          poi.gridCol < colStart ||
          poi.gridCol > colEnd) {
        continue;
      }
      final center = _poiCenter(poi, cellWidth, cellHeight);
      final paint = _poiPaints[poi.poiType] ?? _poiFallbackPaint;
      canvas.drawCircle(center, radius, paint);
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
    final progress = routeProgress.clamp(0.0, 1.0);
    final segments = (n - 1).clamp(0, n);
    final reached = segments * progress;
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
  bool shouldRepaint(covariant MapGridPainter oldDelegate) {
    return !identical(oldDelegate.pois, pois) ||
        !identical(oldDelegate.walkableLocations, walkableLocations) ||
        !identical(oldDelegate.routeLocations, routeLocations) ||
        oldDelegate.routeProgress != routeProgress ||
        oldDelegate.rows != rows ||
        oldDelegate.cols != cols ||
        oldDelegate.visibleRect != visibleRect ||
        oldDelegate.debugTap != debugTap ||
        oldDelegate.debugPoiCenter != debugPoiCenter ||
        (oldDelegate.showDebug ?? false) != (showDebug ?? false);
  }
}

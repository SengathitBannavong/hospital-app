import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hospital_app/features/map/data/models/map_edge.dart';
import 'package:hospital_app/features/map/data/models/map_poi.dart';

class MapGridPainter extends CustomPainter {
  final int rows;
  final int cols;
  final List<MapEdge> edges;
  final List<MapPoi> pois;
  final List<int> routeLocations;
  final Offset? debugTap;
  final Offset? debugPoiCenter;
  final bool? showDebug;

  MapGridPainter({
    required this.rows,
    required this.cols,
    required this.edges,
    required this.pois,
    required this.routeLocations,
    this.debugTap,
    this.debugPoiCenter,
    this.showDebug,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // The page gives this painter a square-cell grid size. Keep all drawing
    // derived from rows and cols so visual positions match tap hitboxes.
    final cellWidth = size.width / cols;
    final cellHeight = size.height / rows;

    final backgroundPaint = Paint()..color = const Color(0xFFF5F7FA);
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final walkablePaint = Paint()..color = const Color(0xFFE2E8F0);
    final walkableLocations = <int>{};

    for (final edge in edges) {
      walkableLocations
        ..add(edge.fromLocation)
        ..add(edge.toLocation);
    }

    for (final location in walkableLocations) {
      final row = location ~/ cols;
      final col = location % cols;
      if (row < 0 || row >= rows || col < 0 || col >= cols) {
        continue;
      }
      final rect = Rect.fromLTWH(
        col * cellWidth,
        row * cellHeight,
        cellWidth,
        cellHeight,
      );
      canvas.drawRect(rect, walkablePaint);
    }

    if (routeLocations.isNotEmpty) {
      final routeCellPaint = Paint()..color = const Color(0xFFB3E5FC);
      for (final location in routeLocations) {
        final row = location ~/ cols;
        final col = location % cols;
        if (row < 0 || row >= rows || col < 0 || col >= cols) {
          continue;
        }
        final rect = Rect.fromLTWH(
          col * cellWidth,
          row * cellHeight,
          cellWidth,
          cellHeight,
        );
        canvas.drawRect(rect, routeCellPaint);
      }

      final linePaint = Paint()
        ..color = const Color(0xFF1976D2)
        ..strokeWidth = math.min(cellWidth, cellHeight) * 0.25
        ..strokeCap = StrokeCap.round;

      for (var i = 0; i < routeLocations.length - 1; i++) {
        final start = routeLocations[i];
        final end = routeLocations[i + 1];
        final startCenter = _cellCenter(start, cellWidth, cellHeight);
        final endCenter = _cellCenter(end, cellWidth, cellHeight);
        canvas.drawLine(startCenter, endCenter, linePaint);
      }
    }

    final radius = math.min(cellWidth, cellHeight) * 0.35;

    for (final poi in pois) {
      if (!_isPoiInBounds(poi)) {
        continue;
      }

      final center = _poiCenter(poi, cellWidth, cellHeight);

      final paint = Paint()..color = _poiColor(poi.poiType);
      canvas.drawCircle(center, radius, paint);
    }

    if (showDebug ?? false) {
      final debugRadius = math.min(cellWidth, cellHeight) * 0.2;
      if (debugTap != null) {
        final tapPaint = Paint()..color = const Color(0xFFE53935);
        canvas.drawCircle(debugTap!, debugRadius, tapPaint);
      }
      if (debugPoiCenter != null) {
        final poiPaint = Paint()..color = const Color(0xFF43A047);
        canvas.drawCircle(debugPoiCenter!, debugRadius, poiPaint);
      }
    }
  }

  Offset _cellCenter(int location, double cellWidth, double cellHeight) {
    // Route locations are flattened row-major indexes from the backend.
    final row = location ~/ cols;
    final col = location % cols;
    return Offset(
      col * cellWidth + cellWidth / 2,
      row * cellHeight + cellHeight / 2,
    );
  }

  Offset _poiCenter(MapPoi poi, double cellWidth, double cellHeight) {
    // POIs use row/col cell coordinates; draw them at the same center point
    // used by MapPage hit testing.
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

  Color _poiColor(String type) {
    switch (type) {
      case 'entrance':
        return const Color(0xFF43A047);
      case 'room':
        return const Color(0xFF1E88E5);
      case 'pharmacy':
        return const Color(0xFF8E24AA);
      case 'wc':
        return const Color(0xFF6D4C41);
      case 'canteen':
        return const Color(0xFFFFA000);
      case 'info':
        return const Color(0xFF00897B);
      case 'wifi':
        return const Color(0xFF5E35B1);
      case 'corridor':
        return const Color(0xFF546E7A);
      default:
        return const Color(0xFF757575);
    }
  }

  @override
  bool shouldRepaint(covariant MapGridPainter oldDelegate) {
    return oldDelegate.pois != pois ||
        oldDelegate.edges != edges ||
        oldDelegate.routeLocations != routeLocations ||
        oldDelegate.debugTap != debugTap ||
        oldDelegate.debugPoiCenter != debugPoiCenter ||
        (oldDelegate.showDebug ?? false) != (showDebug ?? false);
  }
}

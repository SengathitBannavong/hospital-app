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

  MapGridPainter({
    required this.rows,
    required this.cols,
    required this.edges,
    required this.pois,
    required this.routeLocations,
  });

  @override
  void paint(Canvas canvas, Size size) {
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
      final center = Offset(
        poi.gridCol * cellWidth + cellWidth / 2,
        poi.gridRow * cellHeight + cellHeight / 2,
      );
      final paint = Paint()..color = _poiColor(poi.poiType);
      canvas.drawCircle(center, radius, paint);
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
    return true;
  }
}

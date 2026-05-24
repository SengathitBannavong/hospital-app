// Debug grid painter for the hospital map.
//
// Overlays cell grid lines, row/column rulers, and (optionally) the
// grid_location of every visible cell, so you can verify that POIs, walkable
// cells, and routes line up with the grid math (location = row*cols + col).
//
// Everything below is intentionally COMMENTED OUT so it never ships.
//
// HOW TO ENABLE
//   1. Uncomment the implementation: delete the `/*` line just below and the
//      matching `*/` line at the very bottom of this file.
//   2. In map_page.dart, layer it over the existing CustomPaint. Easiest is to
//      add it as a foregroundPainter on the current CustomPaint inside the
//      AnimatedBuilder, e.g.:
//
//        CustomPaint(
//          size: Size(gridWidth, gridHeight),
//          painter: MapGridPainter( ...unchanged... ),
//          foregroundPainter: MapDebugGridPainter(
//            rows: rows,
//            cols: cols,
//            visibleRect: visibleRect,
//            // labelCells: true, // also print each visible cell's location
//          ),
//        ),
//
//      (add the import:)
//        import 'package:hospital_app/features/map/presentation/widgets/map_debug_grid_painter.dart';
//
//   3. When you're done, restore the `/*` and `*/` lines to comment it back out.

import 'dart:math' as math;

import 'package:flutter/material.dart';

class MapDebugGridPainter extends CustomPainter {
  final int rows;
  final int cols;

  /// Visible scene rect (same value passed to MapGridPainter) so only on-screen
  /// cells are drawn. Pass null to draw the whole grid.
  final Rect? visibleRect;

  /// Draw a heavier line and an axis index every `labelEvery` cells.
  final int labelEvery;

  /// When true, prints the grid_location inside every visible cell. Cheap
  /// because `visibleRect` already clips to the viewport — zoom in for clarity.
  final bool labelCells;

  MapDebugGridPainter({
    required this.rows,
    required this.cols,
    this.visibleRect,
    this.labelEvery = 5,
    this.labelCells = false,
  });

  static final Paint _minorLine = Paint()
    ..color = const Color(0x22000000)
    ..strokeWidth = 0.5;
  static final Paint _majorLine = Paint()
    ..color = const Color(0x55D32F2F)
    ..strokeWidth = 1;

  @override
  void paint(Canvas canvas, Size size) {
    if (rows <= 0 || cols <= 0) return;
    final cellW = size.width / cols;
    final cellH = size.height / rows;
    final clip = visibleRect;

    final colStart = clip == null
        ? 0
        : (clip.left / cellW).floor().clamp(0, cols);
    final colEnd = clip == null
        ? cols
        : (clip.right / cellW).ceil().clamp(0, cols);
    final rowStart = clip == null
        ? 0
        : (clip.top / cellH).floor().clamp(0, rows);
    final rowEnd = clip == null
        ? rows
        : (clip.bottom / cellH).ceil().clamp(0, rows);

    // Vertical lines.
    for (var c = colStart; c <= colEnd; c++) {
      final x = c * cellW;
      canvas.drawLine(
        Offset(x, rowStart * cellH),
        Offset(x, rowEnd * cellH),
        c % labelEvery == 0 ? _majorLine : _minorLine,
      );
    }
    // Horizontal lines.
    for (var r = rowStart; r <= rowEnd; r++) {
      final y = r * cellH;
      canvas.drawLine(
        Offset(colStart * cellW, y),
        Offset(colEnd * cellW, y),
        r % labelEvery == 0 ? _majorLine : _minorLine,
      );
    }

    // Column ruler across the top, row ruler down the left edge.
    final axisSize = math.min(cellH * 0.55, 9).toDouble();
    final firstCol = colStart - (colStart % labelEvery);
    for (var c = firstCol; c < colEnd; c += labelEvery) {
      if (c < 0) continue;
      final at = Offset(c * cellW + 1, rowStart * cellH + 1);
      _text(canvas, '$c', at, axisSize);
    }
    final firstRow = rowStart - (rowStart % labelEvery);
    for (var r = firstRow; r < rowEnd; r += labelEvery) {
      if (r < 0) continue;
      final at = Offset(colStart * cellW + 1, r * cellH + 1);
      _text(canvas, '$r', at, axisSize);
    }

    // Optional: grid_location label in every visible cell.
    if (labelCells) {
      final cellSize = math.min(cellH * 0.32, 7).toDouble();
      for (var r = rowStart; r < rowEnd; r++) {
        for (var c = colStart; c < colEnd; c++) {
          final location = r * cols + c;
          _text(
            canvas,
            '$location',
            Offset(c * cellW + cellW * 0.08, r * cellH + cellH * 0.3),
            cellSize,
            color: const Color(0x99000000),
          );
        }
      }
    }
  }

  void _text(
    Canvas canvas,
    String text,
    Offset at,
    double fontSize, {
    Color color = const Color(0xCCD32F2F),
  }) {
    if (fontSize < 3) return; // unreadable when zoomed out; skip
    TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(color: color, fontSize: fontSize),
        ),
        textDirection: TextDirection.ltr,
      )
      ..layout()
      ..paint(canvas, at);
  }

  @override
  bool shouldRepaint(covariant MapDebugGridPainter old) =>
      old.rows != rows ||
      old.cols != cols ||
      old.visibleRect != visibleRect ||
      old.labelEvery != labelEvery ||
      old.labelCells != labelCells;
}

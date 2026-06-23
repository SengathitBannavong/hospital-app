// ignore_for_file: avoid_print, cascade_invocations
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Render map PNGs from .map ASCII files', () async {
    // Ensure Flutter bindings are initialized
    TestWidgetsFlutterBinding.ensureInitialized();

    // Render every assets/map/{id}.map -> assets/map/{id}.png so the bundled
    // base images stay in sync with their source and are named by mapId (the
    // id the backend assigns and that map_asset_registry.dart keys on).
    const mapDir = 'assets/map';
    final mapFiles =
        Directory(mapDir)
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.map'))
            .map((f) => f.path)
            .toList()
          ..sort();
    if (mapFiles.isEmpty) {
      print('No .map files found in $mapDir');
    }

    // Colors matching MapSurface background and walkable
    final backgroundPaint = Paint()..color = const Color(0xFFF1F4F8);
    final walkablePaint = Paint()..color = const Color(0xFFE3E8EF);

    for (final mapFilePath in mapFiles) {
      final file = File(mapFilePath);
      if (!file.existsSync()) {
        print('Skipping non-existent map: $mapFilePath');
        continue;
      }

      final lines = await file.readAsLines();
      if (lines.length < 4) continue;

      // Parse header
      int? rows;
      int? cols;
      var headerIndex = 0;
      for (; headerIndex < lines.length; headerIndex++) {
        final line = lines[headerIndex].trim();
        if (line.startsWith('type')) continue;
        if (line.startsWith('height')) {
          rows = int.parse(line.split(' ')[1]);
          continue;
        }
        if (line.startsWith('width')) {
          cols = int.parse(line.split(' ')[1]);
          continue;
        }
        if (line.startsWith('map')) {
          headerIndex++;
          break;
        }
      }

      if (rows == null || cols == null) {
        print('Invalid map file header in $mapFilePath');
        continue;
      }

      // Resolution setting: ~8 px per cell (as specified in §4)
      const cellSize = 8.0;
      final imageWidth = cols * cellSize;
      final imageHeight = rows * cellSize;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Draw background (walls)
      canvas.drawRect(
        Rect.fromLTWH(0, 0, imageWidth, imageHeight),
        backgroundPaint,
      );

      // Draw walkable cells (floor)
      var gridRow = 0;
      for (var i = headerIndex; i < lines.length && gridRow < rows; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        for (var col = 0; col < line.length && col < cols; col++) {
          final char = line[col];
          if (char != '@') {
            canvas.drawRect(
              Rect.fromLTWH(
                col * cellSize,
                gridRow * cellSize,
                cellSize,
                cellSize,
              ),
              walkablePaint,
            );
          }
        }
        gridRow++;
      }

      final picture = recorder.endRecording();
      final img = await picture.toImage(
        imageWidth.toInt(),
        imageHeight.toInt(),
      );
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        print('Failed to convert image to bytes for $mapFilePath');
        continue;
      }

      final pngBytes = byteData.buffer.asUint8List();
      final filename = mapFilePath.split('/').last;
      final outName = filename.replaceAll('.map', '').toLowerCase();
      final outFilePath = 'assets/map/$outName.png';
      final outFile = File(outFilePath);
      await outFile.parent.create(recursive: true);
      await outFile.writeAsBytes(pngBytes);
      print('Rendered $mapFilePath ($cols x $rows) -> $outFilePath');
    }
  });
}

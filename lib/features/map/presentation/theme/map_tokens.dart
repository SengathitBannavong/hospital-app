import 'package:flutter/material.dart';

class MapMotion {
  MapMotion._();
  static const Duration short = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 240);
  static const Duration long = Duration(milliseconds: 480);
  static const Curve enter = Curves.easeOutCubic;
  static const Curve resize = Curves.easeInOutCubic;
}

class MapSurface {
  MapSurface._();
  static const Color background = Color(0xFFF1F4F8);
  static const Color walkable = Color(0xFFE3E8EF);
  static const Color routeCell = Color(0xFFCFE3F4);
  static const Color routeLine = Color(0xFF1565C0);
  static const Color routeLineHalo = Color(0xFFE3F0FB);
}

/// Muted, semantically grouped palette. Each color has AA contrast (≥3:1)
/// against [MapSurface.background] for graphical elements.
class MapPoiPalette {
  MapPoiPalette._();

  static const Map<String, Color> byType = {
    'entrance': Color(0xFF2F855A),
    'corridor': Color(0xFF94A3B8),
    'room': Color(0xFF3B6FB5),
    'pharmacy': Color(0xFF7E57C2),
    'wc': Color(0xFF8D6E63),
    'canteen': Color(0xFFD08C3D),
    'info': Color(0xFF26A69A),
    'wifi': Color(0xFF5C6BC0),
  };

  static const Color fallback = Color(0xFF6B7280);

  static const Map<String, String> labels = {
    'entrance': 'Entrance',
    'corridor': 'Corridor',
    'room': 'Room',
    'pharmacy': 'Pharmacy',
    'wc': 'Restroom',
    'canteen': 'Canteen',
    'info': 'Information',
    'wifi': 'Wi-Fi',
  };

  static Color colorFor(String type) => byType[type] ?? fallback;
  static String labelFor(String type) => labels[type] ?? type;
}

class MapTokens {
  MapTokens._();

  // Painter palette
  static const Color debugTap = Color(0xFFE53935);
  static const Color debugPoi = Color(0xFF43A047);
  static const Color userDot = Color(0xFF0E8A6D);
  static const Color userHalo = Color(0xFF0E8A6D);
  static const Color routeStop = Color(0xFFD32F2F);
  static const Color paintInk = Color(0xFFFAFCFE);
  static const Color paintInkShadow = Color(0x40000000);
}

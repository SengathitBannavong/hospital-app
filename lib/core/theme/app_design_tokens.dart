import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// SPACING TOKENS
// ─────────────────────────────────────────────

class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;

  // Page padding
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 20.0);
  static const EdgeInsets pageWithTop = EdgeInsets.fromLTRB(20, 16, 20, 20);

  // Card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets cardPaddingLarge = EdgeInsets.all(20.0);
}

// ─────────────────────────────────────────────
// BORDER RADIUS TOKENS
// ─────────────────────────────────────────────

class AppRadius {
  AppRadius._();

  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double full = 999.0;

  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderFull = BorderRadius.all(
    Radius.circular(full),
  );
}

// ─────────────────────────────────────────────
// SHADOW TOKENS
// ─────────────────────────────────────────────

class AppShadows {
  AppShadows._();

  // Subtle shadow for cards
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x05000000), blurRadius: 24, offset: Offset(0, 4)),
  ];

  // Slightly elevated (modals, dropdowns)
  static const List<BoxShadow> elevated = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 16, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x08000000), blurRadius: 40, offset: Offset(0, 16)),
  ];

  // Bottom navigation bar
  static const List<BoxShadow> bottomNav = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, -4)),
  ];
}

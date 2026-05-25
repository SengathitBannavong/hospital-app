import 'package:flutter/material.dart';
import 'app_colors.dart';

// ─────────────────────────────────────────────
// TEXT THEME (Plus Jakarta Sans)
// ─────────────────────────────────────────────

class AppTextTheme {
  AppTextTheme._();

  static TextTheme _base(Color primaryColor, Color secondaryColor) {
    return TextTheme(
      // ── Display ──
      displayLarge: TextStyle(fontFamily: 'Plus Jakarta Sans',
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: primaryColor,
        height: 1.2,
      ),
      displayMedium: TextStyle(fontFamily: 'Plus Jakarta Sans',
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: primaryColor,
        height: 1.25,
      ),
      displaySmall: TextStyle(fontFamily: 'Plus Jakarta Sans',
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.3,
      ),

      // ── Headlines ──
      headlineLarge: TextStyle(fontFamily: 'Plus Jakarta Sans',
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.3,
      ),
      headlineMedium: TextStyle(fontFamily: 'Plus Jakarta Sans',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.35,
      ),
      headlineSmall: TextStyle(fontFamily: 'Plus Jakarta Sans',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.4,
      ),

      // ── Titles ──
      titleLarge: TextStyle(fontFamily: 'Plus Jakarta Sans',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.4,
      ),
      titleMedium: TextStyle(fontFamily: 'Plus Jakarta Sans',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.4,
      ),
      titleSmall: TextStyle(fontFamily: 'Plus Jakarta Sans',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.4,
      ),

      // ── Body ──
      bodyLarge: TextStyle(fontFamily: 'Plus Jakarta Sans',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primaryColor,
        height: 1.6,
      ),
      bodyMedium: TextStyle(fontFamily: 'Plus Jakarta Sans',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: primaryColor,
        height: 1.6,
      ),
      bodySmall: TextStyle(fontFamily: 'Plus Jakarta Sans',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        height: 1.5,
      ),

      // ── Labels ──
      labelLarge: TextStyle(fontFamily: 'Plus Jakarta Sans',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryColor,
        height: 1.4,
      ),
      labelMedium: TextStyle(fontFamily: 'Plus Jakarta Sans',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
        height: 1.4,
      ),
      labelSmall: TextStyle(fontFamily: 'Plus Jakarta Sans',
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
        height: 1.4,
        letterSpacing: 0.5,
      ),
    );
  }

  static TextTheme get light =>
      _base(AppColors.textPrimaryLight, AppColors.textSecondaryLight);

  static TextTheme get dark =>
      _base(AppColors.textPrimaryDark, AppColors.textSecondaryDark);
}

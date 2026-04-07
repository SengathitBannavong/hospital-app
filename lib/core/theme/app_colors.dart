import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// COLOR TOKENS
// ─────────────────────────────────────────────

class AppColors {
  AppColors._();

  // ── Primary: Medical Blue ──
  // Conveys trust, professionalism, calm
  static const Color primary = Color(0xFF0A6DC2);
  static const Color primaryLight = Color(0xFF3B9FE3);
  static const Color primaryDark = Color(0xFF074E8C);
  static const Color primarySurface = Color(0xFFE8F4FD);

  // ── Secondary: Health Green ──
  // Conveys health, vitality, positive outcomes
  static const Color secondary = Color(0xFF0E8A6D);
  static const Color secondaryLight = Color(0xFF2DBDA0);
  static const Color secondaryDark = Color(0xFF086650);
  static const Color secondarySurface = Color(0xFFF0FAF6);

  // ── Semantic Colors ──
  static const Color success = Color(0xFF27AE60);
  static const Color successSurface = Color(0xFFEDF9F0);
  static const Color warning = Color(0xFFF39C12);
  static const Color warningSurface = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFE74C3C);
  static const Color errorSurface = Color(0xFFFDECEC);
  static const Color info = Color(0xFF0A6DC2);
  static const Color infoSurface = Color(0xFFE8F4FD);

  // ── Neutral (Light Mode) ──
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F3F5);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderSubtleLight = Color(0xFFF1F3F5);
  static const Color textPrimaryLight = Color(0xFF1A1D21);
  static const Color textSecondaryLight = Color(0xFF4A5568);
  static const Color textTertiaryLight = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Neutral (Dark Mode) ──
  static const Color backgroundDark = Color(0xFF121417);
  static const Color surfaceDark = Color(0xFF1E2128);
  static const Color surfaceVariantDark = Color(0xFF2A2D35);
  static const Color borderDark = Color(0xFF2F3440);
  static const Color borderSubtleDark = Color(0xFF252830);
  static const Color textPrimaryDark = Color(0xFFE2E8F0);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);

  // ── Appointment Status Colors ──
  static const Color statusAvailable = Color(0xFF27AE60);
  static const Color statusInConsultation = Color(0xFF0A6DC2);
  static const Color statusWaiting = Color(0xFFF39C12);
  static const Color statusEmergency = Color(0xFFE74C3C);
  static const Color statusOffline = Color(0xFF94A3B8);

  // ── Department Accent Colors ──
  // Use for department tags, category badges, icons
  static const Color deptCardiology = Color(0xFFE74C3C);
  static const Color deptNeurology = Color(0xFF8E44AD);
  static const Color deptOrthopedics = Color(0xFF0A6DC2);
  static const Color deptPediatrics = Color(0xFFF39C12);
  static const Color deptDermatology = Color(0xFF1ABC9C);
  static const Color deptGeneral = Color(0xFF2ECC71);
}

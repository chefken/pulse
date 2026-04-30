import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Dark palette ───────────────────────────────────
  static const darkBg           = Color(0xFF0A0A0A);
  static const darkSurface      = Color(0xFF161616);
  static const darkSurfaceHigh  = Color(0xFF222222);
  static const darkSurfaceTop   = Color(0xFF2E2E2E);
  static const darkBorder       = Color(0xFF2A2A2A);

  static const darkTextPrimary   = Color(0xFFF5F5F5);
  static const darkTextSecondary = Color(0xFF999999);
  static const darkTextMuted     = Color(0xFF555555);

  // ── Light palette ──────────────────────────────────
  static const lightBg           = Color(0xFFF7F7F7);
  static const lightSurface      = Color(0xFFFFFFFF);
  static const lightSurfaceHigh  = Color(0xFFF0F0F0);
  static const lightSurfaceTop   = Color(0xFFE8E8E8);
  static const lightBorder       = Color(0xFFE0E0E0);

  static const lightTextPrimary   = Color(0xFF0A0A0A);
  static const lightTextSecondary = Color(0xFF666666);
  static const lightTextMuted     = Color(0xFFAAAAAA);

  // ── Semantic — kept minimal, grey-based ────────────
  static const success = Color(0xFF4CAF50);
  static const danger  = Color(0xFFE53935);
  static const warning = Color(0xFFFF8F00);

  // ── Context helpers ────────────────────────────────
  static Color bg(BuildContext context) =>
      _d(context) ? darkBg : lightBg;

  static Color surface(BuildContext context) =>
      _d(context) ? darkSurface : lightSurface;

  static Color surfaceHigh(BuildContext context) =>
      _d(context) ? darkSurfaceHigh : lightSurfaceHigh;

  static Color surfaceTop(BuildContext context) =>
      _d(context) ? darkSurfaceTop : lightSurfaceTop;

  static Color border(BuildContext context) =>
      _d(context) ? darkBorder : lightBorder;

  static Color textPrimary(BuildContext context) =>
      _d(context) ? darkTextPrimary : lightTextPrimary;

  static Color textSecondary(BuildContext context) =>
      _d(context) ? darkTextSecondary : lightTextSecondary;

  static Color textMuted(BuildContext context) =>
      _d(context) ? darkTextMuted : lightTextMuted;

  static Color btnBg(BuildContext context) =>
      _d(context) ? darkTextPrimary : lightTextPrimary;

  static Color btnText(BuildContext context) =>
      _d(context) ? darkBg : lightBg;

  static bool _d(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
}
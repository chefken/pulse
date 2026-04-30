import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Dark ───────────────────────────────────────────────
  static const darkBg           = Color(0xFF080808);
  static const darkSurface      = Color(0xFF111111);
  static const darkSurfaceHigh  = Color(0xFF1A1A1A);
  static const darkSurfaceTop   = Color(0xFF242424);
  static const darkBorder       = Color(0xFF202020);
  static const darkDivider      = Color(0xFF181818);

  static const darkTextPrimary   = Color(0xFFF0F0F0);
  static const darkTextSecondary = Color(0xFF808080);
  static const darkTextMuted     = Color(0xFF404040);

  // ── Light ──────────────────────────────────────────────
  static const lightBg           = Color(0xFFF8F8F8);
  static const lightSurface      = Color(0xFFFFFFFF);
  static const lightSurfaceHigh  = Color(0xFFF2F2F2);
  static const lightSurfaceTop   = Color(0xFFE8E8E8);
  static const lightBorder       = Color(0xFFE4E4E4);
  static const lightDivider      = Color(0xFFEEEEEE);

  static const lightTextPrimary   = Color(0xFF080808);
  static const lightTextSecondary = Color(0xFF787878);
  static const lightTextMuted     = Color(0xFFB8B8B8);

  // ── Semantic ────────────────────────────────────────────
  static const success = Color(0xFF3A9E6F);
  static const danger  = Color(0xFFD94040);

  // ── Context helpers ─────────────────────────────────────
  static Color bg(BuildContext c)            => _d(c) ? darkBg            : lightBg;
  static Color surface(BuildContext c)       => _d(c) ? darkSurface       : lightSurface;
  static Color surfaceHigh(BuildContext c)   => _d(c) ? darkSurfaceHigh   : lightSurfaceHigh;
  static Color surfaceTop(BuildContext c)    => _d(c) ? darkSurfaceTop    : lightSurfaceTop;
  static Color border(BuildContext c)        => _d(c) ? darkBorder        : lightBorder;
  static Color divider(BuildContext c)       => _d(c) ? darkDivider       : lightDivider;
  static Color textPrimary(BuildContext c)   => _d(c) ? darkTextPrimary   : lightTextPrimary;
  static Color textSecondary(BuildContext c) => _d(c) ? darkTextSecondary : lightTextSecondary;
  static Color textMuted(BuildContext c)     => _d(c) ? darkTextMuted     : lightTextMuted;
  static Color btnBg(BuildContext c)         => _d(c) ? darkTextPrimary   : lightTextPrimary;
  static Color btnText(BuildContext c)       => _d(c) ? darkBg            : lightBg;
  static Color dot(BuildContext c)           => _d(c) ? darkTextPrimary   : lightTextPrimary;

  static bool _d(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark;
}
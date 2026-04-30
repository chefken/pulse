import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark  => _build(isDark: true);
  static ThemeData get light => _build(isDark: false);

  static ThemeData _build({required bool isDark}) {
    final bg      = isDark ? AppColors.darkBg          : AppColors.lightBg;
    final surface = isDark ? AppColors.darkSurface     : AppColors.lightSurface;
    final border  = isDark ? AppColors.darkBorder      : AppColors.lightBorder;
    final primary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final second  = isDark ? AppColors.darkTextSecondary:AppColors.lightTextSecondary;
    final muted   = isDark ? AppColors.darkTextMuted   : AppColors.lightTextMuted;
    final br      = isDark ? Brightness.dark           : Brightness.light;

    return ThemeData(
      brightness: br,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme(
        brightness: br,
        primary: primary,    onPrimary: bg,
        secondary: second,   onSecondary: bg,
        surface: surface,    onSurface: primary,
        error: AppColors.danger, onError: Colors.white,
      ),
      textTheme: GoogleFonts.dmSansTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ).apply(bodyColor: primary, displayColor: primary),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: (isDark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark)
            .copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: border, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerColor: border,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}
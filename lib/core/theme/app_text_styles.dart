import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle displayHero(Color color) => GoogleFonts.inter(
        fontSize: 52, fontWeight: FontWeight.w900,
        color: color, letterSpacing: -2.5, height: 1.05);

  static TextStyle displayLarge(Color color) => GoogleFonts.inter(
        fontSize: 40, fontWeight: FontWeight.w800,
        color: color, letterSpacing: -1.8, height: 1.1);

  static TextStyle displayMedium(Color color) => GoogleFonts.inter(
        fontSize: 32, fontWeight: FontWeight.w700,
        color: color, letterSpacing: -1.2);

  static TextStyle headingLarge(Color color) => GoogleFonts.inter(
        fontSize: 22, fontWeight: FontWeight.w700,
        color: color, letterSpacing: -0.5);

  static TextStyle headingMedium(Color color) => GoogleFonts.inter(
        fontSize: 17, fontWeight: FontWeight.w600,
        color: color, letterSpacing: -0.3);

  static TextStyle headingSmall(Color color) => GoogleFonts.inter(
        fontSize: 15, fontWeight: FontWeight.w600,
        color: color, letterSpacing: -0.2);

  static TextStyle bodyLarge(Color color) => GoogleFonts.inter(
        fontSize: 15, fontWeight: FontWeight.w400,
        color: color, height: 1.5);

  static TextStyle bodyMedium(Color color) => GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400,
        color: color, height: 1.5);

  static TextStyle bodySmall(Color color) => GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w400,
        color: color, height: 1.4);

  static TextStyle labelBold(Color color) => GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w600,
        color: color, letterSpacing: 0.1);

  static TextStyle caption(Color color) => GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w500,
        color: color, letterSpacing: 0.6);

  static TextStyle scoreDisplay(Color color) => GoogleFonts.inter(
        fontSize: 44, fontWeight: FontWeight.w800,
        color: color, letterSpacing: -2.0);
}
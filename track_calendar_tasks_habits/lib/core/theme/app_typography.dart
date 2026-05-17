import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:track_calendar_tasks_habits/core/theme/app_colors.dart';

abstract final class AppTypography {
  static TextStyle _base({
    required double fontSize,
    required FontWeight fontWeight,
    double height = 1.5,
    double letterSpacing = 0,
    Color color = AppColors.onSurface,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
      );

  static TextStyle get headlineLg =>
      _base(fontSize: 32, fontWeight: FontWeight.w700, height: 1.2);

  static TextStyle get headlineMd =>
      _base(fontSize: 24, fontWeight: FontWeight.w600, height: 1.3);

  static TextStyle get headlineSm =>
      _base(fontSize: 20, fontWeight: FontWeight.w600, height: 1.4);

  static TextStyle get bodyLg =>
      _base(fontSize: 18, fontWeight: FontWeight.w400, height: 1.6);

  static TextStyle get bodyMd =>
      _base(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5);

  static TextStyle get bodySm =>
      _base(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);

  static TextStyle get labelLg => _base(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.28,
      );

  static TextStyle get labelSm => _base(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.2,
        letterSpacing: 0.6,
      );

  static TextTheme get textTheme => TextTheme(
        displayLarge: headlineLg,
        displayMedium: headlineMd,
        displaySmall: headlineSm,
        headlineLarge: headlineLg,
        headlineMedium: headlineMd,
        headlineSmall: headlineSm,
        titleLarge: headlineSm,
        titleMedium: bodyLg.copyWith(fontWeight: FontWeight.w600),
        titleSmall: bodyMd.copyWith(fontWeight: FontWeight.w600),
        bodyLarge: bodyLg,
        bodyMedium: bodyMd,
        bodySmall: bodySm,
        labelLarge: labelLg,
        labelMedium: labelSm.copyWith(fontSize: 13),
        labelSmall: labelSm,
      );
}

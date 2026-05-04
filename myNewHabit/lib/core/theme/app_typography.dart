// Sprint 1: Tasarım Sistemi — Tipografi tanımları
// Font: Plus Jakarta Sans (google_fonts paketi ile yüklenir)
// Kural: TextStyle(fontSize: 16) gibi hardcode yazılmaz; AppTypography kullanılır.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Plus Jakarta Sans font ailesine dayalı merkezi text style tanımları.
///
/// Tasarım kaynağı: Bubbly Habit Tracker typography specs.
abstract final class AppTypography {
  // ── Internal font shorthand ───────────────────────────────────────────────

  /// Temel font — Plus Jakarta Sans, renk olmadan.
  static TextStyle _base({
    required double fontSize,
    required FontWeight fontWeight,
    double height = 1.5,
    double letterSpacing = 0,
    Color color = AppColors.onSurface,
  }) => GoogleFonts.plusJakartaSans(
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: height,
    letterSpacing: letterSpacing,
    color: color,
  );

  // ── Headlines ─────────────────────────────────────────────────────────────

  /// 32px · Bold (700) · lineHeight 1.2 — Ekran başlıkları
  static TextStyle get headlineLg =>
      _base(fontSize: 32, fontWeight: FontWeight.w700, height: 1.2);

  /// 24px · SemiBold (600) · lineHeight 1.3 — Bölüm başlıkları
  static TextStyle get headlineMd =>
      _base(fontSize: 24, fontWeight: FontWeight.w600, height: 1.3);

  /// 20px · SemiBold (600) · lineHeight 1.4 — Kart başlıkları
  static TextStyle get headlineSm =>
      _base(fontSize: 20, fontWeight: FontWeight.w600, height: 1.4);

  // ── Body ─────────────────────────────────────────────────────────────────

  /// 18px · Regular (400) · lineHeight 1.6 — Büyük gövde metni
  static TextStyle get bodyLg =>
      _base(fontSize: 18, fontWeight: FontWeight.w400, height: 1.6);

  /// 16px · Regular (400) · lineHeight 1.5 — Standart gövde metni
  static TextStyle get bodyMd =>
      _base(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5);

  /// 14px · Regular (400) · lineHeight 1.5 — Küçük gövde metni
  static TextStyle get bodySm =>
      _base(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);

  // ── Labels ────────────────────────────────────────────────────────────────

  /// 14px · SemiBold (600) · letterSpacing 0.02em — Büyük etiket
  static TextStyle get labelLg => _base(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.28, // 0.02em × 14
  );

  /// 12px · Medium (500) · letterSpacing 0.05em — Küçük etiket / badge
  static TextStyle get labelSm => _base(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.6, // 0.05em × 12
  );

  // ── TextTheme factory ─────────────────────────────────────────────────────

  /// Material 3 TextTheme — ThemeData.textTheme içinde kullanılır.
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

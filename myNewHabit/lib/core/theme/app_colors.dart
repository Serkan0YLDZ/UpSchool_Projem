// Sprint 1: Tasarım Sistemi — Renk sabitleri
// Kaynak: stitchTasarimi/kaynakKodlari/renk_paleti/DESIGN.md
// Kural: Hiçbir yerde Color(0xFF...) yazılmaz; her zaman AppColors kullanılır.

import 'package:flutter/material.dart';

/// Uygulamanın tüm renk değerlerini merkezi olarak tanımlar.
///
/// Tasarım sistemi kaynağı: Bubbly Habit Tracker renk paleti.
/// Primary #0077B6 · Secondary #90E0EF · Tertiary #00B4D8 · Neutral #F8FBFF
abstract final class AppColors {
  // ── Brand primaries ──────────────────────────────────────────────────────
  static const Color primary = Color(0xFF005D90);
  static const Color primaryContainer = Color(0xFF0077B6);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFF3F7FF);
  static const Color inversePrimary = Color(0xFF94CCFF);

  // ── Secondary ────────────────────────────────────────────────────────────
  static const Color secondary = Color(0xFF006875);
  static const Color secondaryContainer = Color(0xFF9CECFB);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // ── Tertiary ─────────────────────────────────────────────────────────────
  static const Color tertiary = Color(0xFF006176);
  static const Color tertiaryContainer = Color(0xFF007C95);
  static const Color onTertiary = Color(0xFFFFFFFF);

  // ── Surface & Background ─────────────────────────────────────────────────
  static const Color surface = Color(0xFFF7FAFE);
  static const Color surfaceDim = Color(0xFFD7DADE);
  static const Color surfaceBright = Color(0xFFF7FAFE);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF1F4F8);
  static const Color surfaceContainer = Color(0xFFEBEEF2);
  static const Color surfaceContainerHigh = Color(0xFFE5E8EC);
  static const Color surfaceContainerHighest = Color(0xFFE0E3E7);

  // ── On-surface ───────────────────────────────────────────────────────────
  static const Color onSurface = Color(0xFF181C1F);
  static const Color onSurfaceVariant = Color(0xFF404850);
  static const Color inverseSurface = Color(0xFF2D3134);
  static const Color inverseOnSurface = Color(0xFFEEF1F5);

  // ── Outline ───────────────────────────────────────────────────────────────
  static const Color outline = Color(0xFF707881);
  static const Color outlineVariant = Color(0xFFBFC7D1);

  // ── Error ────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);

  // ── Functional aliases (kullanım kolaylığı için) ──────────────────────────
  /// Alışkanlık tamamlanma rengi — birincil mavi
  static const Color habitDone = primaryContainer;

  /// Kötü alışkanlık / relapse uyarı rengi
  static const Color relapseDanger = error;

  /// Skip (es geç) soluk rengi
  static const Color skippedMuted = surfaceContainerHigh;

  /// Streak ateşi rengi
  static const Color streakFire = Color(0xFFFF6B35);

  /// Ambient shadow (rgba(0, 119, 182, 0.08))
  static const Color ambientShadow = Color(0x140077B6);
}

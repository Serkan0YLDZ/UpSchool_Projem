import 'package:flutter/material.dart';

/// Uygulama paleti — [AppTheme] ve [TrackCustomColors] ile senkron tutulur.
abstract final class AppColors {
  static const Color primary = Color(0xFF0B5C4F);
  static const Color primaryContainer = Color(0xFF0F7A68);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFE6F5F2);
  static const Color inversePrimary = Color(0xFF7FD4C4);

  static const Color secondary = Color(0xFF3D4A45);
  static const Color secondaryContainer = Color(0xFFC9E8E0);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF1D2622);

  static const Color tertiary = Color(0xFF5B3FA8);
  static const Color tertiaryContainer = Color(0xFFDDD6F5);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFF2A1F45);

  static const Color surface = Color(0xFFF6F7F4);
  static const Color surfaceDim = Color(0xFFDDE0DC);
  static const Color surfaceBright = Color(0xFFFAFBF9);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFECEEEA);
  static const Color surfaceContainer = Color(0xFFE2E5E1);
  static const Color surfaceContainerHigh = Color(0xFFD8DCD7);
  static const Color surfaceContainerHighest = Color(0xFFCED3CD);

  static const Color onSurface = Color(0xFF141816);
  static const Color onSurfaceVariant = Color(0xFF3F4540);
  static const Color inverseSurface = Color(0xFF1A1F1C);
  static const Color inverseOnSurface = Color(0xFFEEF1ED);

  static const Color outline = Color(0xFF5B6460);
  static const Color outlineVariant = Color(0xFFB8C0BA);

  static const Color error = Color(0xFFB3261E);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFF9DEDC);

  static const Color habitDone = primaryContainer;
  static const Color relapseDanger = error;
  static const Color skippedMuted = surfaceContainerHigh;
  static const Color streakFire = Color(0xFFC2410C);
  static const Color streakRecovery = Color(0xFFCA6A08);
  static const Color streakMuted = Color(0xFF8A9390);
  static const Color ambientShadow = Color(0x140F7A68);

  /// Brutalist çizgiler — plan: "brutalistInk" (#121816); API uyumu için isim korunur.
  static const Color brutalistBlack = Color(0xFF121816);
  static const Color brutalistWhite = Color(0xFFFFFFFF);
  static const Color tertiaryFixed = Color(0xFFDDD6F5);
  static const Color neoBadgeDefaultYellow = Color(0xFFF5D565);
  static const Color cardHeaderYellow = Color(0xFFE8D48A);
  static const Color sectionBannerYellow = Color(0xFFC9A227);
  static const Color sectionBannerPurple = Color(0xFF6B4F9C);

  /// Takvim / alışkanlık / yapılacaklar bölüm şeritleri (neo brutalist).
  static const Color homeSectionCalendarBlue = Color(0xFF2563EB);
  static const Color homeSectionHabitsCoral = Color(0xFFEF4444);
  static const Color homeSectionTodosOrange = Color(0xFFF97316);
  static const Color todoPriorityHigh = Color(0xFFE53935);
  static const Color todoPriorityMedium = Color(0xFFF9D65C);
  static const Color todoPriorityLow = Color(0xFF7EB6D9);
  static const Color googleBrandBlue = Color(0xFF4285F4);
  static const Color habitCardSoftBlue = Color(0xFFB8E0D8);

  /// Neobrutalist kart (takvim günleri, merkez FAB) — yüz / gölge / metin.
  static const Color neoStackFace = Color(0xFF434D5E);
  static const Color neoStackShadow = Color(0xFF12161F);
  static const Color neoStackOnFace = Color(0xFFFFFFFF);
  /// Takvim şeridi ve alt nav arka planı.
  static const Color neoChromePlate = Color(0xFFF8F9FB);
}

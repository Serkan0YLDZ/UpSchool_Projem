// Sprint 1: Tasarım Sistemi — Merkezi ThemeData tanımı
// Kural: Renkler AppColors'tan, tipografi AppTypography'den, spacing AppSpacing'den gelir.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Uygulamanın tek ThemeData kaynağı.
///
/// Material 3 etkin; dark mode altyapısı hazır ama MVP'de sadece light kullanılır.
abstract final class AppTheme {
  /// Light theme — MVP'de kullanılan ana tema
  static ThemeData get light => _buildTheme(Brightness.light);

  // ─────────────────────────────────────────────────────────────────────────

  static ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = _colorScheme(brightness);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: AppTypography.textTheme,
      scaffoldBackgroundColor: AppColors.surface,

      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.ambientShadow,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: AppTypography.headlineSm.copyWith(
          color: AppColors.onSurface,
        ),
      ),

      // ── NavigationBar (Material 3) ────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        indicatorColor: AppColors.primaryContainer.withAlpha(30),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelSm.copyWith(
              color: AppColors.primaryContainer,
              fontWeight: FontWeight.w700,
            );
          }
          return AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primaryContainer);
          }
          return const IconThemeData(color: AppColors.onSurfaceVariant);
        }),
        elevation: 3,
        shadowColor: AppColors.ambientShadow,
      ),

      // ── ElevatedButton ────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          elevation: 0,
          textStyle: AppTypography.labelLg,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.cardPadding,
            vertical: AppSpacing.smMd,
          ),
        ),
      ),

      // ── OutlinedButton ────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryContainer,
          minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          side: const BorderSide(color: AppColors.primaryContainer, width: 1.5),
          textStyle: AppTypography.labelLg,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.cardPadding,
            vertical: AppSpacing.smMd,
          ),
        ),
      ),

      // ── TextButton ────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryContainer,
          textStyle: AppTypography.labelLg,
        ),
      ),

      // ── Card ──────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        shadowColor: AppColors.ambientShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Chip ──────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerLow,
        selectedColor: AppColors.primaryContainer.withAlpha(26),
        labelStyle: AppTypography.labelSm,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.smMd,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        side: BorderSide.none,
      ),

      // ── InputDecoration ───────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        hintStyle: AppTypography.bodyMd.copyWith(color: AppColors.outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: const BorderSide(color: AppColors.primaryContainer, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.smMd,
        ),
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariant,
        thickness: 1,
        space: 0,
      ),

      // ── SnackBar ──────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.inverseSurface,
        contentTextStyle: AppTypography.bodyMd.copyWith(
          color: AppColors.inverseOnSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── BottomSheet ───────────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
        elevation: 4,
        shadowColor: AppColors.ambientShadow,
        showDragHandle: true,
        dragHandleColor: AppColors.outlineVariant,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────

  static ColorScheme _colorScheme(Brightness brightness) {
    if (brightness == Brightness.light) {
      return const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSurface,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onSurface,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onSurface,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        shadow: AppColors.ambientShadow,
        inverseSurface: AppColors.inverseSurface,
        onInverseSurface: AppColors.inverseOnSurface,
        inversePrimary: AppColors.inversePrimary,
      );
    }
    // Dark mode scaffold — MVP'de kullanılmaz ama altyapı hazır
    return ColorScheme.dark(
      primary: AppColors.inversePrimary,
      surface: AppColors.inverseSurface,
    );
  }
}

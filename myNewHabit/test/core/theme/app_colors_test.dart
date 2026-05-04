// Sprint 1: AppColors & AppTheme birim/widget testleri
// Kabul kriteri: Primary renk #0077B6 doğru; Material 3 aktif.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_new_habit/core/theme/app_colors.dart';
import 'package:my_new_habit/core/theme/app_theme.dart';

void main() {
  setUpAll(() {
    // Test ortamında Google Fonts HTTP isteği devre dışı —
    // font bulunamazsa sistem fallback kullanır, hata fırlatmaz.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  // ── Pure unit tests (no widget binding needed) ─────────────────────────

  group('AppColors', () {
    test('primaryContainer should equal #0077B6 per Agile Plan spec', () {
      // Arrange
      const expected = Color(0xFF0077B6);

      // Act
      const actual = AppColors.primaryContainer;

      // Assert
      expect(actual, equals(expected));
    });

    test('surface should equal #F7FAFE per design system spec', () {
      // Arrange
      const expected = Color(0xFFF7FAFE);

      // Act
      const actual = AppColors.surface;

      // Assert
      expect(actual, equals(expected));
    });

    test('error should equal #BA1A1A per design system spec', () {
      // Arrange
      const expected = Color(0xFFBA1A1A);

      // Act
      const actual = AppColors.error;

      // Assert
      expect(actual, equals(expected));
    });

    test('ambientShadow alpha should be 0x14 (8% opacity) per design spec', () {
      // Arrange — rgba(0,119,182,0.08) ≈ alpha 20 = 0x14
      const expected = Color(0x140077B6);

      // Act
      const actual = AppColors.ambientShadow;

      // Assert
      expect(actual.a, closeTo(expected.a, 0.01));
    });
  });

  // ── Widget tests (require binding for GoogleFonts) ─────────────────────

  group('AppTheme', () {
    testWidgets('light theme should use Material 3', (tester) async {
      // Arrange & Act — pumpWidget initializes binding
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const SizedBox()),
      );
      final theme = Theme.of(tester.element(find.byType(SizedBox)));

      // Assert
      expect(theme.useMaterial3, isTrue);
    });

    testWidgets(
      'light theme scaffold background should match AppColors.surface',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(theme: AppTheme.light, home: const SizedBox()),
        );
        final theme = Theme.of(tester.element(find.byType(SizedBox)));

        // Assert
        expect(theme.scaffoldBackgroundColor, equals(AppColors.surface));
      },
    );

    testWidgets(
      'light theme colorScheme primary should equal AppColors.primary',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(theme: AppTheme.light, home: const SizedBox()),
        );
        final theme = Theme.of(tester.element(find.byType(SizedBox)));

        // Assert
        expect(theme.colorScheme.primary, equals(AppColors.primary));
      },
    );

    testWidgets(
      'light theme colorScheme primaryContainer should equal #0077B6',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(theme: AppTheme.light, home: const SizedBox()),
        );
        final theme = Theme.of(tester.element(find.byType(SizedBox)));

        // Assert
        expect(
          theme.colorScheme.primaryContainer,
          equals(AppColors.primaryContainer),
        );
      },
    );
  });
}

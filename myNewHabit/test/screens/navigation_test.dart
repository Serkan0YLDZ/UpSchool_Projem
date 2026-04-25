// Sprint 1: Widget testleri — NavigationBar ve 3-tab yapısı
// Kabul kriteri: 3 tab görünür ve tıklanabilir; Plus Jakarta Sans yüklü.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_new_habit/core/router/app_router.dart';
import 'package:my_new_habit/core/theme/app_theme.dart';
import 'package:my_new_habit/core/widgets/empty_state_widget.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Navigation — Sprint 1 kabul kriterleri', () {
    testWidgets(
      'should show 3 navigation destinations',
      (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: appRouter,
          ),
        );
        await tester.pumpAndSettle();

        // Assert — 3 NavigationIcon görünmeli (text label yok)
        expect(find.byIcon(Icons.home_rounded), findsOneWidget);
        expect(find.byIcon(Icons.add_rounded), findsOneWidget);
        expect(find.byIcon(Icons.person_rounded), findsOneWidget);
      },
    );

    testWidgets(
      'should navigate to Profile tab when Profil tapped',
      (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: appRouter,
          ),
        );
        await tester.pumpAndSettle();

        // Act — Profil tab'ı ortadaki (add) değil, sağdaki (person) ikon.
        // Ama "Profil" yazılı bir AppBar olduğu için (ProfileScreen placeholder'ında)
        // navigasyonun çalıştığını "Profil" yazısından anlayabiliriz.
        await tester.tap(find.byIcon(Icons.person_rounded));
        await tester.pumpAndSettle();

        // Assert — Profil ekranı başlığı görünmeli
        expect(find.text('Profil'), findsAtLeastNWidgets(1));
      },
    );

    testWidgets(
      'should show home screen by default on launch',
      (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: appRouter,
          ),
        );
        await tester.pumpAndSettle();

        // Assert — Home ekranında boş durum widget'ı bulunmalı
        expect(find.byType(EmptyStateWidget), findsOneWidget);
      },
    );

    testWidgets(
      'should show snackbar placeholder when Ekle tapped in Sprint 1',
      (tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: appRouter,
          ),
        );
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.byIcon(Icons.add_rounded));
        await tester.pump();

        // Assert — Sprint 2 placeholder snackbar görünmeli
        expect(find.byType(SnackBar), findsOneWidget);
      },
    );
  });

  group('AppTheme — typography', () {
    testWidgets(
      'should apply theme without overflow on 375px width (iPhone SE)',
      (tester) async {
        // Arrange — 375px genişlik simülasyonu
        tester.view.physicalSize = const Size(375 * 3, 667 * 3);
        tester.view.devicePixelRatio = 3.0;

        await tester.pumpWidget(
          MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: appRouter,
          ),
        );
        await tester.pumpAndSettle();

        // Assert — overflow hatası olmamalı
        expect(tester.takeException(), isNull);

        // Cleanup
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
      },
    );
  });
}

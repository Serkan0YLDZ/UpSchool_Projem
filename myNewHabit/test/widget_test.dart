// Sprint 1: Smoke test — uygulamanın hatasız başladığını doğrular.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_new_habit/core/router/app_router.dart';
import 'package:my_new_habit/core/theme/app_theme.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets(
    'app should launch without errors (smoke test)',
    (WidgetTester tester) async {
      // Arrange & Act — router + theme ile direkt başlat
      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: appRouter,
        ),
      );
      await tester.pumpAndSettle();

      // Assert — herhangi bir exception olmamalı
      expect(tester.takeException(), isNull);

      // Özel Navigation bar ikonları görünmeli
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    },
  );
}

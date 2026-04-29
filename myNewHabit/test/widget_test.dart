// Sprint 1: Smoke test — uygulamanın hatasız başladığını doğrular.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:my_new_habit/core/router/app_router.dart';
import 'package:my_new_habit/core/theme/app_theme.dart';
import 'package:my_new_habit/providers/completion_provider.dart';
import 'package:my_new_habit/providers/record_provider.dart';
import 'package:my_new_habit/screens/home/home_screen.dart';
import 'package:my_new_habit/screens/profile/profile_screen.dart';
import 'package:my_new_habit/screens/shell/main_shell.dart';

import 'data/repositories/completion_repository_stub.dart';
import 'data/repositories/record_repository_stub.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await initializeDateFormatting('tr_TR', null);
  });

  testWidgets(
    'app should launch without errors (smoke test)',
    (WidgetTester tester) async {
      // Arrange & Act — router + theme ile direkt başlat
      final router = GoRouter(
        initialLocation: AppRoutes.home,
        routes: [
          ShellRoute(
            builder: (context, state, child) => MainShell(child: child),
            routes: [
              GoRoute(
                path: AppRoutes.home,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomeScreen(),
                ),
              ),
              GoRoute(
                path: AppRoutes.profile,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ProfileScreen(),
                ),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<RecordProvider>(
              create: (_) => RecordProvider(StubRecordRepository()),
            ),
            ChangeNotifierProvider<CompletionProvider>(
              create: (_) => CompletionProvider(StubCompletionRepository()),
            ),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
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

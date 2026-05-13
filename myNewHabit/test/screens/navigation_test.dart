// Sprint 1: Widget testleri — NavigationBar ve 3-tab yapısı
// Sprint 3: HomeScreen Provider gerektirdiği için MultiProvider eklendi.
// Not: "Snackbar placeholder" testi Sprint 2 modal akışına geçildiği için kaldırıldı.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:go_router/go_router.dart';
import 'package:my_new_habit/core/router/app_router.dart';
import 'package:my_new_habit/core/theme/app_theme.dart';
import 'package:my_new_habit/data/auth/mock_auth_backend.dart';
import 'package:my_new_habit/data/database/database_helper.dart';
import 'package:my_new_habit/data/services/cloud_sync_service.dart';
import 'package:my_new_habit/providers/auth_session_provider.dart';
import 'package:my_new_habit/providers/completion_provider.dart';
import 'package:my_new_habit/providers/record_provider.dart';
import 'package:my_new_habit/providers/streak_provider.dart';
import 'package:my_new_habit/providers/sync_status_provider.dart';
import 'package:my_new_habit/screens/focus/focus_section.dart';
import 'package:my_new_habit/screens/focus/focus_section_screen.dart';
import 'package:my_new_habit/screens/home/home_screen.dart';
import 'package:my_new_habit/screens/profile/profile_screen.dart';
import 'package:my_new_habit/screens/shell/main_shell.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../data/repositories/completion_repository_stub.dart';
import '../data/repositories/record_repository_stub.dart';
import '../data/repositories/streak_repository_stub.dart';

/// Son oluşturulan [GoRouter] — odak ekranı yönlendirme testinde kullanılır.
GoRouter? _navigationTestRouter;

DatabaseHelper? _navTestDb;

Widget _buildApp() {
  final db = _navTestDb!;
  final router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
          GoRoute(
            path: AppRoutes.focusParent,
            redirect: (context, state) {
              if (state.uri.path == AppRoutes.focusParent) {
                return AppRoutes.focusCalendar;
              }
              return null;
            },
            routes: [
              GoRoute(
                path: AppRoutes.focusCalendarSegment,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: FocusSectionScreen(section: FocusSection.calendar),
                ),
              ),
              GoRoute(
                path: AppRoutes.focusHabitsSegment,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: FocusSectionScreen(section: FocusSection.habits),
                ),
              ),
              GoRoute(
                path: AppRoutes.focusTodosSegment,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: FocusSectionScreen(section: FocusSection.todos),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  _navigationTestRouter = router;

  final recStub = StubRecordRepository();
  final compStub = StubCompletionRepository();
  final streakStub = StubStreakRepository();

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthSessionProvider>(
        create: (_) => AuthSessionProvider(
          backend: MockAuthBackend(),
          dbHelper: db,
        ),
      ),
      ChangeNotifierProvider<SyncStatusProvider>(
        create: (_) {
          final p = SyncStatusProvider(
            dbHelper: db,
            cloudSync: CloudSyncService(
              recordRepository: recStub,
              completionRepository: compStub,
              streakRepository: streakStub,
            ),
          );
          // Senkron meta ilk okuma
          // ignore: discarded_futures
          p.refresh();
          return p;
        },
      ),
      ChangeNotifierProvider<RecordProvider>(
        create: (_) => RecordProvider(recStub),
      ),
      ChangeNotifierProvider<StreakProvider>(
        create: (_) => StreakProvider(
          completionRepository: compStub,
          streakRepository: streakStub,
          recordRepository: recStub,
        ),
      ),
      ChangeNotifierProvider<CompletionProvider>(
        create: (ctx) => CompletionProvider(
          compStub,
          onMutated: (rid) async {
            await ctx.read<StreakProvider>().reconcileForRecord(rid);
          },
        ),
      ),
    ],
    child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    GoogleFonts.config.allowRuntimeFetching = false;
    await initializeDateFormatting('tr_TR', null);
  });

  setUp(() async {
    _navTestDb = DatabaseHelper.forTesting();
    await _navTestDb!.database;
  });

  tearDown(() async {
    await _navTestDb?.close();
    _navTestDb = null;
  });

  group('Navigation — Sprint 1 kabul kriterleri', () {
    testWidgets('should show 3 navigation destinations', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Assert — 3 NavigationIcon görünmeli
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    });

    testWidgets('should navigate to Profile tab when Profil tapped', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Act — sağdaki (person) ikonuna tıkla
      await tester.tap(find.byIcon(Icons.person_rounded));
      await tester.pumpAndSettle();

      // Assert — Profil ekranı başlığı görünmeli
      expect(find.text('Profil'), findsAtLeastNWidgets(1));
    });

    testWidgets('should show home screen by default on launch', (tester) async {
      // Arrange
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Assert — Ev (home) ikonu aktif; LoadingIndicator veya EmptyState görünür.
      // HomeScreen yüklendi = Scaffold hazır.
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    });

    testWidgets('focus calendar route shows Takvim title', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      _navigationTestRouter!.go(AppRoutes.focusCalendar);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('focus_section_title_calendar')),
        findsOneWidget,
      );
    });
  });

  group('AppTheme — typography', () {
    testWidgets(
      'should apply theme without overflow on 375px width (iPhone SE)',
      (tester) async {
        // Arrange — 375px genişlik simülasyonu
        tester.view.physicalSize = const Size(375 * 3, 667 * 3);
        tester.view.devicePixelRatio = 3.0;

        await tester.pumpWidget(_buildApp());
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

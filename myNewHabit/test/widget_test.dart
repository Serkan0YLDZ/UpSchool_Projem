// Sprint 1: Smoke test — uygulamanın hatasız başladığını doğrular.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
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
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'data/repositories/completion_repository_stub.dart';
import 'data/repositories/record_repository_stub.dart';
import 'data/repositories/streak_repository_stub.dart';

DatabaseHelper? _widgetTestDb;

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    GoogleFonts.config.allowRuntimeFetching = false;
    await initializeDateFormatting('tr_TR', null);
  });

  setUp(() async {
    _widgetTestDb = DatabaseHelper.forTesting();
    await _widgetTestDb!.database;
  });

  tearDown(() async {
    await _widgetTestDb?.close();
    _widgetTestDb = null;
  });

  testWidgets('app should launch without errors (smoke test)', (
    WidgetTester tester,
  ) async {
    final db = _widgetTestDb!;
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

    final recStub = StubRecordRepository();
    final compStub = StubCompletionRepository();
    final streakStub = StubStreakRepository();

    await tester.pumpWidget(
      MultiProvider(
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
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
  });
}

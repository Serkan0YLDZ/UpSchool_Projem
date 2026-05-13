import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:my_new_habit/core/theme/app_theme.dart';
import 'package:my_new_habit/data/auth/mock_auth_backend.dart';
import 'package:my_new_habit/data/database/database_helper.dart';
import 'package:my_new_habit/data/services/cloud_sync_service.dart';
import 'package:my_new_habit/providers/auth_session_provider.dart';
import 'package:my_new_habit/providers/sync_status_provider.dart';
import 'package:my_new_habit/screens/profile/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../data/repositories/completion_repository_stub.dart';
import '../data/repositories/record_repository_stub.dart';
import '../data/repositories/streak_repository_stub.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    GoogleFonts.config.allowRuntimeFetching = false;
    await initializeDateFormatting('tr_TR', null);
  });

  testWidgets('guest profile shows sign-in options', (tester) async {
    final db = DatabaseHelper.forTesting();
    addTearDown(() async => db.close());

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
            create: (_) => SyncStatusProvider(
              dbHelper: db,
              cloudSync: CloudSyncService(
                recordRepository: recStub,
                completionRepository: compStub,
                streakRepository: streakStub,
              ),
            ),
          ),
        ],
        child: TickerMode(
          enabled: false,
          child: MaterialApp(
            theme: AppTheme.light.copyWith(
              splashFactory: NoSplash.splashFactory,
            ),
            home: const ProfileScreen(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Google ile devam et'), findsOneWidget);
    expect(find.text('Apple ile devam et'), findsOneWidget);
    expect(find.text('E-posta ile devam et'), findsOneWidget);
    expect(find.text('Giriş yapınca neler olur?'), findsOneWidget);
  });

  testWidgets('email demo sign-in then sign out flow', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.binding.setSurfaceSize(const Size(800, 1400));

    final db = DatabaseHelper.forTesting();
    addTearDown(() async => db.close());

    final recStub = StubRecordRepository();
    final compStub = StubCompletionRepository();
    final streakStub = StubStreakRepository();

    final auth = AuthSessionProvider(
      backend: MockAuthBackend(),
      dbHelper: db,
    );
    addTearDown(auth.dispose);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthSessionProvider>.value(value: auth),
          ChangeNotifierProvider<SyncStatusProvider>(
            create: (_) => SyncStatusProvider(
              dbHelper: db,
              cloudSync: CloudSyncService(
                recordRepository: recStub,
                completionRepository: compStub,
                streakRepository: streakStub,
              ),
            ),
          ),
        ],
        child: TickerMode(
          enabled: false,
          child: MaterialApp(
            theme: AppTheme.light.copyWith(
              splashFactory: NoSplash.splashFactory,
            ),
            home: const ProfileScreen(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    final emailRow = find.text('E-posta ile devam et');
    await tester.ensureVisible(emailRow);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(emailRow);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('E-posta ile giriş'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).first,
      'test@example.com',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'secret123',
    );
    final submit = find.byKey(const ValueKey('email_sheet_submit'));
    await tester.ensureVisible(submit);
    await tester.pump();
    await tester.tap(submit);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Çıkış yap'), findsWidgets);
    expect(find.text('test@example.com'), findsOneWidget);

    final scaffoldEl = tester.element(
      find.descendant(
        of: find.byType(ProfileScreen),
        matching: find.byType(Scaffold),
      ),
    );
    ScaffoldMessenger.maybeOf(scaffoldEl)?.clearSnackBars();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final signOutBtn = find.widgetWithText(OutlinedButton, 'Çıkış yap');
    await tester.ensureVisible(signOutBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(signOutBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Vazgeç'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(TextButton, 'Çıkış yap'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Google ile devam et'), findsOneWidget);
  });
}

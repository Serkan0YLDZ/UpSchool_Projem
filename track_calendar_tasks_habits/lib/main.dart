import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/auth/mock_auth_backend.dart';
import 'data/repositories/completion_repository.dart';
import 'data/repositories/record_repository.dart';
import 'data/repositories/streak_repository.dart';
import 'providers/auth_session_provider.dart';
import 'providers/completion_provider.dart';
import 'providers/record_provider.dart';
import 'providers/streak_provider.dart';
import 'providers/sync_status_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Mock repository'ler — backend bağlantısı gerektirmez.
  final recordRepo = MockRecordRepository();
  final completionRepo = MockCompletionRepository();
  final streakRepo = MockStreakRepository();

  runApp(TrackHabitsApp(
    recordRepo: recordRepo,
    completionRepo: completionRepo,
    streakRepo: streakRepo,
  ));
}

class TrackHabitsApp extends StatelessWidget {
  const TrackHabitsApp({
    super.key,
    required this.recordRepo,
    required this.completionRepo,
    required this.streakRepo,
  });

  final RecordRepository recordRepo;
  final CompletionRepository completionRepo;
  final StreakRepository streakRepo;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthSessionProvider(backend: MockAuthBackend()),
        ),
        ChangeNotifierProvider(
          create: (_) => SyncStatusProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => RecordProvider(recordRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => StreakProvider(
            completionRepository: completionRepo,
            streakRepository: streakRepo,
            recordRepository: recordRepo,
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => CompletionProvider(
            completionRepo,
            onMutated: (recordId) async {
              await ctx.read<StreakProvider>().reconcileForRecord(recordId);
            },
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Track Habits',
        theme: AppTheme.light,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

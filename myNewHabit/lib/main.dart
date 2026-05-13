// Sprint 2: Uygulama giriş noktası — MultiProvider entegrasyonu
// DIP: Repository abstraction'ları constructor'dan enjekte edilir.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/agent_arch_debug_log.dart';
import 'core/utils/debug_session_log.dart';
import 'data/auth/firebase_auth_backend.dart';
import 'data/database/database_helper.dart';
import 'data/repositories/completion_repository.dart';
import 'data/repositories/record_repository.dart';
import 'data/repositories/streak_repository.dart';
import 'data/services/cloud_sync_service.dart';
import 'firebase_options.dart';
import 'providers/auth_session_provider.dart';
import 'providers/completion_provider.dart';
import 'providers/record_provider.dart';
import 'providers/streak_provider.dart';
import 'providers/sync_status_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // #region agent log
  debugSessionLogCwd(hypothesisId: 'H_build_root');
  // #endregion
  // #region agent log
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    final opts = DefaultFirebaseOptions.currentPlatform;
    debugSessionLog(
      hypothesisId: 'H1',
      location: 'main.dart:main',
      message: 'firebase_init_ok',
      data: {
        'projectId': opts.projectId,
        'appIdSuffix': opts.appId.length > 12 ? opts.appId.substring(opts.appId.length - 12) : opts.appId,
      },
    );
  } catch (e) {
    debugSessionLog(
      hypothesisId: 'H1',
      location: 'main.dart:main',
      message: 'firebase_init_fail',
      data: {
        'type': e.runtimeType.toString(),
        'error': e.toString(),
      },
    );
    rethrow;
  }
  // #endregion
  await initializeDateFormatting('tr_TR', null);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // DB'yi runApp'tan ÖNCE WidgetsFlutterBinding garantisi altında aç.
  // Bu sayede sqflite iOS plugin'i tam olarak kayıtlanmış olur.
  final dbHelper = DatabaseHelper.instance;
  await dbHelper.database; // Eager initialization
  // #region agent log
  agentArchDebugLog(
    hypothesisId: 'H4',
    location: 'main.dart:main',
    message: 'db_eager_init_done',
    data: {'dbHash': dbHelper.hashCode},
  );
  // #endregion

  final recordRepository = SqfliteRecordRepository(dbHelper);
  final completionRepository = SqfliteCompletionRepository(dbHelper);
  final streakRepository = SqfliteStreakRepository(dbHelper);
  final cloudSync = CloudSyncService(
    recordRepository: recordRepository,
    completionRepository: completionRepository,
    streakRepository: streakRepository,
  );

  runApp(
    MyNewHabitApp(
      dbHelper: dbHelper,
      cloudSync: cloudSync,
      recordRepository: recordRepository,
      completionRepository: completionRepository,
      streakRepository: streakRepository,
    ),
  );
}

/// Uygulamanın kök widget'ı.
class MyNewHabitApp extends StatelessWidget {
  const MyNewHabitApp({
    super.key,
    required this.dbHelper,
    required this.cloudSync,
    required this.recordRepository,
    required this.completionRepository,
    required this.streakRepository,
  });

  final DatabaseHelper dbHelper;
  final CloudSyncService cloudSync;
  final RecordRepository recordRepository;
  final CompletionRepository completionRepository;
  final StreakRepository streakRepository;

  static int _archBuildCount = 0;

  @override
  Widget build(BuildContext context) {
    // #region agent log
    _archBuildCount++;
    agentArchDebugLog(
      hypothesisId: 'H3',
      location: 'main.dart:MyNewHabitApp.build',
      message: 'root_build',
      data: {
        'buildCount': _archBuildCount,
        'recordRepoHash': recordRepository.hashCode,
        'completionRepoHash': completionRepository.hashCode,
        'streakRepoHash': streakRepository.hashCode,
      },
    );
    // #endregion

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            // #region agent log
            agentArchDebugLog(
              hypothesisId: 'H1',
              location: 'main.dart:AuthSessionProvider.create',
              message: 'provider_created',
              data: {'name': 'AuthSessionProvider'},
            );
            // #endregion
            return AuthSessionProvider(
              backend: FirebaseAuthBackend(),
              dbHelper: dbHelper,
            );
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final p = SyncStatusProvider(
              dbHelper: dbHelper,
              cloudSync: cloudSync,
            );
            unawaited(p.refresh());
            return p;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            // #region agent log
            agentArchDebugLog(
              hypothesisId: 'H1',
              location: 'main.dart:RecordProvider.create',
              message: 'provider_created',
              data: {
                'name': 'RecordProvider',
                'repoHash': recordRepository.hashCode,
              },
            );
            // #endregion
            return RecordProvider(recordRepository);
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            // #region agent log
            agentArchDebugLog(
              hypothesisId: 'H1',
              location: 'main.dart:StreakProvider.create',
              message: 'provider_created',
              data: {
                'name': 'StreakProvider',
                'completionRepoHash': completionRepository.hashCode,
              },
            );
            // #endregion
            return StreakProvider(
              completionRepository: completionRepository,
              streakRepository: streakRepository,
              recordRepository: recordRepository,
            );
          },
        ),
        ChangeNotifierProvider(
          create: (ctx) {
            // #region agent log
            agentArchDebugLog(
              hypothesisId: 'H1',
              location: 'main.dart:CompletionProvider.create',
              message: 'before_streak_read',
              data: {},
            );
            final streakRef = ctx.read<StreakProvider>();
            agentArchDebugLog(
              hypothesisId: 'H1',
              location: 'main.dart:CompletionProvider.create',
              message: 'streak_read_ok',
              data: {'streakProviderHash': streakRef.hashCode},
            );
            // #endregion
            return CompletionProvider(
              completionRepository,
              onMutated: (recordId) async {
                // #region agent log
                agentArchDebugLog(
                  hypothesisId: 'H1',
                  location: 'main.dart:onMutated',
                  message: 'onMutated_entry',
                  data: {'recordId': recordId},
                );
                // #endregion
                try {
                  await ctx.read<StreakProvider>().reconcileForRecord(recordId);
                  // #region agent log
                  agentArchDebugLog(
                    hypothesisId: 'H1',
                    location: 'main.dart:onMutated',
                    message: 'onMutated_reconcile_done',
                    data: {'recordId': recordId},
                  );
                  // #endregion
                } catch (e, st) {
                  // #region agent log
                  agentArchDebugLog(
                    hypothesisId: 'H1',
                    location: 'main.dart:onMutated',
                    message: 'onMutated_error',
                    data: {
                      'recordId': recordId,
                      'error': e.toString(),
                      'stack': st.toString(),
                    },
                  );
                  // #endregion
                  rethrow;
                }
              },
            );
          },
        ),
      ],
      child: MaterialApp.router(
        title: 'myNewHabit',
        theme: AppTheme.light,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

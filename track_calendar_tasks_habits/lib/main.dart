import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:track_calendar_tasks_habits/core/router/app_router.dart';
import 'package:track_calendar_tasks_habits/core/theme/app_theme.dart';
import 'package:track_calendar_tasks_habits/data/auth/mock_auth_backend.dart';
import 'package:track_calendar_tasks_habits/data/db/database_helper.dart';

import 'package:track_calendar_tasks_habits/data/repositories/calendar_event_repository.dart';
import 'package:track_calendar_tasks_habits/data/repositories/habit_repository.dart';
import 'package:track_calendar_tasks_habits/data/repositories/todo_repository.dart';
import 'package:track_calendar_tasks_habits/data/repositories/habit_day_log_repository.dart';
import 'package:track_calendar_tasks_habits/data/repositories/streak_snapshot_repository.dart';

import 'package:track_calendar_tasks_habits/presentation/providers/auth_session_provider.dart';
import 'package:track_calendar_tasks_habits/presentation/providers/sync_status_provider.dart';
import 'package:track_calendar_tasks_habits/presentation/providers/calendar_event_provider.dart';
import 'package:track_calendar_tasks_habits/presentation/providers/habit_provider.dart';
import 'package:track_calendar_tasks_habits/presentation/providers/todo_provider.dart';
import 'package:track_calendar_tasks_habits/presentation/providers/habit_day_log_provider.dart';
import 'package:track_calendar_tasks_habits/presentation/providers/streak_provider.dart';
import 'package:track_calendar_tasks_habits/presentation/providers/home_state_provider.dart';

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

  // SQLite Database Initialization
  final db = await DatabaseHelper.instance.database;

  // Initialize SQLite Repositories
  final calendarRepo = CalendarEventSqliteRepository(db);
  final habitRepo = HabitSqliteRepository(db);
  final todoRepo = TodoSqliteRepository(db);
  final habitDayLogRepo = HabitDayLogSqliteRepository(db);
  final streakSnapshotRepo = StreakSnapshotSqliteRepository(db);

  runApp(TrackHabitsApp(
    calendarRepo: calendarRepo,
    habitRepo: habitRepo,
    todoRepo: todoRepo,
    habitDayLogRepo: habitDayLogRepo,
    streakSnapshotRepo: streakSnapshotRepo,
  ));
}

class TrackHabitsApp extends StatelessWidget {
  const TrackHabitsApp({
    super.key,
    required this.calendarRepo,
    required this.habitRepo,
    required this.todoRepo,
    required this.habitDayLogRepo,
    required this.streakSnapshotRepo,
  });

  final CalendarEventRepository calendarRepo;
  final HabitRepository habitRepo;
  final TodoRepository todoRepo;
  final HabitDayLogRepository habitDayLogRepo;
  final StreakSnapshotRepository streakSnapshotRepo;

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
          create: (_) => CalendarEventProvider(repository: calendarRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => HabitProvider(repository: habitRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => TodoProvider(repository: todoRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => HabitDayLogProvider(repository: habitDayLogRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeStateProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => StreakProvider(
            snapshotRepo: streakSnapshotRepo,
            logRepo: habitDayLogRepo,
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

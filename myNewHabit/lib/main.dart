// Sprint 2: Uygulama giriş noktası — MultiProvider entegrasyonu
// DIP: Repository abstraction'ları constructor'dan enjekte edilir.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/database/database_helper.dart';
import 'data/repositories/completion_repository.dart';
import 'data/repositories/record_repository.dart';
import 'providers/completion_provider.dart';
import 'providers/record_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  runApp(MyNewHabitApp(dbHelper: dbHelper));
}

/// Uygulamanın kök widget'ı.
class MyNewHabitApp extends StatelessWidget {
  const MyNewHabitApp({super.key, required this.dbHelper});

  final DatabaseHelper dbHelper;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RecordProvider(SqfliteRecordRepository(dbHelper)),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              CompletionProvider(SqfliteCompletionRepository(dbHelper)),
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

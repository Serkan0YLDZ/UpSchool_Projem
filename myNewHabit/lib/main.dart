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

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) => runApp(const MyNewHabitApp()));
}

/// Uygulamanın kök widget'ı.
///
/// Sprint 2: MultiProvider ile RecordProvider ve CompletionProvider
/// en üst seviyede enjekte edilmiştir.
class MyNewHabitApp extends StatelessWidget {
  const MyNewHabitApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dbHelper = DatabaseHelper.instance;
    final recordRepo = SqfliteRecordRepository(dbHelper);
    final completionRepo = SqfliteCompletionRepository(dbHelper);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RecordProvider(recordRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => CompletionProvider(completionRepo),
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

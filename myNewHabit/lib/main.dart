// Sprint 1: Uygulama giriş noktası
// Kural: Provider'lar en üste MultiProvider ile enjekte edilir.
// Sprint 2'de RecordProvider ve CompletionProvider buraya eklenecek.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Status bar rengi tasarımla uyumlu olsun
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Desteklenen yönler: sadece dikey
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) => runApp(const MyNewHabitApp()));
}

/// Uygulamanın kök widget'ı.
///
/// Sprint 1: Sadece theme + router kurulumu.
/// Sprint 2: MultiProvider içine RecordProvider, CompletionProvider eklenecek.
class MyNewHabitApp extends StatelessWidget {
  const MyNewHabitApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Sprint 2'de MultiProvider buraya eklenecek:
    // return MultiProvider(
    //   providers: [
    //     ChangeNotifierProvider(create: (_) => RecordProvider(SqfliteRecordRepository())),
    //     ChangeNotifierProvider(create: (_) => CompletionProvider(SqfliteCompletionRepository())),
    //   ],
    //   child: MaterialApp.router(...),
    // );
    return MaterialApp.router(
      title: 'myNewHabit',
      theme: AppTheme.light,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}

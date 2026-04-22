import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:upschool_projem_app/features/documents/presentation/document_detail_screen.dart';
import 'package:upschool_projem_app/features/documents/presentation/document_list_screen.dart';
import 'package:upschool_projem_app/features/documents/presentation/state/document_state.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const DocumentListScreen(),
      ),
      GoRoute(
        path: '/detail',
        builder: (context, state) {
          final extra = state.extra;
          final doc = extra is DocumentListItem ? extra : null;
          if (doc == null) {
            return const Scaffold(
              body: Center(child: Text('Eksik belge bilgisi')),
            );
          }
          return DocumentDetailScreen(doc: doc);
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'UpSchool Projem',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5B5BE6)),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

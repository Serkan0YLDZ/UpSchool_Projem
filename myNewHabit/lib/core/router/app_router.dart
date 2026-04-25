// Sprint 1: Navigasyon — go_router kurulumu
// Kural: go_router kullanılır; Navigator.push kesinlikle yazılmaz.

import 'package:go_router/go_router.dart';

import 'package:my_new_habit/screens/home/home_screen.dart';
import 'package:my_new_habit/screens/profile/profile_screen.dart';
import 'package:my_new_habit/screens/shell/main_shell.dart';

/// Uygulamanın tüm rota tanımları.
///
/// Shell route ile 3-tab navigation bar kalıcı kalır.
final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: false,
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.profile,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ProfileScreen(),
          ),
        ),
      ],
    ),
  ],
);

/// Merkezi rota sabitleri — string literal kullanımını önler.
abstract final class AppRoutes {
  static const String home = '/';
  static const String profile = '/profile';
}

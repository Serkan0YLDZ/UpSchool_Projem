// Sprint 1: Navigasyon — go_router kurulumu
// Kural: go_router kullanılır; Navigator.push kesinlikle yazılmaz.

import 'package:go_router/go_router.dart';

import 'package:my_new_habit/screens/focus/focus_section.dart';
import 'package:my_new_habit/screens/focus/focus_section_screen.dart';
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
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HomeScreen()),
        ),
        GoRoute(
          path: AppRoutes.profile,
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ProfileScreen()),
        ),
        // Shell altında tek parça mutlak path'ler (/focus/calendar) bazı sürümlerde
        // eşleşmeyebiliyor; üst /focus + göreli alt path ile aynı URL korunur.
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

/// Merkezi rota sabitleri — string literal kullanımını önler.
abstract final class AppRoutes {
  static const String home = '/';
  static const String profile = '/profile';

  /// Üst rota (alt segmentler: calendar, habits, todos).
  static const String focusParent = '/focus';

  static const String focusCalendarSegment = 'calendar';
  static const String focusHabitsSegment = 'habits';
  static const String focusTodosSegment = 'todos';

  /// Tam ekran odak: yalnızca saatli takvim etkinlikleri.
  static const String focusCalendar = '/focus/calendar';

  /// Tam ekran odak: yalnızca alışkanlık kartları.
  static const String focusHabits = '/focus/habits';

  /// Tam ekran odak: yalnızca yapılacaklar.
  static const String focusTodos = '/focus/todos';
}

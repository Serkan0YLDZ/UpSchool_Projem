import 'package:go_router/go_router.dart';

import '../../screens/focus/focus_section.dart';
import '../../screens/focus/focus_section_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/shell/main_shell.dart';

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

abstract final class AppRoutes {
  static const String home = '/';
  static const String profile = '/profile';
  static const String focusParent = '/focus';
  static const String focusCalendarSegment = 'calendar';
  static const String focusHabitsSegment = 'habits';
  static const String focusTodosSegment = 'todos';
  static const String focusCalendar = '/focus/calendar';
  static const String focusHabits = '/focus/habits';
  static const String focusTodos = '/focus/todos';
}

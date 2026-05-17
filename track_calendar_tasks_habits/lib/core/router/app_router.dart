import 'package:go_router/go_router.dart';

import 'package:track_calendar_tasks_habits/presentation/screens/focus/focus_section.dart';
import 'package:track_calendar_tasks_habits/presentation/screens/focus/focus_section_screen.dart';
import 'package:track_calendar_tasks_habits/presentation/screens/home/home_screen.dart';
import 'package:track_calendar_tasks_habits/presentation/screens/profile/profile_screen.dart';
import 'package:track_calendar_tasks_habits/presentation/screens/shell/main_shell.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:track_calendar_tasks_habits/presentation/screens/onboarding/onboarding_screen.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: false,
  redirect: (context, state) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('onboarding_completed') ?? false;
    
    final isGoingToOnboarding = state.uri.path == AppRoutes.onboarding;
    
    if (!completed && !isGoingToOnboarding) {
      return AppRoutes.onboarding;
    }
    
    if (completed && isGoingToOnboarding) {
      return AppRoutes.home;
    }
    
    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
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
  static const String onboarding = '/onboarding';
  static const String profile = '/profile';
  static const String focusParent = '/focus';
  static const String focusCalendarSegment = 'calendar';
  static const String focusHabitsSegment = 'habits';
  static const String focusTodosSegment = 'todos';
  static const String focusCalendar = '/focus/calendar';
  static const String focusHabits = '/focus/habits';
  static const String focusTodos = '/focus/todos';
}

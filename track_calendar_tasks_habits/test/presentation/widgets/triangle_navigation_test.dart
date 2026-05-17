import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:track_calendar_tasks_habits/presentation/screens/shell/main_shell.dart';
import 'package:track_calendar_tasks_habits/core/theme/app_theme.dart';
import 'package:track_calendar_tasks_habits/presentation/providers/todo_provider.dart';
import 'package:track_calendar_tasks_habits/presentation/providers/habit_provider.dart';
import 'package:track_calendar_tasks_habits/presentation/providers/calendar_event_provider.dart';
import 'package:track_calendar_tasks_habits/core/router/app_router.dart';
import 'package:track_calendar_tasks_habits/data/repositories/todo_repository.dart';
import 'package:track_calendar_tasks_habits/data/repositories/habit_repository.dart';
import 'package:track_calendar_tasks_habits/data/repositories/calendar_event_repository.dart';

import 'package:track_calendar_tasks_habits/data/models/todo_model.dart';
import 'package:track_calendar_tasks_habits/data/models/habit_model.dart';
import 'package:track_calendar_tasks_habits/data/models/calendar_event_model.dart';

// Fakes
class FakeTodoRepo implements TodoRepository {
  @override Future<List<TodoModel>> getActive() async => [];
  @override Future<TodoModel?> getById(String id) async => null;
  @override Future<void> insert(TodoModel item) async {}
  @override Future<void> update(TodoModel item) async {}
  @override Future<void> softDelete(String id) async {}
  @override Future<void> markCompleted(String id, bool isCompleted) async {}
}

class FakeHabitRepo implements HabitRepository {
  @override Future<List<HabitModel>> getActive() async => [];
  @override Future<HabitModel?> getById(String id) async => null;
  @override Future<void> insert(HabitModel item) async {}
  @override Future<void> update(HabitModel item) async {}
  @override Future<void> softDelete(String id) async {}
}

class FakeEventRepo implements CalendarEventRepository {
  @override Future<List<CalendarEventModel>> getActive() async => [];
  @override Future<CalendarEventModel?> getById(String id) async => null;
  @override Future<void> insert(CalendarEventModel item) async {}
  @override Future<void> update(CalendarEventModel item) async {}
  @override Future<void> softDelete(String id) async {}
  @override Future<List<CalendarEventModel>> getByDate(String isoDate) async => [];
}

void main() {
  testWidgets('TriangleCornerNav render edilir ve Semantics etiketi bulunur', (WidgetTester tester) async {
    // Arrange
    final router = GoRouter(
      initialLocation: AppRoutes.home,
      routes: [
        ShellRoute(
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const Text('Home'),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TodoProvider(repository: FakeTodoRepo())),
          ChangeNotifierProvider(create: (_) => HabitProvider(repository: FakeHabitRepo())),
          ChangeNotifierProvider(create: (_) => CalendarEventProvider(repository: FakeEventRepo())),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.light,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Assert
    // Ana ikonlar: takvim, alışkanlık, yapılacaklar ikonlarını arayalım
    expect(find.byIcon(Icons.calendar_today_rounded), findsWidgets);
    expect(find.byIcon(Icons.repeat_rounded), findsWidgets);
    expect(find.byIcon(Icons.checklist_rounded), findsWidgets);

    // Semantics testi
    expect(find.bySemanticsLabel(RegExp(r'Mod seçici.*|.*görünümü.*')), findsWidgets);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:track_calendar_tasks_habits/presentation/screens/home/widgets/todo_filter_button.dart';
import 'package:track_calendar_tasks_habits/presentation/providers/todo_provider.dart';
import 'package:track_calendar_tasks_habits/core/theme/app_theme.dart';
import 'package:track_calendar_tasks_habits/data/repositories/todo_repository.dart';
import 'package:track_calendar_tasks_habits/data/models/todo_model.dart';

// Fake repo
class FakeTodoRepository implements TodoRepository {
  @override
  Future<List<TodoModel>> getActive() async => [];
  @override
  Future<TodoModel?> getById(String id) async => null;
  @override
  Future<void> insert(TodoModel item) async {}
  @override
  Future<void> update(TodoModel item) async {}
  @override
  Future<void> softDelete(String id) async {}
  @override
  Future<void> markCompleted(String id, bool isCompleted) async {}
}

void main() {
  testWidgets('TodoFilterButton modal açar ve Yapılacakları Filtrele yazar', (WidgetTester tester) async {
    // Arrange
    final provider = TodoProvider(repository: FakeTodoRepository());
    
    await tester.pumpWidget(
      ChangeNotifierProvider<TodoProvider>.value(
        value: provider,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: TodoFilterButton(),
          ),
        ),
      ),
    );

    // Act - find button and tap
    final button = find.byType(TodoFilterButton);
    expect(button, findsOneWidget);
    await tester.tap(button);
    await tester.pumpAndSettle(); // Wait for bottom sheet to animate in

    // Assert - bottom sheet contents
    expect(find.text('Yapılacakları Filtrele'), findsOneWidget);
    
    // Tap on an option
    final doneOption = find.text('Yapılanlar');
    expect(doneOption, findsOneWidget);
    
    await tester.tap(doneOption);
    await tester.pumpAndSettle();
    
    // Verify provider state changed
    expect(provider.activeFilters.contains(TodoFilterType.todoDone), isTrue);
  });
}

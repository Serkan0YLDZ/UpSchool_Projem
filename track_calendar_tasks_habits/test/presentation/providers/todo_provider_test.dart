import 'package:flutter_test/flutter_test.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:track_calendar_tasks_habits/data/db/table_constants.dart';
import 'package:track_calendar_tasks_habits/data/models/todo_model.dart';
import 'package:track_calendar_tasks_habits/data/repositories/todo_repository.dart';
import 'package:track_calendar_tasks_habits/presentation/providers/todo_provider.dart';

Future<Database> _openTestDb() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  return openDatabase(
    inMemoryDatabasePath,
    version: 1,
    onCreate: (db, _) async {
      await db.execute(TableConstants.createTodos);
    },
  );
}

void main() {
  late Database db;
  late TodoSqliteRepository repo;
  late TodoProvider provider;

  setUp(() async {
    db = await _openTestDb();
    repo = TodoSqliteRepository(db);
    provider = TodoProvider(repository: repo);
  });

  tearDown(() async {
    await db.close();
  });

  test('loadTodos aktif todoları yükler', () async {
    final todo = TodoModel(
      id: 't1',
      title: 'Alışveriş',
      priority: TodoPriority.low,
      createdAt: '2025-05-15',
      updatedAt: '2025-05-15',
    );
    await repo.insert(todo);

    expect(provider.todos, isEmpty);
    await provider.loadTodos();
    expect(provider.todos.length, 1);
    expect(provider.todos.first.id, 't1');
  });

  test('markCompleted repositoryyi günceller ve statei yeniler', () async {
    final todo = TodoModel(
      id: 't2',
      title: 'Temizlik',
      priority: TodoPriority.medium,
      createdAt: '2025-05-15',
      updatedAt: '2025-05-15',
    );
    await provider.addTodo(todo);

    expect(provider.todos.first.isCompleted, false);

    await provider.markCompleted('t2', true);

    expect(provider.todos.first.isCompleted, true);
    expect(provider.todos.first.completedAt, isNotNull);
  });
}

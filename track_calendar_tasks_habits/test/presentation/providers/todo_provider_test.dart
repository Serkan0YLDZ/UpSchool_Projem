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

  group('TodoFilter logic', () {
    test('toggleFilter ekler ve siler', () {
      expect(provider.activeFilters, isEmpty);
      
      provider.toggleFilter(TodoFilterType.todoDone);
      expect(provider.activeFilters.contains(TodoFilterType.todoDone), true);

      // tekrar tıklandığında kalkar
      provider.toggleFilter(TodoFilterType.todoDone);
      expect(provider.activeFilters, isEmpty);
    });

    test('Aynı gruptaki filtreler (radio) birbirini ezer', () {
      provider.toggleFilter(TodoFilterType.todoDone);
      expect(provider.activeFilters.contains(TodoFilterType.todoDone), true);

      // todoTodo seçilince todoDone iptal olmalı
      provider.toggleFilter(TodoFilterType.todoTodo);
      expect(provider.activeFilters.contains(TodoFilterType.todoTodo), true);
      expect(provider.activeFilters.contains(TodoFilterType.todoDone), false);
    });

    test('Filtreleme işlemi todos listesini doğru filtreler', () async {
      final t1 = TodoModel(id: 't1', title: 'A', priority: TodoPriority.low, createdAt: '2025-05-15', updatedAt: '2025-05-15');
      final t2 = TodoModel(id: 't2', title: 'B', priority: TodoPriority.high, createdAt: '2025-05-15', updatedAt: '2025-05-15');
      
      await provider.addTodo(t1);
      await provider.addTodo(t2);
      await provider.markCompleted('t1', true); // t1 completed, t2 not

      // Filtre yoksa 2 tane olmalı
      expect(provider.todos.length, 2);

      // Sadece bitenleri filtrele
      provider.toggleFilter(TodoFilterType.todoDone);
      expect(provider.todos.length, 1);
      expect(provider.todos.first.id, 't1');

      // Sadece yapılmamış olanları filtrele
      provider.toggleFilter(TodoFilterType.todoTodo);
      expect(provider.todos.length, 1);
      expect(provider.todos.first.id, 't2');
    });

    test('Önem derecesine göre sıralama', () async {
      final t1 = TodoModel(id: 't1', title: 'A', priority: TodoPriority.low, createdAt: '2025-05-15', updatedAt: '2025-05-15');
      final t2 = TodoModel(id: 't2', title: 'B', priority: TodoPriority.high, createdAt: '2025-05-15', updatedAt: '2025-05-15');
      final t3 = TodoModel(id: 't3', title: 'C', priority: TodoPriority.medium, createdAt: '2025-05-15', updatedAt: '2025-05-15');
      
      await provider.addTodo(t1);
      await provider.addTodo(t2);
      await provider.addTodo(t3);

      provider.toggleFilter(TodoFilterType.mostImportant);
      final sorted = provider.todos;
      
      // Enum sırası: high(0), medium(1), low(2) (veya tersi)
      // TodoPriority: high, medium, low ise
      expect(sorted[0].priority, TodoPriority.high);
      expect(sorted[1].priority, TodoPriority.medium);
      expect(sorted[2].priority, TodoPriority.low);
    });
  });
}

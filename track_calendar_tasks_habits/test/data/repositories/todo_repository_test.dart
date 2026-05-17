import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:track_calendar_tasks_habits/data/db/table_constants.dart';
import 'package:track_calendar_tasks_habits/data/models/todo_model.dart';
import 'package:track_calendar_tasks_habits/data/repositories/todo_repository.dart';


Future<Database> _openTestDb() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  return openDatabase(
    inMemoryDatabasePath,
    version: 1,
    onCreate: (db, _) => db.execute(TableConstants.createTodos),
  );
}

TodoModel _sampleTodo({
  String id = 't-1',
  String title = 'Test Görev',
  TodoPriority priority = TodoPriority.medium,
}) {
  final now = DateTime.now().toIso8601String();
  return TodoModel(
    id: id,
    title: title,
    priority: priority,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late Database db;
  late TodoSqliteRepository repo;

  setUp(() async {
    db = await _openTestDb();
    repo = TodoSqliteRepository(db);
  });

  tearDown(() => db.close());

  test('insert → getActive() listede görünür', () async {
    await repo.insert(_sampleTodo());
    final list = await repo.getActive();
    expect(list.length, 1);
    expect(list.first.title, 'Test Görev');
  });

  test('softDelete → getActive() listede görünmez', () async {
    await repo.insert(_sampleTodo());
    await repo.softDelete('t-1');
    final list = await repo.getActive();
    expect(list, isEmpty);
  });

  test('markCompleted → is_completed=1 ve completed_at dolu', () async {
    await repo.insert(_sampleTodo());
    await repo.markCompleted('t-1', true);
    final found = await repo.getById('t-1');
    expect(found!.isCompleted, isTrue);
    expect(found.completedAt, isNotNull);
  });

  test('priority doğru saklanır', () async {
    await repo.insert(_sampleTodo(priority: TodoPriority.high));
    final found = await repo.getById('t-1');
    expect(found!.priority, TodoPriority.high);
  });

  test('description alanı null olabilir', () async {
    await repo.insert(_sampleTodo());
    final found = await repo.getById('t-1');
    expect(found!.description, isNull);
  });
}

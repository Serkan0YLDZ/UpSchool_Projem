import 'package:sqflite/sqflite.dart';

import 'package:track_calendar_tasks_habits/data/db/table_constants.dart';
import 'package:track_calendar_tasks_habits/data/models/todo_model.dart';

/// Yapılacak görevler için CRUD sözleşmesi.
abstract class TodoRepository {
  Future<List<TodoModel>> getActive();
  Future<TodoModel?> getById(String id);
  Future<void> insert(TodoModel todo);
  Future<void> update(TodoModel todo);
  Future<void> softDelete(String id);
  Future<void> markCompleted(String id, bool isCompleted);
}

/// SQLite tabanlı implementasyon.
class TodoSqliteRepository implements TodoRepository {
  TodoSqliteRepository(this._db);

  final Database _db;

  @override
  Future<List<TodoModel>> getActive() async {
    final rows = await _db.query(
      TableConstants.todos,
      where: 'deleted_at IS NULL',
      orderBy: 'created_at ASC',
    );
    return rows.map(TodoModel.fromMap).toList();
  }

  @override
  Future<TodoModel?> getById(String id) async {
    final rows = await _db.query(
      TableConstants.todos,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return TodoModel.fromMap(rows.first);
  }

  @override
  Future<void> insert(TodoModel todo) async {
    await _db.insert(
      TableConstants.todos,
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> update(TodoModel todo) async {
    await _db.update(
      TableConstants.todos,
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  @override
  Future<void> softDelete(String id) async {
    final now = DateTime.now().toIso8601String();
    await _db.update(
      TableConstants.todos,
      {'deleted_at': now, 'updated_at': now},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> markCompleted(String id, bool isCompleted) async {
    final now = DateTime.now().toIso8601String();
    if (isCompleted) {
      await _db.update(
        TableConstants.todos,
        {
          'is_completed': 1,
          'completed_at': now,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } else {
      await _db.update(
        TableConstants.todos,
        {
          'is_completed': 0,
          'completed_at': null,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }
}

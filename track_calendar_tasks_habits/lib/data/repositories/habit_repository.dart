import 'package:sqflite/sqflite.dart';

import 'package:track_calendar_tasks_habits/data/db/table_constants.dart';
import 'package:track_calendar_tasks_habits/data/models/habit_model.dart';

/// Alışkanlıklar için CRUD sözleşmesi.
abstract class HabitRepository {
  Future<List<HabitModel>> getActive();
  Future<HabitModel?> getById(String id);
  Future<void> insert(HabitModel habit);
  Future<void> update(HabitModel habit);
  Future<void> softDelete(String id);
}

/// SQLite tabanlı implementasyon.
class HabitSqliteRepository implements HabitRepository {
  HabitSqliteRepository(this._db);

  final Database _db;

  @override
  Future<List<HabitModel>> getActive() async {
    final rows = await _db.query(
      TableConstants.habits,
      where: 'deleted_at IS NULL',
      orderBy: 'created_at ASC',
    );
    return rows.map(HabitModel.fromMap).toList();
  }

  @override
  Future<HabitModel?> getById(String id) async {
    final rows = await _db.query(
      TableConstants.habits,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return HabitModel.fromMap(rows.first);
  }

  @override
  Future<void> insert(HabitModel habit) async {
    await _db.insert(
      TableConstants.habits,
      habit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> update(HabitModel habit) async {
    await _db.update(
      TableConstants.habits,
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  @override
  Future<void> softDelete(String id) async {
    final now = DateTime.now().toIso8601String();
    await _db.update(
      TableConstants.habits,
      {'deleted_at': now, 'updated_at': now},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

import 'package:sqflite/sqflite.dart';

import 'package:track_calendar_tasks_habits/data/db/table_constants.dart';
import 'package:track_calendar_tasks_habits/data/models/habit_day_log_model.dart';

/// Alışkanlık günlük logları için CRUD sözleşmesi.
abstract class HabitDayLogRepository {
  Future<List<HabitDayLogModel>> getByHabitId(String habitId);
  Future<HabitDayLogModel?> getByHabitAndDate(String habitId, String isoDate);
  Future<List<HabitDayLogModel>> getByDate(String isoDate);
  Future<void> upsert(HabitDayLogModel log);
  Future<void> softDelete(String id);
}

/// SQLite tabanlı implementasyon.
///
/// [upsert] INSERT OR REPLACE kullanır — (habit_id, calendar_date) UNIQUE kısıtı
/// sayesinde aynı gün için her zaman tek satır kalır.
class HabitDayLogSqliteRepository implements HabitDayLogRepository {
  HabitDayLogSqliteRepository(this._db);

  final Database _db;

  @override
  Future<List<HabitDayLogModel>> getByHabitId(String habitId) async {
    final rows = await _db.query(
      TableConstants.habitDayLogs,
      where: 'habit_id = ? AND deleted_at IS NULL',
      whereArgs: [habitId],
      orderBy: 'calendar_date ASC',
    );
    return rows.map(HabitDayLogModel.fromMap).toList();
  }

  @override
  Future<HabitDayLogModel?> getByHabitAndDate(
    String habitId,
    String isoDate,
  ) async {
    final rows = await _db.query(
      TableConstants.habitDayLogs,
      where: 'habit_id = ? AND calendar_date = ? AND deleted_at IS NULL',
      whereArgs: [habitId, isoDate],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return HabitDayLogModel.fromMap(rows.first);
  }

  @override
  Future<List<HabitDayLogModel>> getByDate(String isoDate) async {
    final rows = await _db.query(
      TableConstants.habitDayLogs,
      where: 'calendar_date = ? AND deleted_at IS NULL',
      whereArgs: [isoDate],
    );
    return rows.map(HabitDayLogModel.fromMap).toList();
  }

  @override
  Future<void> upsert(HabitDayLogModel log) async {
    await _db.insert(
      TableConstants.habitDayLogs,
      log.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> softDelete(String id) async {
    final now = DateTime.now().toIso8601String();
    await _db.update(
      TableConstants.habitDayLogs,
      {'deleted_at': now, 'updated_at': now},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

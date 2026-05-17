import 'package:sqflite/sqflite.dart';

import 'package:track_calendar_tasks_habits/data/db/table_constants.dart';
import 'package:track_calendar_tasks_habits/data/models/streak_snapshot_model.dart';

/// Seri anlık görüntüleri için CRUD sözleşmesi.
abstract class StreakSnapshotRepository {
  Future<StreakSnapshotModel?> getByHabitId(String habitId);
  Future<Map<String, StreakSnapshotModel>> getByHabitIds(List<String> habitIds);
  Future<void> upsert(StreakSnapshotModel snapshot);
}

/// SQLite tabanlı implementasyon.
///
/// habit_id PRIMARY KEY olduğu için upsert = INSERT OR REPLACE.
class StreakSnapshotSqliteRepository implements StreakSnapshotRepository {
  StreakSnapshotSqliteRepository(this._db);

  final Database _db;

  @override
  Future<StreakSnapshotModel?> getByHabitId(String habitId) async {
    final rows = await _db.query(
      TableConstants.streakSnapshots,
      where: 'habit_id = ?',
      whereArgs: [habitId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return StreakSnapshotModel.fromMap(rows.first);
  }

  @override
  Future<Map<String, StreakSnapshotModel>> getByHabitIds(
    List<String> habitIds,
  ) async {
    if (habitIds.isEmpty) return {};
    final placeholders = habitIds.map((_) => '?').join(', ');
    final rows = await _db.rawQuery(
      'SELECT * FROM ${TableConstants.streakSnapshots} WHERE habit_id IN ($placeholders)',
      habitIds,
    );
    return {
      for (final row in rows)
        row['habit_id'] as String: StreakSnapshotModel.fromMap(row),
    };
  }

  @override
  Future<void> upsert(StreakSnapshotModel snapshot) async {
    await _db.insert(
      TableConstants.streakSnapshots,
      snapshot.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

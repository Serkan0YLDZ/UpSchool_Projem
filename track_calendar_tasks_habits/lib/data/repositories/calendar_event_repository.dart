import 'package:sqflite/sqflite.dart';

import 'package:track_calendar_tasks_habits/data/db/table_constants.dart';
import 'package:track_calendar_tasks_habits/data/models/calendar_event_model.dart';

/// Takvim etkinlikleri için CRUD sözleşmesi (DIP: provider bu interface'e bağlanır).
abstract class CalendarEventRepository {
  Future<List<CalendarEventModel>> getActive();
  Future<List<CalendarEventModel>> getByDate(String isoDate);
  Future<CalendarEventModel?> getById(String id);
  Future<void> insert(CalendarEventModel event);
  Future<void> update(CalendarEventModel event);
  Future<void> softDelete(String id);
}

/// SQLite tabanlı implementasyon.
class CalendarEventSqliteRepository implements CalendarEventRepository {
  CalendarEventSqliteRepository(this._db);

  final Database _db;

  @override
  Future<List<CalendarEventModel>> getActive() async {
    final rows = await _db.query(
      TableConstants.calendarEvents,
      where: 'deleted_at IS NULL',
      orderBy: 'starts_at ASC',
    );
    return rows.map(CalendarEventModel.fromMap).toList();
  }

  @override
  Future<List<CalendarEventModel>> getByDate(String isoDate) async {
    // Etkinlik başladıysa (starts_at <= date) VE bitmemişse (ends_at >= date VEYA ends_at IS NULL)
    // ya da sadece starts_at o güne denk geliyor.
    final rows = await _db.query(
      TableConstants.calendarEvents,
      where: """
        deleted_at IS NULL AND
        substr(starts_at, 1, 10) <= ? AND
        (ends_at IS NULL OR substr(ends_at, 1, 10) >= ?)
      """,
      whereArgs: [isoDate, isoDate],
      orderBy: 'starts_at ASC',
    );
    return rows.map(CalendarEventModel.fromMap).toList();
  }

  @override
  Future<CalendarEventModel?> getById(String id) async {
    final rows = await _db.query(
      TableConstants.calendarEvents,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return CalendarEventModel.fromMap(rows.first);
  }

  @override
  Future<void> insert(CalendarEventModel event) async {
    await _db.insert(
      TableConstants.calendarEvents,
      event.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> update(CalendarEventModel event) async {
    await _db.update(
      TableConstants.calendarEvents,
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  @override
  Future<void> softDelete(String id) async {
    final now = DateTime.now().toIso8601String();
    await _db.update(
      TableConstants.calendarEvents,
      {'deleted_at': now, 'updated_at': now},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

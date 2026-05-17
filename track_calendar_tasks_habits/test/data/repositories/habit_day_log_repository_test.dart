import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:track_calendar_tasks_habits/data/db/table_constants.dart';
import 'package:track_calendar_tasks_habits/data/models/habit_day_log_model.dart';
import 'package:track_calendar_tasks_habits/data/repositories/habit_day_log_repository.dart';


Future<Database> _openTestDb() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  return openDatabase(
    inMemoryDatabasePath,
    version: 1,
    onCreate: (db, _) async {
      // habit_day_logs REFERENCES habits(id) — habits tablosu da gerekli
      await db.execute(TableConstants.createHabits);
      await db.execute(TableConstants.createHabitDayLogs);
    },
  );
}

HabitDayLogModel _sampleLog({
  String id = 'log-1',
  String habitId = 'h-1',
  String date = '2025-05-16',
  DayLogStatus status = DayLogStatus.pending,
  String? skipSource,
}) {
  final now = DateTime.now().toIso8601String();
  return HabitDayLogModel(
    id: id,
    habitId: habitId,
    calendarDate: date,
    status: status,
    skipSource: skipSource,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late Database db;
  late HabitDayLogSqliteRepository repo;

  setUp(() async {
    db = await _openTestDb();
    repo = HabitDayLogSqliteRepository(db);
  });

  tearDown(() => db.close());

  test('upsert (insert) → getByHabitAndDate döner, status pending', () async {
    await repo.upsert(_sampleLog());
    final found = await repo.getByHabitAndDate('h-1', '2025-05-16');
    expect(found, isNotNull);
    expect(found!.status, DayLogStatus.pending);
  });

  test('upsert (update) → status met olarak güncellenir', () async {
    await repo.upsert(_sampleLog());
    final now = DateTime.now().toIso8601String();
    await repo.upsert(_sampleLog(status: DayLogStatus.met).copyWith(updatedAt: now));
    final found = await repo.getByHabitAndDate('h-1', '2025-05-16');
    expect(found!.status, DayLogStatus.met);
  });

  test('upsert skipped → skipSource saklanır', () async {
    await repo.upsert(_sampleLog(
      status: DayLogStatus.skipped,
      skipSource: 'free_weekly',
    ));
    final found = await repo.getByHabitAndDate('h-1', '2025-05-16');
    expect(found!.skipSource, 'free_weekly');
  });

  test('softDelete → getByHabitAndDate null döner', () async {
    await repo.upsert(_sampleLog());
    await repo.softDelete('log-1');
    final found = await repo.getByHabitAndDate('h-1', '2025-05-16');
    expect(found, isNull);
  });

  test('getByHabitId → tüm aktif loglar döner', () async {
    await repo.upsert(_sampleLog(id: 'log-1', date: '2025-05-16'));
    await repo.upsert(_sampleLog(id: 'log-2', date: '2025-05-18'));
    final list = await repo.getByHabitId('h-1');
    expect(list.length, 2);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:track_calendar_tasks_habits/data/db/table_constants.dart';
import 'package:track_calendar_tasks_habits/data/models/streak_snapshot_model.dart';
import 'package:track_calendar_tasks_habits/data/repositories/streak_snapshot_repository.dart';


Future<Database> _openTestDb() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  return openDatabase(
    inMemoryDatabasePath,
    version: 1,
    onCreate: (db, _) async {
      await db.execute(TableConstants.createHabits);
      await db.execute(TableConstants.createStreakSnapshots);
    },
  );
}

StreakSnapshotModel _sampleSnapshot({
  String habitId = 'h-1',
  int currentStreak = 0,
  int longestStreak = 0,
  SeriesState seriesState = SeriesState.active,
}) {
  return StreakSnapshotModel(
    habitId: habitId,
    currentStreak: currentStreak,
    longestStreak: longestStreak,
    seriesState: seriesState,
    updatedAt: DateTime.now().toIso8601String(),
  );
}

void main() {
  late Database db;
  late StreakSnapshotSqliteRepository repo;

  setUp(() async {
    db = await _openTestDb();
    repo = StreakSnapshotSqliteRepository(db);
  });

  tearDown(() => db.close());

  test('upsert (insert) → getByHabitId döner', () async {
    await repo.upsert(_sampleSnapshot(currentStreak: 3));
    final found = await repo.getByHabitId('h-1');
    expect(found, isNotNull);
    expect(found!.currentStreak, 3);
  });

  test('upsert (update) → currentStreak güncellenir', () async {
    await repo.upsert(_sampleSnapshot(currentStreak: 3));
    await repo.upsert(_sampleSnapshot(currentStreak: 7));
    final found = await repo.getByHabitId('h-1');
    expect(found!.currentStreak, 7);
  });

  test('getByHabitId → olmayan id için null döner', () async {
    final found = await repo.getByHabitId('yok');
    expect(found, isNull);
  });

  test('getByHabitIds → birden fazla snapshot döner', () async {
    await repo.upsert(_sampleSnapshot(habitId: 'h-1', currentStreak: 5));
    await repo.upsert(_sampleSnapshot(habitId: 'h-2', currentStreak: 10));
    final map = await repo.getByHabitIds(['h-1', 'h-2', 'h-yok']);
    expect(map.length, 2);
    expect(map['h-1']!.currentStreak, 5);
    expect(map['h-2']!.currentStreak, 10);
  });

  test('seriesState doğru saklanır', () async {
    await repo.upsert(_sampleSnapshot(seriesState: SeriesState.closed));
    final found = await repo.getByHabitId('h-1');
    expect(found!.seriesState, SeriesState.closed);
  });
}

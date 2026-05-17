import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:track_calendar_tasks_habits/data/db/table_constants.dart';
import 'package:track_calendar_tasks_habits/data/models/habit_model.dart';
import 'package:track_calendar_tasks_habits/data/repositories/habit_repository.dart';


Future<Database> _openTestDb() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  return openDatabase(
    inMemoryDatabasePath,
    version: 1,
    onCreate: (db, _) => db.execute(TableConstants.createHabits),
  );
}

HabitModel _sampleHabit({String id = 'h-1', String title = 'Koşu'}) {
  final now = DateTime.now().toIso8601String();
  return HabitModel(
    id: id,
    title: title,
    scheduleKind: ScheduleKind.weekly,
    weeklyDaysMask: 127, // 0b1111111 — her gün
    anchorDate: '2025-05-01',
    createdAt: now,
    updatedAt: now,
  );
}


void main() {
  late Database db;
  late HabitSqliteRepository repo;

  setUp(() async {
    db = await _openTestDb();
    repo = HabitSqliteRepository(db);
  });

  tearDown(() => db.close());

  test('insert → getActive() listede görünür', () async {
    await repo.insert(_sampleHabit());
    final list = await repo.getActive();
    expect(list.length, 1);
    expect(list.first.title, 'Koşu');
  });

  test('softDelete → getActive() listede görünmez', () async {
    await repo.insert(_sampleHabit());
    await repo.softDelete('h-1');
    final list = await repo.getActive();
    expect(list, isEmpty);
  });

  test('softDelete → getById() hâlâ döner, deleted_at dolu', () async {
    await repo.insert(_sampleHabit());
    await repo.softDelete('h-1');
    final found = await repo.getById('h-1');
    expect(found, isNotNull);
    expect(found!.deletedAt, isNotNull);
    expect(found.isActive, isFalse);
  });

  test('update → title değişir', () async {
    await repo.insert(_sampleHabit());
    final updated = _sampleHabit(title: 'Yüzme');
    await repo.update(updated);
    final found = await repo.getById('h-1');
    expect(found!.title, 'Yüzme');
  });

  test('weeklyDaysMask doğru saklanır ve okunur', () async {
    final habit = _sampleHabit().copyWith(weeklyDaysMask: 21); // Pzt+Çar+Cum
    await repo.insert(habit);
    final found = await repo.getById('h-1');
    expect(found!.weeklyDaysMask, 21);
  });
}

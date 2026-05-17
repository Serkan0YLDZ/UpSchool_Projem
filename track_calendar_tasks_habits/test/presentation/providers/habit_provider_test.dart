import 'package:flutter_test/flutter_test.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:track_calendar_tasks_habits/data/db/table_constants.dart';
import 'package:track_calendar_tasks_habits/data/models/habit_model.dart';
import 'package:track_calendar_tasks_habits/data/repositories/habit_repository.dart';
import 'package:track_calendar_tasks_habits/presentation/providers/habit_provider.dart';

Future<Database> _openTestDb() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  return openDatabase(
    inMemoryDatabasePath,
    version: 1,
    onCreate: (db, _) async {
      await db.execute(TableConstants.createHabits);
    },
  );
}

void main() {
  late Database db;
  late HabitSqliteRepository repo;
  late HabitProvider provider;

  setUp(() async {
    db = await _openTestDb();
    repo = HabitSqliteRepository(db);
    provider = HabitProvider(repository: repo);
  });

  tearDown(() async {
    await db.close();
  });

  test('loadHabits veritabanından okuyup habits listesine yazar', () async {
    final habit = HabitModel(
      id: 'h1',
      title: 'Spor',
      scheduleKind: ScheduleKind.interval,
      intervalDays: 1,
      anchorDate: '2025-05-15',
      createdAt: '2025-05-15',
      updatedAt: '2025-05-15',
    );
    await repo.insert(habit);

    expect(provider.habits, isEmpty);

    await provider.loadHabits();

    expect(provider.habits.length, 1);
    expect(provider.habits.first.id, 'h1');
  });

  test('addHabit veritabanına ekler ve listeyi günceller', () async {
    final habit = HabitModel(
      id: 'h2',
      title: 'Kitap Okuma',
      scheduleKind: ScheduleKind.weekly,
      weeklyDaysMask: 127,
      anchorDate: '2025-05-15',
      createdAt: '2025-05-15',
      updatedAt: '2025-05-15',
    );

    await provider.addHabit(habit);
    expect(provider.habits.length, 1);
    expect(provider.habits.first.title, 'Kitap Okuma');
  });
}

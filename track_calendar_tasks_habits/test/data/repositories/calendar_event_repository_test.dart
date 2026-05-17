import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:track_calendar_tasks_habits/data/db/database_helper.dart';
import 'package:track_calendar_tasks_habits/data/db/table_constants.dart';
import 'package:track_calendar_tasks_habits/data/models/calendar_event_model.dart';
import 'package:track_calendar_tasks_habits/data/repositories/calendar_event_repository.dart';


Database? _db;

Future<Database> _openTestDb() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  final db = await openDatabase(
    inMemoryDatabasePath,
    version: 1,
    onCreate: (db, _) async {
      await db.execute(TableConstants.createCalendarEvents);
    },
  );
  return db;
}

CalendarEventModel _sampleEvent({
  String id = 'ev-1',
  String title = 'Test Etkinliği',
  String? deletedAt,
}) {
  final now = DateTime.now().toIso8601String();
  return CalendarEventModel(
    id: id,
    title: title,
    startsAt: '2025-05-16T10:00:00',
    createdAt: now,
    updatedAt: now,
    deletedAt: deletedAt,
  );
}

void main() {
  late CalendarEventSqliteRepository repo;

  setUpAll(() async {
    _db = await _openTestDb();
    repo = CalendarEventSqliteRepository(_db!);
  });

  tearDownAll(() async {
    await _db?.close();
    await DatabaseHelper.instance.closeForTest();
  });

  tearDown(() async {
    await _db!.delete(TableConstants.calendarEvents);
  });

  test('insert → getActive() listede görünür', () async {
    await repo.insert(_sampleEvent());
    final list = await repo.getActive();
    expect(list.length, 1);
    expect(list.first.title, 'Test Etkinliği');
  });

  test('softDelete → getActive() listede görünmez', () async {
    await repo.insert(_sampleEvent());
    await repo.softDelete('ev-1');
    final list = await repo.getActive();
    expect(list, isEmpty);
  });

  test('softDelete → getById() hâlâ döner', () async {
    await repo.insert(_sampleEvent());
    await repo.softDelete('ev-1');
    final found = await repo.getById('ev-1');
    expect(found, isNotNull);
    expect(found!.deletedAt, isNotNull);
  });

  test('update → title değişir', () async {
    await repo.insert(_sampleEvent());
    final updated = _sampleEvent(title: 'Yeni Başlık');
    await repo.update(updated);
    final found = await repo.getById('ev-1');
    expect(found!.title, 'Yeni Başlık');
  });

  test('getByDate → yalnızca o güne ait etkinlikler döner', () async {
    final now = DateTime.now().toIso8601String();
    await repo.insert(CalendarEventModel(
      id: 'ev-a',
      title: 'Bugün',
      startsAt: '2025-05-16T09:00:00',
      createdAt: now,
      updatedAt: now,
    ));
    await repo.insert(CalendarEventModel(
      id: 'ev-b',
      title: 'Yarın',
      startsAt: '2025-05-17T09:00:00',
      createdAt: now,
      updatedAt: now,
    ));
    final list = await repo.getByDate('2025-05-16');
    expect(list.length, 1);
    expect(list.first.id, 'ev-a');
  });
}

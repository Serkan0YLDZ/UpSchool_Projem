// Sprint 3: Unit testler — RecordProvider filtreleme (US-308)
// Sprint 2'de yazılan testlere Sprint 3 testleri eklendi.

import 'package:flutter_test/flutter_test.dart';

import 'package:my_new_habit/data/models/record_model.dart';
import 'package:my_new_habit/providers/record_provider.dart';

import '../data/repositories/record_repository_stub.dart';

void main() {
  late RecordProvider provider;
  late StubRecordRepository stub;

  setUp(() {
    stub = StubRecordRepository();
    provider = RecordProvider(stub);
  });

  // ── loadRecords (Sprint 2'den taşındı) ───────────────────────────────────

  test(
    'loadRecords should populate records when repository returns data',
    () async {
      // Arrange
      stub.recordsToReturn = [_habit('h1', 'Koşu'), _habit('h2', 'Kitap')];

      // Act
      await provider.loadRecords();

      // Assert
      expect(provider.records.length, 2);
      expect(provider.isLoading, isFalse);
      expect(provider.hasError, isFalse);
    },
  );

  test(
    'loadRecords should set hasError when repository throws',
    () async {
      // Arrange
      stub.shouldThrow = true;

      // Act
      await provider.loadRecords();

      // Assert
      expect(provider.hasError, isTrue);
      expect(provider.errorMessage, isNotNull);
    },
  );

  // ── createRecord ──────────────────────────────────────────────────────────

  test(
    'createRecord should add record to list when called with valid model',
    () async {
      // Arrange
      final record = _habit('h3', 'Meditasyon');

      // Act
      await provider.createRecord(record);

      // Assert (US-202 kabul kriteri)
      expect(stub.created.any((r) => r.title == 'Meditasyon'), isTrue);
    },
  );

  // ── deleteRecord ──────────────────────────────────────────────────────────

  test(
    'deleteRecord should call repository delete when called with id',
    () async {
      // Arrange
      stub.recordsToReturn = [_habit('h4', 'Egzersiz')];
      await provider.loadRecords();

      // Act
      await provider.deleteRecord('h4');

      // Assert (US-205: silme çalışmalı)
      expect(stub.deletedIds.contains('h4'), isTrue);
    },
  );

  // ── habits getter (Sprint 2'den taşındı) ─────────────────────────────────

  test(
    'habits getter should sort by priority high first when filter is all',
    () async {
      // Arrange
      stub.recordsToReturn = [
        _habit('h5', 'Düşük', priority: Priority.low),
        _habit('h6', 'Yüksek', priority: Priority.high),
        _habit('h7', 'Orta', priority: Priority.medium),
      ];
      await provider.loadRecords();

      // Act
      final habits = provider.habits;

      // Assert (US-304: önem sırasına göre)
      expect(habits[0].priority, Priority.high);
      expect(habits[1].priority, Priority.medium);
      expect(habits[2].priority, Priority.low);
    },
  );

  // ── selectDate (US-302) ───────────────────────────────────────────────────

  test(
    'selectDate should reload records for new date',
    () async {
      // Arrange
      const newDate = '2024-06-15';

      // Act
      await provider.selectDate(newDate);

      // Assert (US-302: farklı güne tıklanınca kayıtlar yüklenmeli)
      expect(provider.selectedDate, newDate);
      expect(stub.lastQueriedDate, newDate);
    },
  );

  // ── applyFilter (US-308) ─────────────────────────────────────────────────

  test(
    'applyFilter mostImportant should sort habits by priority descending',
    () async {
      // Arrange
      stub.recordsToReturn = [
        _habit('hA', 'Düşük Öncelik', priority: Priority.low),
        _habit('hB', 'Yüksek Öncelik', priority: Priority.high),
      ];
      await provider.loadRecords();

      // Act
      provider.applyFilter(FilterType.mostImportant);
      final habits = provider.habits;

      // Assert (US-308: En Önemli filtresi high önce getirir)
      expect(habits.first.priority, Priority.high);
    },
  );

  test(
    'applyFilter should toggle off when same filter applied twice',
    () async {
      // Arrange
      provider.applyFilter(FilterType.thisWeek);
      expect(provider.activeFilter, FilterType.thisWeek);

      // Act — aynı filtreye tekrar bas
      provider.applyFilter(FilterType.thisWeek);

      // Assert — all'a döner (toggle davranışı)
      expect(provider.activeFilter, FilterType.all);
    },
  );

  test(
    'applyFilter earliest should sort habits by createdAt ascending',
    () async {
      // Arrange
      final older = _habitAt('hC', 'Eski', DateTime(2024, 1, 1));
      final newer = _habitAt('hD', 'Yeni', DateTime(2024, 6, 1));
      stub.recordsToReturn = [newer, older];
      await provider.loadRecords();

      // Act
      provider.applyFilter(FilterType.earliest);

      // Assert (En Erken filtresi: createdAt küçük olan önce)
      expect(provider.habits.first.id, 'hC');
    },
  );

  // ── todos (US-305) ──────────────────────────────────────────────────

  test(
    'todos should only return todo type records',
    () async {
      // Arrange
      stub.recordsToReturn = [
        _habit('h8', 'Rutin'),
        _todo('q1', 'Yapılacak'),
        _event('t1', 'Toplantı'),
      ];
      await provider.loadRecords();

      // Act & Assert
      expect(provider.todos.length, 1);
      expect(provider.todos.first.type, RecordType.todo);
    },
  );

  // ── scheduledTasks (US-303) ──────────────────────────────────────────────

  test(
    'scheduledTasks should return only events with scheduledTime sorted by time',
    () async {
      // Arrange
      stub.recordsToReturn = [
        _eventAt('t2', 'Akşam', '18:00'),
        _eventAt('t3', 'Sabah', '09:00'),
        _eventAt('t4', 'Öğle', '13:30'),
      ];
      await provider.loadRecords();

      // Act
      final tasks = provider.scheduledTasks;

      // Assert (US-303: kronolojik sıra)
      expect(tasks[0].scheduledTime, '09:00');
      expect(tasks[1].scheduledTime, '13:30');
      expect(tasks[2].scheduledTime, '18:00');
    },
  );
}

// ── Helpers ───────────────────────────────────────────────────────────────────

RecordModel _habit(String id, String title, {Priority priority = Priority.medium}) =>
    RecordModel(
      id: id,
      type: RecordType.habit,
      title: title,
      priority: priority,
      repeatDays: const [],
      createdAt: DateTime.now(),
    );

RecordModel _habitAt(String id, String title, DateTime createdAt) => RecordModel(
      id: id,
      type: RecordType.habit,
      title: title,
      priority: Priority.medium,
      repeatDays: const [],
      createdAt: createdAt,
    );

RecordModel _todo(String id, String title) => RecordModel(
      id: id,
      type: RecordType.todo,
      title: title,
      createdAt: DateTime.now(),
    );

RecordModel _event(String id, String title) => RecordModel(
      id: id,
      type: RecordType.event,
      title: title,
      createdAt: DateTime.now(),
    );

RecordModel _eventAt(String id, String title, String time) => RecordModel(
      id: id,
      type: RecordType.event,
      title: title,
      scheduledTime: time,
      createdAt: DateTime.now(),
    );

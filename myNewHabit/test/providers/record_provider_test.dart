// Sprint 2: Unit testler — RecordProvider

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

  // ── loadRecords ───────────────────────────────────────────────────────────

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

  // ── computed getters ──────────────────────────────────────────────────────

  test(
    'habits getter should sort by priority high first',
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

      // Assert
      expect(habits[0].priority, Priority.high);
      expect(habits[1].priority, Priority.medium);
      expect(habits[2].priority, Priority.low);
    },
  );

  test(
    'selectDate should reload records for new date',
    () async {
      // Arrange
      const newDate = '2024-06-15';

      // Act
      await provider.selectDate(newDate);

      // Assert
      expect(provider.selectedDate, newDate);
      expect(stub.lastQueriedDate, newDate);
    },
  );
}

// ── Helpers ───────────────────────────────────────────────────────────────────

RecordModel _habit(
  String id,
  String title, {
  Priority priority = Priority.medium,
}) =>
    RecordModel(
      id: id,
      type: RecordType.habit,
      title: title,
      priority: priority,
      repeatDays: const [],
      createdAt: DateTime.now(),
    );

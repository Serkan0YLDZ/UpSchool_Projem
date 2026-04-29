// Sprint 2: Unit testler — RecordRepository (SqfliteRecordRepository)

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:my_new_habit/data/database/database_helper.dart';
import 'package:my_new_habit/data/models/record_model.dart';
import 'package:my_new_habit/data/repositories/record_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late DatabaseHelper dbHelper;
  late SqfliteRecordRepository repository;

  setUp(() async {
    // Her test bağımsız in-memory DB alır — singleton kilit çakışması olmaz.
    dbHelper = DatabaseHelper.forTesting();
    repository = SqfliteRecordRepository(dbHelper);
  });

  tearDown(() async {
    await dbHelper.close();
  });

  // ── create & getAll ────────────────────────────────────────────────────────

  test('create should persist record when called with valid model', () async {
    // Arrange
    final record = _habitRecord(id: 'h1', title: 'Koşu');

    // Act
    await repository.create(record);
    final all = await repository.getAll();

    // Assert
    expect(all.length, 1);
    expect(all.first.id, 'h1');
    expect(all.first.title, 'Koşu');
  });

  test('getAll should return only active records when is_active = 1', () async {
    // Arrange
    final active = _habitRecord(id: 'h2', title: 'Aktif');
    final inactive = _habitRecord(id: 'h3', title: 'Pasif', isActive: false);
    await repository.create(active);
    await repository.create(inactive);

    // Act
    final result = await repository.getAll();

    // Assert — pasif kayıt dönmemeli (US-205 kabul kriteri)
    expect(result.any((r) => r.id == 'h2'), isTrue);
    expect(result.any((r) => r.id == 'h3'), isFalse);
  });

  // ── update ────────────────────────────────────────────────────────────────

  test('update should change title when called with updated model', () async {
    // Arrange
    final record = _habitRecord(id: 'h4', title: 'Eski Ad');
    await repository.create(record);

    // Act
    await repository.update(record.copyWith(title: 'Yeni Ad'));
    final updated = await repository.getById('h4');

    // Assert
    expect(updated?.title, 'Yeni Ad');
  });

  // ── delete ────────────────────────────────────────────────────────────────

  test('delete should remove record when called with existing id', () async {
    // Arrange
    final record = _habitRecord(id: 'h5', title: 'Silinecek');
    await repository.create(record);

    // Act
    await repository.delete('h5');
    final result = await repository.getById('h5');

    // Assert (US-205: silme çalışmalı)
    expect(result, isNull);
  });

  // ── getByDate ─────────────────────────────────────────────────────────────

  test(
    'getByDate should include habit when repeatDays contains target day',
    () async {
      // Arrange — Pazartesi (MON) olan bir alışkanlık
      final record = _habitRecord(
        id: 'h6',
        title: 'Pzt Alışkanlık',
        repeatDays: ['MON'],
      );
      await repository.create(record);

      // Act — 2024-01-08 bir Pazartesi'dir
      final result = await repository.getByDate('2024-01-08');

      // Assert
      expect(result.any((r) => r.id == 'h6'), isTrue);
    },
  );

  test(
    'getByDate should exclude habit when repeatDays does not contain target day',
    () async {
      // Arrange — yalnızca Cuma (FRI) olan alışkanlık
      final record = _habitRecord(
        id: 'h7',
        title: 'Sadece Cuma',
        repeatDays: ['FRI'],
      );
      await repository.create(record);

      // Act — 2024-01-08 Pazartesi'dir (FRI değil)
      final result = await repository.getByDate('2024-01-08');

      // Assert
      expect(result.any((r) => r.id == 'h7'), isFalse);
    },
  );

  test(
    'getByDate should always include quit records',
    () async {
      // Arrange
      final record = RecordModel(
        id: 'q1',
        type: RecordType.quit,
        title: 'Sigara',
        repeatDays: const [],
        createdAt: DateTime.now(),
      );
      await repository.create(record);

      // Act
      final result = await repository.getByDate('2024-01-08');

      // Assert (US-204: quit her zaman görünür)
      expect(result.any((r) => r.id == 'q1'), isTrue);
    },
  );

  test(
    'getByDate should handle intervalDays correctly (e.g. every 3 days)',
    () async {
      // Arrange
      final createdAt = DateTime(2024, 1, 1);
      final record = RecordModel(
        id: 'h8',
        type: RecordType.habit,
        title: '3 Günde Bir',
        repeatDays: const [],
        intervalDays: 3,
        createdAt: createdAt,
      );
      await repository.create(record);

      // Act & Assert
      // 1 Ocak -> 0. gün (göstermeli)
      var result = await repository.getByDate('2024-01-01');
      expect(result.any((r) => r.id == 'h8'), isTrue);

      // 2 Ocak -> 1. gün (göstermemeli)
      result = await repository.getByDate('2024-01-02');
      expect(result.any((r) => r.id == 'h8'), isFalse);

      // 4 Ocak -> 3. gün (göstermeli)
      result = await repository.getByDate('2024-01-04');
      expect(result.any((r) => r.id == 'h8'), isTrue);
    },
  );

  test(
    'getByDate should include task if endDate is null or not passed, exclude if passed',
    () async {
      // Covers: US-203
      // Arrange
      final recordNullEnd = RecordModel(
        id: 't1',
        type: RecordType.task,
        title: 'Bitiş tarihi yok',
        repeatDays: const [],
        createdAt: DateTime(2024, 1, 4),
      );
      final recordWithEnd = RecordModel(
        id: 't2',
        type: RecordType.task,
        title: 'Bitiş tarihi var',
        repeatDays: const [],
        endDate: DateTime(2024, 1, 5),
        createdAt: DateTime(2024, 1, 4),
      );
      
      await repository.create(recordNullEnd);
      await repository.create(recordWithEnd);

      // Act & Assert
      // 2024-01-03 (Before creation date -> should NOT show any)
      var result = await repository.getByDate('2024-01-03');
      expect(result.any((r) => r.id == 't1'), isFalse);
      expect(result.any((r) => r.id == 't2'), isFalse);

      // 2024-01-04 (Creation date -> should show both)
      result = await repository.getByDate('2024-01-04');
      expect(result.any((r) => r.id == 't1'), isTrue);
      expect(result.any((r) => r.id == 't2'), isTrue);

      // 2024-01-05 (On end date -> should show t2, but NOT t1 because t1 only shows on creation date)
      result = await repository.getByDate('2024-01-05');
      expect(result.any((r) => r.id == 't1'), isFalse);
      expect(result.any((r) => r.id == 't2'), isTrue);

      // 2024-01-06 (After end date -> should exclude t2 and t1)
      result = await repository.getByDate('2024-01-06');
      expect(result.any((r) => r.id == 't1'), isFalse);
      expect(result.any((r) => r.id == 't2'), isFalse);
    },
  );
}

// ── Helpers ──────────────────────────────────────────────────────────────────

RecordModel _habitRecord({
  required String id,
  required String title,
  List<String> repeatDays = const [],
  bool isActive = true,
}) {
  return RecordModel(
    id: id,
    type: RecordType.habit,
    title: title,
    priority: Priority.medium,
    repeatDays: repeatDays,
    createdAt: DateTime.now(),
    isActive: isActive,
  );
}

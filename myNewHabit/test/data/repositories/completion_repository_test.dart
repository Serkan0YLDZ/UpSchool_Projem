// Sprint 2: Unit testler — CompletionRepository

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:my_new_habit/data/database/database_helper.dart';
import 'package:my_new_habit/data/models/completion_model.dart';
import 'package:my_new_habit/data/models/record_model.dart';
import 'package:my_new_habit/data/repositories/completion_repository.dart';
import 'package:my_new_habit/data/repositories/record_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late DatabaseHelper dbHelper;
  late SqfliteRecordRepository recordRepo;
  late SqfliteCompletionRepository completionRepo;

  setUp(() async {
    dbHelper = DatabaseHelper.forTesting();
    recordRepo = SqfliteRecordRepository(dbHelper);
    completionRepo = SqfliteCompletionRepository(dbHelper);
    // Her test için temiz bir kayıt oluştur (FK gereksinimi)
    await recordRepo.create(_record('r1'));
  });

  tearDown(() async {
    await dbHelper.close();
  });

  // ── markDone ──────────────────────────────────────────────────────────────

  test(
    'markDone should create completion with done status when called',
    () async {
      // Arrange
      const date = '2024-01-15';

      // Act
      await completionRepo.markDone('c1', 'r1', date);
      final result = await completionRepo.getForRecordAndDate('r1', date);

      // Assert (US-202 kabul kriteri: tamamlama kaydedilebilir)
      expect(result, isNotNull);
      expect(result!.status.isDone, isTrue);
    },
  );

  // ── markSkipped ───────────────────────────────────────────────────────────

  test(
    'markSkipped should create completion with skipped status when called',
    () async {
      // Arrange
      const date = '2024-01-16';

      // Act
      await completionRepo.markSkipped('c2', 'r1', date);
      final result = await completionRepo.getForRecordAndDate('r1', date);

      // Assert
      expect(result?.status.isSkipped, isTrue);
    },
  );

  // ── markRelapsed ──────────────────────────────────────────────────────────

  test(
    'markRelapsed should create completion with relapsed status when called',
    () async {
      // Arrange — US-204: kötü alışkanlık relapse kaydı
      const date = '2024-01-17';

      // Act
      await completionRepo.markRelapsed('c3', 'r1', date);
      final result = await completionRepo.getForRecordAndDate('r1', date);

      // Assert
      expect(result?.status.isRelapsed, isTrue);
    },
  );

  // ── upsert (aynı gün tekrar) ──────────────────────────────────────────────

  test(
    'markDone should overwrite previous status when called twice on same date',
    () async {
      // Arrange — önce skipped, sonra done
      const date = '2024-01-18';
      await completionRepo.markSkipped('c4', 'r1', date);

      // Act
      await completionRepo.markDone('c4', 'r1', date);
      final result = await completionRepo.getForRecordAndDate('r1', date);

      // Assert — en son durum geçerlidir
      expect(result?.status.isDone, isTrue);
    },
  );

  // ── getByDate ─────────────────────────────────────────────────────────────

  test(
    'getByDate should return only completions for given date',
    () async {
      // Arrange
      await completionRepo.markDone('c5', 'r1', '2024-02-01');
      await completionRepo.markDone('c6', 'r1', '2024-02-02');

      // Act
      final result = await completionRepo.getByDate('2024-02-01');

      // Assert
      expect(result.length, 1);
      expect(result.first.date, '2024-02-01');
    },
  );

  // ── delete ────────────────────────────────────────────────────────────────

  test(
    'delete should remove completion when called with existing id',
    () async {
      // Arrange
      const date = '2024-03-01';
      await completionRepo.markDone('c7', 'r1', date);

      // Act
      await completionRepo.delete('c7');
      final result = await completionRepo.getForRecordAndDate('r1', date);

      // Assert
      expect(result, isNull);
    },
  );
}

// ── Helper ────────────────────────────────────────────────────────────────────

RecordModel _record(String id) => RecordModel(
      id: id,
      type: RecordType.habit,
      title: 'Test Alışkanlık',
      repeatDays: const [],
      createdAt: DateTime.now(),
    );

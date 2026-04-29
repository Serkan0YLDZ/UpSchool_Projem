// Sprint 3: Unit testler — CompletionProvider (US-306, US-307)

import 'package:flutter_test/flutter_test.dart';

import 'package:my_new_habit/data/models/completion_model.dart';
import 'package:my_new_habit/providers/completion_provider.dart';

import '../data/repositories/completion_repository_stub.dart';

void main() {
  late CompletionProvider provider;
  late StubCompletionRepository stub;

  const testDate = '2024-06-01';
  const recordId = 'rec-001';

  setUp(() {
    stub = StubCompletionRepository();
    provider = CompletionProvider(stub);
  });

  // ── loadForDate ───────────────────────────────────────────────────────────

  test(
    'loadForDate should populate completions map for given date',
    () async {
      // Arrange
      await stub.markDone('c1', recordId, testDate);

      // Act
      await provider.loadForDate(testDate);

      // Assert (US-302: geçmiş güne tıklanınca completion durumları görünür)
      expect(provider.completionFor(recordId), isNotNull);
      expect(provider.isDone(recordId), isTrue);
    },
  );

  test(
    'loadForDate should set hasError when repository throws',
    () async {
      // Arrange
      stub.shouldThrow = true;

      // Act
      await provider.loadForDate(testDate);

      // Assert
      expect(provider.hasError, isTrue);
    },
  );

  // ── markDone (US-306) ─────────────────────────────────────────────────────

  test(
    'markDone should set isDone true for record when called',
    () async {
      // Act (US-306: alışkanlığı tamamlandı işaretleyebilir)
      await provider.markDone(recordId, testDate);

      // Assert
      expect(provider.isDone(recordId), isTrue);
      expect(provider.hasError, isFalse);
    },
  );

  test(
    'markDone should not throw when called twice on same record',
    () async {
      // Arrange — önce done, sonra tekrar done
      await provider.markDone(recordId, testDate);

      // Act & Assert — exception atmamalı
      expect(
        () async => provider.markDone(recordId, testDate),
        returnsNormally,
      );
    },
  );

  // ── undoCompletion (US-306: geri alma) ───────────────────────────────────

  test(
    'undoCompletion should remove completion so isDone returns false',
    () async {
      // Arrange
      await provider.markDone(recordId, testDate);
      expect(provider.isDone(recordId), isTrue);

      // Act (US-306: tamamlamayı geri alabilir)
      await provider.undoCompletion(recordId);

      // Assert
      expect(provider.isDone(recordId), isFalse);
    },
  );

  test(
    'undoCompletion should do nothing when no completion exists',
    () async {
      // Act & Assert — exception atmamalı, state temiz kalmalı
      expect(
        () async => provider.undoCompletion('nonexistent'),
        returnsNormally,
      );
      expect(provider.hasError, isFalse);
    },
  );

  // ── markRelapsed (US-307) ─────────────────────────────────────────────────

  test(
    'markRelapsed should set status to relapsed when called on quit record',
    () async {
      // Act (US-307: "Yaptım" butonuna basılınca relapsed kaydedilir)
      await provider.markRelapsed(recordId, testDate);

      // Assert
      final completion = provider.completionFor(recordId);
      expect(completion, isNotNull);
      expect(completion!.status, CompletionStatus.relapsed);
    },
  );

  test(
    'markRelapsed should override previous done status',
    () async {
      // Arrange — önce done
      await provider.markDone(recordId, testDate);

      // Act — sonra relapsed
      await provider.markRelapsed(recordId, testDate);

      // Assert — relapsed override eder
      expect(provider.completionFor(recordId)?.status,
          CompletionStatus.relapsed);
    },
  );

  // ── markSkipped ───────────────────────────────────────────────────────────

  test(
    'markSkipped should set status to skipped when called',
    () async {
      // Act
      await provider.markSkipped(recordId, testDate);

      // Assert
      expect(
        provider.completionFor(recordId)?.status,
        CompletionStatus.skipped,
      );
    },
  );
}

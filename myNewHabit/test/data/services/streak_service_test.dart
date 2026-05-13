// Sprint 6: StreakService birim testleri

import 'package:flutter_test/flutter_test.dart';

import 'package:my_new_habit/data/models/completion_model.dart';
import 'package:my_new_habit/data/models/record_model.dart';
import 'package:my_new_habit/data/models/streak_model.dart';
import 'package:my_new_habit/data/services/streak_service.dart';

RecordModel _dailyHabit(String id, DateTime createdMonday) {
  return RecordModel(
    id: id,
    type: RecordType.habit,
    title: 'Test',
    createdAt: createdMonday,
    repeatDays: const [],
    targetProgress: 100,
  );
}

CompletionModel _done(String id, String rid, String date) {
  return CompletionModel(
    id: id,
    recordId: rid,
    date: date,
    status: CompletionStatus.done,
    progress: 100,
  );
}

void main() {
  group('StreakService.reconcile', () {
    test('should increment current streak when two consecutive scheduled days are done', () {
      final habit = _dailyHabit('h1', DateTime.parse('2020-01-06'));
      final completions = [
        _done('c1', 'h1', '2020-01-06'),
        _done('c2', 'h1', '2020-01-07'),
      ];
      final row = StreakModel(recordId: 'h1');
      final out = StreakService.reconcile(
        habit: habit,
        completions: completions,
        todayYmd: '2020-01-07',
        row: row,
      );
      expect(out.currentStreak, 2);
      expect(out.seriesClosedAfter, isNull);
    });

    test('should set seriesClosedAfter when recovery day passes without success', () {
      final habit = _dailyHabit('h2', DateTime.parse('2020-01-06'));
      final completions = [
        _done('c1', 'h2', '2020-01-06'),
        _done('c2', 'h2', '2020-01-07'),
      ];
      final row = StreakModel(recordId: 'h2');
      final out = StreakService.reconcile(
        habit: habit,
        completions: completions,
        todayYmd: '2020-01-10',
        row: row,
      );
      expect(out.seriesClosedAfter, '2020-01-09');
      expect(out.currentStreak, 0);
    });

    test('should continue streak when recovery day is done at target', () {
      final habit = _dailyHabit('h3', DateTime.parse('2020-01-06'));
      final completions = [
        _done('c1', 'h3', '2020-01-06'),
        _done('c2', 'h3', '2020-01-07'),
        _done('c3', 'h3', '2020-01-08'),
      ];
      final row = StreakModel(recordId: 'h3');
      final out = StreakService.reconcile(
        habit: habit,
        completions: completions,
        todayYmd: '2020-01-08',
        row: row,
      );
      expect(out.currentStreak, 3);
      expect(out.seriesClosedAfter, isNull);
    });

    test('should bridge miss when recovery_applied matches open miss and recovery date', () {
      final habit = _dailyHabit('h4', DateTime.parse('2020-01-06'));
      final completions = [
        _done('c1', 'h4', '2020-01-06'),
        _done('c2', 'h4', '2020-01-07'),
      ];
      final row = StreakModel(
        recordId: 'h4',
        openMissDate: '2020-01-08',
        recoveryScheduledDate: '2020-01-09',
        streakFrozenBeforeMiss: 2,
        recoveryApplied: 1,
      );
      final out = StreakService.reconcile(
        habit: habit,
        completions: completions,
        todayYmd: '2020-01-09',
        row: row,
      );
      expect(out.currentStreak, 3);
      expect(out.openMissDate, isNull);
    });

    test('should not miss when day is skipped', () {
      final habit = _dailyHabit('h5', DateTime.parse('2020-01-06'));
      final completions = [
        _done('c1', 'h5', '2020-01-06'),
        CompletionModel(
          id: 's1',
          recordId: 'h5',
          date: '2020-01-07',
          status: CompletionStatus.skipped,
        ),
        _done('c2', 'h5', '2020-01-08'),
      ];
      final row = StreakModel(recordId: 'h5');
      final out = StreakService.reconcile(
        habit: habit,
        completions: completions,
        todayYmd: '2020-01-08',
        row: row,
      );
      expect(out.currentStreak, 3);
      expect(out.openMissDate, isNull);
    });

    test(
        'daily habit with completions only on first and fourth calendar day should hard-close, not show streak 2',
        () {
      final habit = RecordModel(
        id: 'h-gap',
        type: RecordType.habit,
        title: 'Daily',
        createdAt: DateTime.parse('2026-05-11'),
        repeatDays: const [],
        targetProgress: 100,
      );
      final completions = [
        _done('a', 'h-gap', '2026-05-11'),
        _done('b', 'h-gap', '2026-05-14'),
      ];
      final out = StreakService.reconcile(
        habit: habit,
        completions: completions,
        todayYmd: '2026-05-14',
        row: StreakModel(recordId: 'h-gap'),
      );
      expect(out.seriesClosedAfter, '2026-05-13');
      expect(out.currentStreak, 0);
      final view = StreakService.computeView(
        habit: habit,
        completions: completions,
        row: out,
        selectedYmd: '2026-05-14',
        todayYmd: '2026-05-14',
      );
      expect(view.isHiddenForSelectedDate, isTrue);
    });

    test('intervalDays 1 behaves like daily: gap 11 / empty / 14 hard-closes', () {
      final habit = RecordModel(
        id: 'h-int1',
        type: RecordType.habit,
        title: 'Every day (interval 1)',
        createdAt: DateTime.parse('2026-05-11'),
        repeatDays: const [],
        intervalDays: 1,
        targetProgress: 100,
      );
      final completions = [
        _done('a', 'h-int1', '2026-05-11'),
        _done('b', 'h-int1', '2026-05-14'),
      ];
      final out = StreakService.reconcile(
        habit: habit,
        completions: completions,
        todayYmd: '2026-05-14',
        row: StreakModel(recordId: 'h-int1'),
      );
      expect(out.seriesClosedAfter, '2026-05-13');
      expect(out.currentStreak, 0);
      final view = StreakService.computeView(
        habit: habit,
        completions: completions,
        row: out,
        selectedYmd: '2026-05-14',
        todayYmd: '2026-05-14',
      );
      expect(view.isHiddenForSelectedDate, isTrue);
    });

    test('every 3 days habit: two done check-ins can legitimately show streak 2', () {
      final habit = RecordModel(
        id: 'h-int',
        type: RecordType.habit,
        title: 'Interval',
        createdAt: DateTime.parse('2026-05-11'),
        repeatDays: const [],
        intervalDays: 3,
        targetProgress: 100,
      );
      final completions = [
        _done('a', 'h-int', '2026-05-11'),
        _done('b', 'h-int', '2026-05-14'),
      ];
      final out = StreakService.reconcile(
        habit: habit,
        completions: completions,
        todayYmd: '2026-05-14',
        row: StreakModel(recordId: 'h-int'),
      );
      expect(out.seriesClosedAfter, isNull);
      expect(out.currentStreak, 2);
    });
  });

  group('StreakService.computeView', () {
    test('does not count completions on dates after real today toward display streak', () {
      final habit = _dailyHabit('h-fut', DateTime.parse('2026-05-11'));
      final completions = [
        _done('a', 'h-fut', '2026-05-11'),
        _done('b', 'h-fut', '2026-05-14'),
      ];
      final view = StreakService.computeView(
        habit: habit,
        completions: completions,
        row: StreakModel(recordId: 'h-fut'),
        selectedYmd: '2026-05-14',
        todayYmd: '2026-05-11',
      );
      expect(view.displayStreak, 1);
    });
  });

  group('StreakService.isHiddenOnDate', () {
    test('should hide when selected date is after seriesClosedAfter', () {
      final row = StreakModel(recordId: 'x', seriesClosedAfter: '2020-01-08');
      expect(StreakService.isHiddenOnDate(row, '2020-01-09'), isTrue);
      expect(StreakService.isHiddenOnDate(row, '2020-01-08'), isFalse);
    });
  });
}

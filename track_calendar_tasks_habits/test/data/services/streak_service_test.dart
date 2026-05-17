import 'package:flutter_test/flutter_test.dart';
import 'package:track_calendar_tasks_habits/data/models/habit_model.dart';
import 'package:track_calendar_tasks_habits/data/models/habit_day_log_model.dart';
import 'package:track_calendar_tasks_habits/data/models/streak_snapshot_model.dart';
import 'package:track_calendar_tasks_habits/domain/services/streak_service.dart';

void main() {
  final now = DateTime.now().toIso8601String();

  // Habit: anchor=2025-05-10, interval=2 (10, 12, 14, 16...)
  final habit = HabitModel(
    id: 'h-1',
    title: 'Test',
    scheduleKind: ScheduleKind.interval,
    intervalDays: 2,
    anchorDate: '2025-05-10',
    createdAt: now,
    updatedAt: now,
  );

  StreakSnapshotModel initSnapshot() => StreakSnapshotModel(
        habitId: 'h-1',
        updatedAt: now,
      );

  HabitDayLogModel createLog(String date, DayLogStatus status) {
    return HabitDayLogModel(
      id: 'log-$date',
      habitId: 'h-1',
      calendarDate: date,
      status: status,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('processLog — Basit Streak Mantığı', () {
    test('met → streak +1', () {
      var snap = initSnapshot();
      snap = StreakService.processLog(habit, snap, createLog('2025-05-10', DayLogStatus.met));
      expect(snap.currentStreak, 1);
      expect(snap.seriesState, SeriesState.active);
    });

    test('met + met → streak = 2', () {
      var snap = initSnapshot();
      snap = StreakService.processLog(habit, snap, createLog('2025-05-10', DayLogStatus.met));
      snap = StreakService.processLog(habit, snap, createLog('2025-05-12', DayLogStatus.met));
      expect(snap.currentStreak, 2);
      expect(snap.longestStreak, 2);
    });

    test('met + missed → streak sıfırlanır, active kalır', () {
      var snap = initSnapshot();
      snap = StreakService.processLog(habit, snap, createLog('2025-05-10', DayLogStatus.met));
      snap = StreakService.processLog(habit, snap, createLog('2025-05-12', DayLogStatus.missed));
      expect(snap.currentStreak, 0);
      expect(snap.seriesState, SeriesState.active);
      expect(snap.longestStreak, 1);
    });

    test('met + missed + met → streak = 1 (sıfırdan başlar)', () {
      var snap = initSnapshot();
      snap = StreakService.processLog(habit, snap, createLog('2025-05-10', DayLogStatus.met));
      snap = StreakService.processLog(habit, snap, createLog('2025-05-12', DayLogStatus.missed));
      snap = StreakService.processLog(habit, snap, createLog('2025-05-14', DayLogStatus.met));
      expect(snap.currentStreak, 1);
      expect(snap.longestStreak, 1);
    });

    // test('skipped → streak kırılmaz', () {
    //   var snap = initSnapshot();
    //   snap = StreakService.processLog(habit, snap, createLog('2025-05-10', DayLogStatus.met));
    //   snap = StreakService.processLog(habit, snap, createLog('2025-05-12', DayLogStatus.skipped));
    //   expect(snap.currentStreak, 1);
    //   expect(snap.skipUsedThisWeek, 1);
    // });

    test('pending → streak 1 azalır', () {
      var snap = initSnapshot();
      snap = StreakService.processLog(habit, snap, createLog('2025-05-10', DayLogStatus.met));
      snap = StreakService.processLog(habit, snap, createLog('2025-05-12', DayLogStatus.met));
      snap = StreakService.processLog(habit, snap, createLog('2025-05-12', DayLogStatus.pending));
      expect(snap.currentStreak, 1);
    });

    test('longestStreak kaçırma sonrası korunur', () {
      var snap = initSnapshot();
      snap = StreakService.processLog(habit, snap, createLog('2025-05-10', DayLogStatus.met));
      snap = StreakService.processLog(habit, snap, createLog('2025-05-12', DayLogStatus.met));
      snap = StreakService.processLog(habit, snap, createLog('2025-05-14', DayLogStatus.met));
      expect(snap.longestStreak, 3);
      snap = StreakService.processLog(habit, snap, createLog('2025-05-16', DayLogStatus.missed));
      expect(snap.currentStreak, 0);
      expect(snap.longestStreak, 3);
    });
  });

  group('reconcileMissedDays — Full Replay', () {
    test('10 met, 12 ve 14 log yok → 2 missed oluşur, streak=0', () {
      final snap = initSnapshot();
      final existingLogs = [createLog('2025-05-10', DayLogStatus.met)];

      // currentDate=15, yesterday=14 → scheduled 10,12,14 kontrol edilir
      final result = StreakService.reconcileMissedDays(
        habit: habit,
        currentSnapshot: snap,
        existingLogs: existingLogs,
        currentDate: '2025-05-15',
      );

      final newLogs = result['newLogs'] as List<HabitDayLogModel>;
      final updatedSnap = result['snapshot'] as StreakSnapshotModel;

      expect(newLogs.length, 2);
      expect(newLogs[0].calendarDate, '2025-05-12');
      expect(newLogs[1].calendarDate, '2025-05-14');
      expect(updatedSnap.seriesState, SeriesState.active);
      expect(updatedSnap.currentStreak, 0);
    });

    test('10 ve 12 met, 14 log yok → streak=1 (10+12=2, 14 missed → 0 değil! 12 sonrası 14 missed)', () {
      final snap = initSnapshot();
      final existingLogs = [
        createLog('2025-05-10', DayLogStatus.met),
        createLog('2025-05-12', DayLogStatus.met),
      ];

      final result = StreakService.reconcileMissedDays(
        habit: habit,
        currentSnapshot: snap,
        existingLogs: existingLogs,
        currentDate: '2025-05-15',
      );

      final newLogs = result['newLogs'] as List<HabitDayLogModel>;
      final updatedSnap = result['snapshot'] as StreakSnapshotModel;

      // 10=met(1), 12=met(2), 14=missed(0)
      expect(newLogs.length, 1);
      expect(newLogs[0].calendarDate, '2025-05-14');
      expect(updatedSnap.currentStreak, 0);
      expect(updatedSnap.longestStreak, 2);
    });

    test('Bugünkü met logu dahil edilir', () {
      final snap = initSnapshot();
      final existingLogs = [
        createLog('2025-05-10', DayLogStatus.met),
        createLog('2025-05-12', DayLogStatus.met), // bugün
      ];

      // currentDate=12 → yesterday=11 → past: [10]. today=12 scheduled ve met
      final result = StreakService.reconcileMissedDays(
        habit: habit,
        currentSnapshot: snap,
        existingLogs: existingLogs,
        currentDate: '2025-05-12',
      );

      final updatedSnap = result['snapshot'] as StreakSnapshotModel;
      // 10=met(1), bugün 12=met(2)
      expect(updatedSnap.currentStreak, 2);
    });

    test('Mevcut missed log yeniden DB\'ye eklenmiyor (sadece snapshot replay)', () {
      final snap = initSnapshot();
      final existingLogs = [
        createLog('2025-05-10', DayLogStatus.met),
        createLog('2025-05-12', DayLogStatus.missed), // Zaten DB'de var
      ];

      final result = StreakService.reconcileMissedDays(
        habit: habit,
        currentSnapshot: snap,
        existingLogs: existingLogs,
        currentDate: '2025-05-15',
      );

      final newLogs = result['newLogs'] as List<HabitDayLogModel>;
      final updatedSnap = result['snapshot'] as StreakSnapshotModel;

      // 12 zaten var → newLogs'a eklenmez, sadece 14 eklenir
      expect(newLogs.length, 1);
      expect(newLogs[0].calendarDate, '2025-05-14');
      // streak: 10=met(1), 12=missed(0), 14=missed(0)
      expect(updatedSnap.currentStreak, 0);
    });
  });
}

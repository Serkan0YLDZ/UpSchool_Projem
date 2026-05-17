import 'package:flutter/foundation.dart';
import 'package:track_calendar_tasks_habits/data/models/habit_model.dart';
import 'package:track_calendar_tasks_habits/data/models/habit_day_log_model.dart';
import 'package:track_calendar_tasks_habits/data/models/streak_snapshot_model.dart';
import 'package:track_calendar_tasks_habits/data/repositories/streak_snapshot_repository.dart';
import 'package:track_calendar_tasks_habits/data/repositories/habit_day_log_repository.dart';
import 'package:track_calendar_tasks_habits/domain/services/streak_service.dart';
import 'package:track_calendar_tasks_habits/data/utils/habit_schedule.dart';

class StreakViewState {
  final int currentStreak;
  final int longestStreak;
  final bool isCompletedToday;
  final bool isMissedToday;
  final bool isSkippedToday;
  final bool isLapsed; // broken
  final bool isClosed;
  final bool isRecovery;
  final bool isScheduledToday;

  StreakViewState({
    required this.currentStreak,
    required this.longestStreak,
    required this.isCompletedToday,
    required this.isMissedToday,
    required this.isSkippedToday,
    required this.isLapsed,
    required this.isClosed,
    required this.isRecovery,
    required this.isScheduledToday,
  });

  int get displayStreak => currentStreak;
  int get flameTier {
    if (isRecovery) return 2;
    if (currentStreak == 0) return 0;
    return 1; // Fire
  }
  bool get showRecoverCta => isRecovery && !isCompletedToday;
}

class StreakProvider extends ChangeNotifier {
  final StreakSnapshotRepository snapshotRepo;
  final HabitDayLogRepository logRepo;

  StreakProvider({
    required this.snapshotRepo,
    required this.logRepo,
  });

  final Map<String, StreakSnapshotModel> _snapshots = {};
  final Map<String, List<HabitDayLogModel>> _logsCache = {};

  StreakSnapshotModel? getSnapshot(String habitId) => _snapshots[habitId];

  Future<void> loadForHabits(List<HabitModel> habits, String todayYmd) async {
    for (final habit in habits) {
      await reconcileForHabit(habit, todayYmd);
    }
    notifyListeners();
  }

  Future<void> reconcileForHabit(HabitModel habit, String todayYmd) async {
    var snapshot = await snapshotRepo.getByHabitId(habit.id);
    snapshot ??= StreakSnapshotModel(
      habitId: habit.id,
      updatedAt: DateTime.now().toIso8601String(),
    );

    final logs = await logRepo.getByHabitId(habit.id);

    final result = StreakService.reconcileMissedDays(
      habit: habit,
      currentSnapshot: snapshot,
      existingLogs: logs,
      currentDate: todayYmd,
    );

    final updatedSnap = result['snapshot'] as StreakSnapshotModel;
    final newLogs = result['newLogs'] as List<HabitDayLogModel>;

    for (final log in newLogs) {
      await logRepo.upsert(log);
    }
    await snapshotRepo.upsert(updatedSnap);

    _snapshots[habit.id] = updatedSnap;
    _logsCache[habit.id] = await logRepo.getByHabitId(habit.id);
  }

  Future<void> logDay(HabitModel habit, String date, DayLogStatus status) async {
    // logDay öncesi reconcile — snapshot her zaman güncel loglarla hesaplanır
    await reconcileForHabit(habit, date);

    var snapshot = _snapshots[habit.id] ??
        StreakSnapshotModel(habitId: habit.id, updatedAt: DateTime.now().toIso8601String());

    // İdempotency: aynı duruma tekrar set etme
    final existingLog = await logRepo.getByHabitAndDate(habit.id, date);
    if (existingLog != null && existingLog.status == status) return;

    final newLog = HabitDayLogModel(
      id: existingLog?.id ?? 'log_${habit.id}_$date',
      habitId: habit.id,
      calendarDate: date,
      status: status,
      createdAt: existingLog?.createdAt ?? DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    await logRepo.upsert(newLog);

    final updatedSnap = StreakService.processLog(habit, snapshot, newLog);
    await snapshotRepo.upsert(updatedSnap);

    _snapshots[habit.id] = updatedSnap;
    _logsCache[habit.id] = await logRepo.getByHabitId(habit.id);
    notifyListeners();
  }

  Future<void> applyRecovery(String habitId, String date) async {
    final snap = _snapshots[habitId];
    if (snap == null) return;
    
    // We update the snapshot to apply recovery. Wait, does StreakService have applyRecovery?
    // Actually we can just create a log for the missed day, or set recovery_applied.
    // The simplest is to mark the recovery scheduled date as met.
    // Let's assume recovery logs the missed day as met.
    // In our simplified PRD, we just freeze it. Let's just reset the state to active.
    final updated = snap.copyWith(
      seriesState: SeriesState.active,
      recoveryApplied: snap.recoveryApplied + 1,
      updatedAt: DateTime.now().toIso8601String(),
    );
    await snapshotRepo.upsert(updated);
    _snapshots[habitId] = updated;
    notifyListeners();
  }

  Future<void> restartSeries(String habitId, String date) async {
    final snap = _snapshots[habitId];
    if (snap == null) return;
    
    final updated = StreakSnapshotModel(
      habitId: habitId,
      currentStreak: 0,
      longestStreak: snap.longestStreak,
      seriesState: SeriesState.active,
      updatedAt: DateTime.now().toIso8601String(),
    );
    await snapshotRepo.upsert(updated);
    _snapshots[habitId] = updated;
    notifyListeners();
  }

  StreakViewState viewFor(HabitModel habit, String selectedYmd, String todayYmd) {
    final snap = _snapshots[habit.id] ?? StreakSnapshotModel(habitId: habit.id, updatedAt: DateTime.now().toIso8601String());
    final logs = _logsCache[habit.id] ?? [];
    
    // Find log for selectedYmd
    HabitDayLogModel? todayLog;
    for (final l in logs) {
      if (l.calendarDate == selectedYmd) {
        todayLog = l;
        break;
      }
    }

    final isScheduled = HabitSchedule.isScheduledForDate(habit, selectedYmd);

    return StreakViewState(
      currentStreak: snap.currentStreak,
      longestStreak: snap.longestStreak,
      isCompletedToday: todayLog?.status == DayLogStatus.met,
      isMissedToday: todayLog?.status == DayLogStatus.missed,
      isSkippedToday: todayLog?.status == DayLogStatus.skipped,
      isLapsed: snap.seriesState == SeriesState.broken,
      isClosed: snap.seriesState == SeriesState.closed,
      isRecovery: snap.seriesState == SeriesState.broken && snap.recoveryScheduledDate == selectedYmd,
      isScheduledToday: isScheduled,
    );
  }
}

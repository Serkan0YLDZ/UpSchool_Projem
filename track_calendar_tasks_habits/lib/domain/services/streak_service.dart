import 'package:track_calendar_tasks_habits/data/models/habit_model.dart';
import 'package:track_calendar_tasks_habits/data/models/habit_day_log_model.dart';
import 'package:track_calendar_tasks_habits/data/models/streak_snapshot_model.dart';
import 'package:track_calendar_tasks_habits/data/utils/habit_schedule.dart';

/// Alışkanlık streak mantığını işleten saf Dart servisi (Domain Layer).
class StreakService {
  StreakService._();

  static String getIsoWeekKey(String dateStr) {
    final date = DateTime.parse(dateStr);
    final diff = date.weekday - 1;
    final monday = date.subtract(Duration(days: diff));
    return monday.toIso8601String().substring(0, 10);
  }

  /// Yeni bir gün logu girildiğinde mevcut snapshot'ı günceller.
  static StreakSnapshotModel processLog(
    HabitModel habit,
    StreakSnapshotModel currentSnapshot,
    HabitDayLogModel newLog,
  ) {
    final date = newLog.calendarDate;
    var snap = currentSnapshot;

    if (newLog.status == DayLogStatus.met) {
      final newStreak = snap.currentStreak + 1;
      snap = snap.copyWith(
        currentStreak: newStreak,
        longestStreak: newStreak > snap.longestStreak ? newStreak : snap.longestStreak,
        seriesState: SeriesState.active,
        lastDoneDate: date,
      );
    } else if (newLog.status == DayLogStatus.skipped) {
      snap = snap.copyWith(
        skipUsedThisWeek: 1,
        skipConsumedWeekKey: getIsoWeekKey(date),
      );
    } else if (newLog.status == DayLogStatus.missed) {
      // Kaçırılan gün → streak sıfırla, active'de kal
      snap = snap.copyWith(
        currentStreak: 0,
        seriesState: SeriesState.active,
        clearOpenMissDate: true,
        clearRecoveryScheduledDate: true,
        clearStreakFrozenBeforeMiss: true,
      );
    } else if (newLog.status == DayLogStatus.pending) {
      if (snap.currentStreak > 0) {
        final newStreak = snap.currentStreak - 1;
        snap = snap.copyWith(
          currentStreak: newStreak,
          longestStreak: snap.longestStreak == snap.currentStreak
              ? newStreak
              : snap.longestStreak,
        );
      }
    }

    return snap.copyWith(updatedAt: DateTime.now().toIso8601String());
  }

  /// Full-replay yaklaşımı: anchorDate'den bugüne kadar tüm planlı günleri
  /// mevcut loglar üzerinden sıfır snapshot ile yeniden hesaplar.
  ///
  /// Bu sayede herhangi bir DB tutarsızlığı (eski broken/closed snapshot,
  /// eksik missed log, vb.) her reconcile'da otomatik düzeltilir.
  static Map<String, dynamic> reconcileMissedDays({
    required HabitModel habit,
    required StreakSnapshotModel currentSnapshot,
    required List<HabitDayLogModel> existingLogs,
    required String currentDate,
  }) {
    final yesterday = DateTime.parse(currentDate)
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .substring(0, 10);

    // anchorDate → dün: kaçırılan günler missed sayılır
    final pastScheduled = HabitSchedule.getScheduledDatesBetween(
      habit,
      habit.anchorDate,
      yesterday,
    );

    final logMap = {for (final log in existingLogs) log.calendarDate: log};
    final newLogs = <HabitDayLogModel>[];

    // Sıfır snapshot ile tam replay başlat
    var snap = StreakSnapshotModel(
      habitId: habit.id,
      longestStreak: currentSnapshot.longestStreak, // en uzun seriyi koru
      updatedAt: DateTime.now().toIso8601String(),
    );

    for (final dateStr in pastScheduled) {
      final log = logMap[dateStr];
      final isMet = log?.status == DayLogStatus.met;
      final isSkipped = log?.status == DayLogStatus.skipped;

      if (isMet || isSkipped) {
        // Mevcut geçerli log → replay
        snap = processLog(habit, snap, log!);
      } else {
        // Log yok veya pending/missed → missed say
        final missedLog = HabitDayLogModel(
          id: log?.id ?? 'miss_${habit.id}_$dateStr',
          habitId: habit.id,
          calendarDate: dateStr,
          status: DayLogStatus.missed,
          createdAt: log?.createdAt ?? DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );
        if (log == null) newLogs.add(missedLog); // Sadece yeni logları DB'ye ekle
        snap = processLog(habit, snap, missedLog);
      }
    }

    // Bugün planlıysa ve met/skipped log varsa → onu da dahil et
    if (HabitSchedule.isScheduledForDate(habit, currentDate)) {
      final todayLog = logMap[currentDate];
      if (todayLog?.status == DayLogStatus.met ||
          todayLog?.status == DayLogStatus.skipped) {
        snap = processLog(habit, snap, todayLog!);
      }
    }

    return {'snapshot': snap, 'newLogs': newLogs};
  }
}

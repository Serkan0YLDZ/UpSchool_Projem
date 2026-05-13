// Sprint 6: Seri motoru — planlı günler, Es Geç, kurtarma, sert kapanış

import 'package:my_new_habit/core/utils/calendar_date.dart';
import 'package:my_new_habit/data/utils/habit_schedule.dart';
import '../models/completion_model.dart';
import '../models/record_model.dart';
import '../models/streak_model.dart';

/// UI ve `reconcile` çıktısı için özet durum.
class StreakViewState {
  const StreakViewState({
    required this.displayStreak,
    required this.longestStreak,
    required this.showRecoverCta,
    required this.showSkipCta,
    required this.isHiddenForSelectedDate,
    required this.flameTier,
    required this.isRecoveryDay,
  });

  final int displayStreak;
  final int longestStreak;
  final bool showRecoverCta;
  final bool showSkipCta;
  final bool isHiddenForSelectedDate;
  final int flameTier;
  final bool isRecoveryDay;

  static const hidden = StreakViewState(
    displayStreak: 0,
    longestStreak: 0,
    showRecoverCta: false,
    showSkipCta: false,
    isHiddenForSelectedDate: true,
    flameTier: 0,
    isRecoveryDay: false,
  );
}

abstract final class StreakService {
  static String mondayWeekKeyFromYmd(String yyyyMmDd) {
    return mondayWeekKey(DateTime.parse(yyyyMmDd));
  }

  static String mondayWeekKey(DateTime d) {
    final day = DateTime(d.year, d.month, d.day);
    final monday = day.subtract(Duration(days: day.weekday - DateTime.monday));
    return '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
  }

  static bool isTargetDone(RecordModel habit, CompletionModel? c) {
    if (c == null) return false;
    if (c.status != CompletionStatus.done) return false;
    return c.progress >= habit.targetProgress;
  }

  static Map<String, CompletionModel> completionsByDate(
    List<CompletionModel> list,
  ) {
    final m = <String, CompletionModel>{};
    for (final c in list) {
      m[c.date] = c;
    }
    return m;
  }

  static bool isHiddenOnDate(StreakModel? row, String selectedYmd) {
    if (row?.seriesClosedAfter == null) return false;
    return selectedYmd.compareTo(row!.seriesClosedAfter!) > 0;
  }

  /// Bugüne kadar olan planlı günlerden satırı türetir.
  static StreakModel reconcile({
    required RecordModel habit,
    required List<CompletionModel> completions,
    required String todayYmd,
    required StreakModel row,
  }) {
    if (habit.type != RecordType.habit) return row;

    final byDate = completionsByDate(completions);
    final created = _habitStartYmd(habit);
    final scheduled = HabitSchedule.scheduledDaysInclusive(habit, created, todayYmd);

    final thisWeek = mondayWeekKeyFromYmd(todayYmd);
    final skipFields = _skipUsageForWeek(completions, thisWeek);

    final closedStart = row.seriesClosedAfter;

    if (closedStart != null) {
      return StreakModel(
        recordId: habit.id,
        currentStreak: 0,
        longestStreak: row.longestStreak,
        lastDoneDate: row.lastDoneDate,
        skipUsedThisWeek: skipFields.$1,
        skipConsumedWeekKey: skipFields.$2,
        openMissDate: null,
        recoveryScheduledDate: null,
        recoveryApplied: 0,
        streakFrozenBeforeMiss: null,
        seriesClosedAfter: closedStart,
      );
    }

    var streak = 0;
    var best = row.longestStreak;
    String? lastDone;
    String? openM;
    String? recD;
    int? frozen;

    String? closed;

    for (final d in scheduled) {
      final c = byDate[d];
      final done = isTargetDone(habit, c);
      final skipped = c?.status == CompletionStatus.skipped;

      if (openM == null) {
        if (done) {
          streak++;
          lastDone = d;
          if (best < streak) best = streak;
        } else if (skipped) {
          streak++;
          lastDone = d;
          if (best < streak) best = streak;
        } else {
          if (d.compareTo(todayYmd) < 0) {
            openM = d;
            recD = HabitSchedule.nextScheduledAfter(habit, d);
            frozen = streak;
            if (recD == null) {
              closed = d;
              streak = 0;
              openM = null;
              frozen = null;
              break;
            }
          }
        }
      } else {
        if (d.compareTo(openM) <= 0) {
          continue;
        }
        if (recD != null && d.compareTo(recD) < 0) {
          continue;
        }
        if (recD != null && d == recD) {
          if (done || skipped) {
            streak = frozen! + 1;
            if (done) {
              lastDone = d;
            }
            openM = null;
            recD = null;
            frozen = null;
            if (best < streak) best = streak;
          } else if (row.recoveryApplied == 1 &&
              row.recoveryScheduledDate == recD &&
              row.openMissDate == openM) {
            streak = frozen! + 1;
            openM = null;
            recD = null;
            frozen = null;
            if (best < streak) best = streak;
          } else if (d.compareTo(todayYmd) < 0) {
            closed = recD;
            streak = 0;
            openM = null;
            recD = null;
            frozen = null;
            break;
          }
        } else if (recD != null && d.compareTo(recD) > 0) {
          closed = recD;
          streak = 0;
          openM = null;
          recD = null;
          frozen = null;
          break;
        }
      }
    }

    if (closed != null) {
      return StreakModel(
        recordId: habit.id,
        currentStreak: 0,
        longestStreak: best,
        lastDoneDate: lastDone,
        skipUsedThisWeek: skipFields.$1,
        skipConsumedWeekKey: skipFields.$2,
        openMissDate: null,
        recoveryScheduledDate: null,
        recoveryApplied: 0,
        streakFrozenBeforeMiss: null,
        seriesClosedAfter: closed,
      );
    }

    return StreakModel(
      recordId: habit.id,
      currentStreak: streak,
      longestStreak: best,
      lastDoneDate: lastDone,
      skipUsedThisWeek: skipFields.$1,
      skipConsumedWeekKey: skipFields.$2,
      openMissDate: openM,
      recoveryScheduledDate: recD,
      recoveryApplied: 0,
      streakFrozenBeforeMiss: frozen,
      seriesClosedAfter: null,
    );
  }

  static StreakViewState computeView({
    required RecordModel habit,
    required List<CompletionModel> completions,
    required StreakModel row,
    required String selectedYmd,
    required String todayYmd,
  }) {
    if (habit.type != RecordType.habit) {
      return const StreakViewState(
        displayStreak: 0,
        longestStreak: 0,
        showRecoverCta: false,
        showSkipCta: false,
        isHiddenForSelectedDate: false,
        flameTier: 0,
        isRecoveryDay: false,
      );
    }

    if (isHiddenOnDate(row, selectedYmd)) {
      return StreakViewState(
        displayStreak: 0,
        longestStreak: row.longestStreak,
        showRecoverCta: false,
        showSkipCta: false,
        isHiddenForSelectedDate: true,
        flameTier: 0,
        isRecoveryDay: false,
      );
    }

    final byDate = completionsByDate(completions);
    final created = _habitStartYmd(habit);
    final endCap = selectedYmd.compareTo(created) < 0 ? created : selectedYmd;
    final missCutoff = selectedYmd.compareTo(todayYmd) <= 0 ? selectedYmd : todayYmd;

    final scheduled = HabitSchedule.scheduledDaysInclusive(habit, created, endCap);

    var streak = 0;
    String? openM;
    String? recD;
    int? frozen;

    for (final d in scheduled) {
      if (row.seriesClosedAfter != null && d.compareTo(row.seriesClosedAfter!) > 0) {
        break;
      }

      final c = byDate[d];
      final done = isTargetDone(habit, c);
      final skipped = c?.status == CompletionStatus.skipped;
      final isFuture = d.compareTo(todayYmd) > 0;

      if (openM == null) {
        // Gelecek takvim günlerindeki tamamlamalar seriyi artırmaz (gerçek "bugün"
        // henüz o güne gelmediyse 12–13 kaçırılmış sayılmaz; 14 tamamlansa bile 2. alev hatası oluşmasın).
        if (done && !isFuture) {
          streak++;
        } else if (skipped && !isFuture) {
          streak++;
        } else if (!isFuture && d.compareTo(missCutoff) < 0) {
          openM = d;
          recD = HabitSchedule.nextScheduledAfter(habit, d);
          frozen = streak;
        }
      } else {
        if (d.compareTo(openM) <= 0) continue;
        if (recD != null && d.compareTo(recD) < 0) continue;
        if (recD != null && d == recD) {
          if ((done || skipped) && !isFuture) {
            streak = frozen! + 1;
            openM = null;
            recD = null;
            frozen = null;
          } else if (!isFuture &&
              row.recoveryApplied == 1 &&
              row.openMissDate == openM &&
              row.recoveryScheduledDate == recD) {
            streak = frozen! + 1;
            openM = null;
            recD = null;
            frozen = null;
          } else if (!isFuture && d.compareTo(missCutoff) < 0) {
            streak = frozen ?? streak;
            break;
          }
        } else if (recD != null && d.compareTo(recD) > 0 && !isFuture) {
          break;
        }
      }
    }

    final skipUsedThisWeek = _skipUsageForWeek(
      completions,
      mondayWeekKeyFromYmd(todayYmd),
    ).$1;
    final skipAvailable = skipUsedThisWeek == 0;
    final scheduledToday = HabitSchedule.isScheduledOn(habit, selectedYmd);
    final cSel = byDate[selectedYmd];
    final doneSel = isTargetDone(habit, cSel);
    final skipSel = cSel?.status == CompletionStatus.skipped;

    final isRecoveryDay =
        row.recoveryScheduledDate != null &&
        row.recoveryScheduledDate == selectedYmd &&
        row.openMissDate != null;

    final showRecover =
        isRecoveryDay &&
        !doneSel &&
        !skipSel &&
        row.recoveryApplied == 0 &&
        selectedYmd.compareTo(todayYmd) <= 0;

    final showSkip =
        scheduledToday &&
        selectedYmd == todayYmd &&
        !doneSel &&
        !skipSel &&
        skipAvailable;

    var tier = 1;
    if (showRecover) {
      tier = 2;
    } else if (streak >= 7) {
      tier = 3;
    } else if (streak == 0) {
      tier = 0;
    }

    return StreakViewState(
      displayStreak: streak,
      longestStreak: row.longestStreak,
      showRecoverCta: showRecover,
      showSkipCta: showSkip,
      isHiddenForSelectedDate: false,
      flameTier: tier,
      isRecoveryDay: isRecoveryDay,
    );
  }

  static String _habitStartYmd(RecordModel habit) {
    return CalendarDate.ymd(
      DateTime(habit.createdAt.year, habit.createdAt.month, habit.createdAt.day),
    );
  }

  /// (skipUsedThisWeek, skipConsumedWeekKey) — tamamlama listesinden türetilir.
  static (int, String?) _skipUsageForWeek(
    List<CompletionModel> completions,
    String thisWeekMondayKey,
  ) {
    for (final c in completions) {
      if (c.status != CompletionStatus.skipped) continue;
      if (mondayWeekKeyFromYmd(c.date) == thisWeekMondayKey) {
        return (1, thisWeekMondayKey);
      }
    }
    return (0, null);
  }
}

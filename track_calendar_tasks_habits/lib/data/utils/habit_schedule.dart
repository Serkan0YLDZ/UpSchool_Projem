import 'package:track_calendar_tasks_habits/data/models/habit_model.dart';

/// Alışkanlıkların planlı günlerini hesaplamak için yardımcı sınıf.
/// PRD §FR-05 gereksinimlerini karşılar.
class HabitSchedule {
  HabitSchedule._();

  /// Belirli bir tarihin alışkanlık için planlı bir gün olup olmadığını kontrol eder.
  /// [date] ISO8601 YYYY-MM-DD formatında olmalıdır.
  static bool isScheduledForDate(HabitModel habit, String date) {
    final targetDate = DateTime.parse(date);
    final anchor = DateTime.parse(habit.anchorDate);

    // Hedef tarih başlangıç tarihinden önceyse planlı değildir.
    final targetDateOnly = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final anchorDateOnly = DateTime(anchor.year, anchor.month, anchor.day);
    if (targetDateOnly.isBefore(anchorDateOnly)) {
      return false;
    }

    if (habit.scheduleKind == ScheduleKind.weekly) {
      if (habit.weeklyDaysMask == null) return false;
      // DateTime.weekday: 1 (Pzt) ... 7 (Paz)
      // Maskemiz: bit0 (Pzt) ... bit6 (Paz)
      final bitIndex = targetDate.weekday - 1;
      final isSet = (habit.weeklyDaysMask! & (1 << bitIndex)) != 0;
      return isSet;
    } else if (habit.scheduleKind == ScheduleKind.interval) {
      if (habit.intervalDays == null || habit.intervalDays! <= 0) return false;
      final diffDays = targetDateOnly.difference(anchorDateOnly).inDays;
      return diffDays % habit.intervalDays! == 0;
    }

    return false;
  }

  /// Belirli bir tarih aralığındaki tüm planlı günlerin 'YYYY-MM-DD' listesini döner.
  static List<String> getScheduledDatesBetween(
    HabitModel habit,
    String startDate,
    String endDate,
  ) {
    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate);
    final List<String> scheduled = [];

    var current = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);

    while (!current.isAfter(last)) {
      final isoDate = current.toIso8601String().substring(0, 10);
      if (isScheduledForDate(habit, isoDate)) {
        scheduled.add(isoDate);
      }
      current = current.add(const Duration(days: 1));
    }

    return scheduled;
  }
}

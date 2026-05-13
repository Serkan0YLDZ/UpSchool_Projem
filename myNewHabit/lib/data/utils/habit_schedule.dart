// Sprint 6: Planlı alışkanlık günleri — SqfliteRecordRepository.getByDate ile aynı kurallar (DRY tek kaynak).

import 'package:my_new_habit/core/utils/calendar_date.dart';
import 'package:my_new_habit/data/models/record_model.dart';

/// Alışkanlığın belirli bir takvim gününde planlı olup olmadığını hesaplar.
abstract final class HabitSchedule {
  static const _abbrs = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  /// `yyyy-MM-dd` → `MON` … `SUN`
  static String dayAbbreviation(String yyyyMmDd) {
    final weekday = DateTime.parse(yyyyMmDd).weekday;
    return _abbrs[weekday - 1];
  }

  /// [r] habit değilse false döner.
  static bool isScheduledOn(RecordModel r, String yyyyMmDd) {
    if (r.type != RecordType.habit) return false;

    if (r.intervalDays != null) {
      final target = DateTime.parse(yyyyMmDd);
      final start = DateTime(r.createdAt.year, r.createdAt.month, r.createdAt.day);
      final diff = target.difference(start).inDays;
      if (diff < 0) return false;
      return diff % r.intervalDays! == 0;
    }

    return r.repeatDays.isEmpty || r.repeatDays.contains(dayAbbreviation(yyyyMmDd));
  }

  /// [from] ve [to] dahil aralıkta planlı günleri tarih sırasıyla listeler (`yyyy-MM-dd`).
  static List<String> scheduledDaysInclusive(
    RecordModel habit,
    String fromYyyyMmDd,
    String toYyyyMmDd,
  ) {
    if (habit.type != RecordType.habit) return [];

    var cursor = DateTime.parse(fromYyyyMmDd);
    final end = DateTime.parse(toYyyyMmDd);
    final out = <String>[];

    while (!cursor.isAfter(end)) {
      final key = CalendarDate.ymd(cursor);
      if (isScheduledOn(habit, key)) {
        out.add(key);
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    return out;
  }

  /// [afterYyyyMmDd] sonrası ilk planlı gün; yoksa null.
  static String? nextScheduledAfter(RecordModel habit, String afterYyyyMmDd) {
    var cursor = DateTime.parse(afterYyyyMmDd).add(const Duration(days: 1));
    final limit = cursor.add(const Duration(days: 800));
    while (!cursor.isAfter(limit)) {
      final key = CalendarDate.ymd(cursor);
      if (isScheduledOn(habit, key)) return key;
      cursor = cursor.add(const Duration(days: 1));
    }
    return null;
  }
}

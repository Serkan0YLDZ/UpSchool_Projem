import 'package:flutter_test/flutter_test.dart';
import 'package:track_calendar_tasks_habits/data/models/habit_model.dart';
import 'package:track_calendar_tasks_habits/data/utils/habit_schedule.dart';

void main() {
  group('HabitSchedule', () {
    test('anchor_date öncesindeki bir tarih için false döner', () {
      final habit = HabitModel(
        id: 'h-1',
        title: 'Test',
        scheduleKind: ScheduleKind.weekly,
        weeklyDaysMask: 127, // her gün
        anchorDate: '2025-05-10',
        createdAt: '2025-05-10',
        updatedAt: '2025-05-10',
      );

      final isScheduled = HabitSchedule.isScheduledForDate(habit, '2025-05-09');
      expect(isScheduled, isFalse);
    });

    test('weekly maskesine göre gün hesaplaması yapar (Pzt+Çar+Cum)', () {
      // 21 = 0b0010101 -> Pzt (1), Çar (4), Cum (16)
      final habit = HabitModel(
        id: 'h-1',
        title: 'Test',
        scheduleKind: ScheduleKind.weekly,
        weeklyDaysMask: 21,
        anchorDate: '2025-05-12', // 12 Mayıs 2025 bir Pazartesi
        createdAt: '2025-05-12',
        updatedAt: '2025-05-12',
      );

      // 12 Mayıs (Pzt) -> true
      expect(HabitSchedule.isScheduledForDate(habit, '2025-05-12'), isTrue);
      // 13 Mayıs (Sal) -> false
      expect(HabitSchedule.isScheduledForDate(habit, '2025-05-13'), isFalse);
      // 14 Mayıs (Çar) -> true
      expect(HabitSchedule.isScheduledForDate(habit, '2025-05-14'), isTrue);
      // 16 Mayıs (Cum) -> true
      expect(HabitSchedule.isScheduledForDate(habit, '2025-05-16'), isTrue);
    });

    test('interval (N günde bir) doğru hesaplanır', () {
      final habit = HabitModel(
        id: 'h-1',
        title: 'Test',
        scheduleKind: ScheduleKind.interval,
        intervalDays: 2,
        anchorDate: '2025-05-10',
        createdAt: '2025-05-10',
        updatedAt: '2025-05-10',
      );

      // PRD Kanonik senaryo: 10/12/14 planlı, 11/13 plansız.
      expect(HabitSchedule.isScheduledForDate(habit, '2025-05-10'), isTrue);
      expect(HabitSchedule.isScheduledForDate(habit, '2025-05-11'), isFalse);
      expect(HabitSchedule.isScheduledForDate(habit, '2025-05-12'), isTrue);
      expect(HabitSchedule.isScheduledForDate(habit, '2025-05-13'), isFalse);
      expect(HabitSchedule.isScheduledForDate(habit, '2025-05-14'), isTrue);
    });

    test('getScheduledDatesBetween planlı günlerin listesini döner', () {
      final habit = HabitModel(
        id: 'h-1',
        title: 'Test',
        scheduleKind: ScheduleKind.interval,
        intervalDays: 2,
        anchorDate: '2025-05-10',
        createdAt: '2025-05-10',
        updatedAt: '2025-05-10',
      );

      final dates = HabitSchedule.getScheduledDatesBetween(
        habit,
        '2025-05-08',
        '2025-05-15',
      );

      expect(dates, [
        '2025-05-10',
        '2025-05-12',
        '2025-05-14',
      ]);
    });
  });
}

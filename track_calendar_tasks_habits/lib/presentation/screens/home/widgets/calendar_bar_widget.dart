import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:track_calendar_tasks_habits/core/theme/app_spacing.dart';
import 'package:track_calendar_tasks_habits/core/theme/track_custom_colors.dart';
import 'package:track_calendar_tasks_habits/core/utils/calendar_date.dart';
import 'package:track_calendar_tasks_habits/presentation/providers/calendar_event_provider.dart';
import 'package:track_calendar_tasks_habits/presentation/providers/habit_day_log_provider.dart';
import 'package:track_calendar_tasks_habits/presentation/providers/home_state_provider.dart';

/// 7 günlük yatay kaydırılabilir takvim barı.
class CalendarBarWidget extends StatelessWidget {
  const CalendarBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeStateProvider>(
      builder: (context, provider, _) =>
          _CalendarRow(selectedDate: provider.selectedDate),
    );
  }
}

class _CalendarRow extends StatelessWidget {
  const _CalendarRow({required this.selectedDate});

  final String selectedDate;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(
      7,
      (i) => today.subtract(const Duration(days: 1)).add(Duration(days: i)),
    );

    return SizedBox(
      height: AppSpacing.xxl + AppSpacing.lg,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final dateStr = CalendarDate.ymd(day);
          return _DayCell(
            day: day,
            dateStr: dateStr,
            isSelected: dateStr == selectedDate,
          );
        },
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.dateStr,
    required this.isSelected,
  });

  final DateTime day;
  final String dateStr;
  final bool isSelected;

  static const _dayNames = ['PZT', 'SAL', 'ÇAR', 'PER', 'CUM', 'CMT', 'PAZ'];

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final track = context.track;
    final ink = track.brutalistInk;
    final dayLabel = _dayNames[day.weekday - 1];
    final textTheme = Theme.of(context).textTheme;

    final face = isSelected
        ? Color.lerp(track.neoStackFace, track.neoStackOnFace, 0.07)!
        : track.brutalistSurface;
    final depth = 5.0;

    return GestureDetector(
      onTap: () async {
        context.read<HomeStateProvider>().selectDate(dateStr);
        if (!context.mounted) return;
        await context.read<CalendarEventProvider>().loadEvents(dateStr);
        if (!context.mounted) return;
        await context.read<HabitDayLogProvider>().loadLogsForDate(dateStr);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs + AppSpacing.xs / 2,
        ),
        child: Container(
          width: AppSpacing.xxl,
          decoration: BoxDecoration(
            color: face,
            borderRadius: BorderRadius.circular(
              isSelected ? AppSpacing.radiusMd + 2 : AppSpacing.radiusMd,
            ),
            border: Border.all(color: ink, width: AppSpacing.xs),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: track.neoStackShadow,
                      offset: Offset(depth, depth),
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dayLabel,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? track.neoStackOnFace.withValues(alpha: 0.95)
                      : scheme.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${day.day}',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isSelected
                      ? track.neoStackOnFace
                      : scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

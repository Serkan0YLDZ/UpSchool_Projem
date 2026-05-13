// Sprint 3: Ana Sayfa & Takvim — CalendarBarWidget (US-301, US-302)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/calendar_date.dart';
import '../../../providers/completion_provider.dart';
import '../../../providers/record_provider.dart';
import '../../../providers/streak_provider.dart';

/// 7 günlük yatay kaydırılabilir takvim barı.
///
/// PRD: "Dün, Bugün ve Gelecek 5 Gün" gösterilir.
/// Seçili gün: AppColors.primary dairesi + beyaz metin.
class CalendarBarWidget extends StatelessWidget {
  const CalendarBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer burada kasıtlı olarak küçük tutulmuştur (sadece bar rebuilds).
    return Consumer<RecordProvider>(
      builder: (context, provider, _) {
        return _CalendarRow(selectedDate: provider.selectedDate);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CalendarRow extends StatelessWidget {
  const _CalendarRow({required this.selectedDate});

  final String selectedDate;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    // Dün (index 0), Bugün (index 1), Gelecek 5 Gün (index 2–6) = 7 gün toplam.
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
          final isSelected = dateStr == selectedDate;
          return _DayCell(
            day: day,
            dateStr: dateStr,
            isSelected: isSelected,
            index: index,
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.dateStr,
    required this.isSelected,
    required this.index,
  });

  final DateTime day;
  final String dateStr;
  final bool isSelected;
  final int index;

  static const _dayNames = ['PZT', 'SAL', 'ÇAR', 'PER', 'CUM', 'CMT', 'PAZ'];

  @override
  Widget build(BuildContext context) {
    final dayLabel = _dayNames[day.weekday - 1];
    final rotation = index % 2 == 0 ? -1.5 : 1.5;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () async {
        final rp = context.read<RecordProvider>();
        final cp = context.read<CompletionProvider>();
        final sp = context.read<StreakProvider>();
        await rp.selectDate(dateStr);
        if (!context.mounted) return;
        await cp.loadForDate(dateStr);
        if (!context.mounted) return;
        final todayYmd = CalendarDate.todayYmd();
        await sp.loadForHabits(rp.habits, todayYmd);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs + AppSpacing.xs / 2,
        ),
        child: Transform.rotate(
          angle: rotation * 3.1415926535 / 180,
          child: Container(
            width: AppSpacing.xxl,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryContainer
                  : AppColors.brutalistWhite,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.brutalistBlack, width: AppSpacing.xs),
              boxShadow: isSelected
                  ? const [
                      BoxShadow(
                        color: AppColors.brutalistBlack,
                        offset: Offset(4, 4),
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
                        ? AppColors.onPrimary.withValues(alpha: 0.78)
                        : AppColors.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${day.day}',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

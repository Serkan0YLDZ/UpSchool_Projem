// Sprint 3: Ana Sayfa & Takvim — CalendarBarWidget (US-301, US-302)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../providers/record_provider.dart';

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
    final days = List.generate(7, (i) => today.subtract(const Duration(days: 1)).add(Duration(days: i)));

    return SizedBox(
      height: 84,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final dateStr = DateFormat('yyyy-MM-dd').format(day);
          final isSelected = dateStr == selectedDate;
          return _DayCell(
            day: day,
            dateStr: dateStr,
            isSelected: isSelected,
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
  });

  final DateTime day;
  final String dateStr;
  final bool isSelected;

  static const _dayNames = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cts', 'Paz'];

  @override
  Widget build(BuildContext context) {
    final dayLabel = _dayNames[day.weekday - 1];

    return GestureDetector(
      onTap: () => context.read<RecordProvider>().selectDate(dateStr),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: isSelected ? 52 : 44,
          height: isSelected ? 80 : 72,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(32),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dayLabel.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.85)
                          : AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${day.day}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isSelected ? Colors.white : AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

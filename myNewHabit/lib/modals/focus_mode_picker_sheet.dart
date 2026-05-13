import 'package:flutter/material.dart';
import 'package:my_new_habit/core/utils/calendar_date.dart';
import 'package:provider/provider.dart';

import 'package:my_new_habit/core/theme/app_colors.dart';
import 'package:my_new_habit/core/theme/app_spacing.dart';
import 'package:my_new_habit/providers/completion_provider.dart';
import 'package:my_new_habit/providers/record_provider.dart';
import 'package:my_new_habit/providers/streak_provider.dart';
import 'package:my_new_habit/screens/focus/focus_section.dart';

/// Takvim ikonu uzun basış: Takvim / Alışkanlıklar / Yapılacaklar arasından birini seç.
Future<FocusSection?> showFocusModePickerSheet(BuildContext context) async {
  final recordProvider = context.read<RecordProvider>();
  final completionProvider = context.read<CompletionProvider>();
  final streakProvider = context.read<StreakProvider>();

  await recordProvider.loadRecords();
  if (!context.mounted) return null;
  await completionProvider.loadForDate(recordProvider.selectedDate);
  if (!context.mounted) return null;
  final todayYmd = CalendarDate.todayYmd();
  await streakProvider.loadForHabits(recordProvider.habits, todayYmd);
  if (!context.mounted) return null;

  return showModalBottomSheet<FocusSection>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      decoration: const BoxDecoration(
        color: AppColors.brutalistWhite,
        border: Border(
          top: BorderSide(color: AppColors.brutalistBlack, width: 4),
          left: BorderSide(color: AppColors.brutalistBlack, width: 4),
          right: BorderSide(color: AppColors.brutalistBlack, width: 4),
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BÖLÜM SEÇ',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.brutalistBlack,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Tam ekranda yalnızca seçtiğin bölümü görürsün.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _ModeRow(
                  label: 'Takvim',
                  subtitle: 'Saatli planlar',
                  icon: Icons.event_rounded,
                  accent: AppColors.primaryContainer,
                  onTap: () => Navigator.of(ctx).pop(FocusSection.calendar),
                ),
                _ModeRow(
                  label: 'Alışkanlıklar',
                  subtitle: 'Rutin kartları',
                  icon: Icons.repeat_rounded,
                  accent: AppColors.sectionBannerYellow,
                  onTap: () => Navigator.of(ctx).pop(FocusSection.habits),
                ),
                _ModeRow(
                  label: 'Yapılacaklar',
                  subtitle: 'Görev listesi',
                  icon: Icons.checklist_rounded,
                  accent: AppColors.sectionBannerPurple,
                  onTap: () => Navigator.of(ctx).pop(FocusSection.todos),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _ModeRow extends StatelessWidget {
  const _ModeRow({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.smMd),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.smMd + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.brutalistWhite,
          border: Border.all(color: AppColors.brutalistBlack, width: 3),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: const [
            BoxShadow(color: AppColors.brutalistBlack, offset: Offset(4, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.brutalistBlack, width: 2),
              ),
              child: Icon(icon, size: 22, color: AppColors.onPrimary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.brutalistBlack,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.brutalistBlack,
            ),
          ],
        ),
      ),
    );
  }
}

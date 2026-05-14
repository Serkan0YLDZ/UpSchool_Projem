import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/track_custom_colors.dart';
import '../core/utils/calendar_date.dart';
import '../providers/completion_provider.dart';
import '../providers/record_provider.dart';
import '../providers/streak_provider.dart';
import '../screens/focus/focus_section.dart';

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
    builder: (ctx) {
      final track = ctx.track;
      final scheme = ctx.scheme;
      final ink = track.brutalistInk;

      return Container(
        decoration: BoxDecoration(
          color: track.brutalistSurface,
          border: Border(
            top: BorderSide(color: ink, width: 4),
            left: BorderSide(color: ink, width: 4),
            right: BorderSide(color: ink, width: 4),
          ),
          borderRadius: const BorderRadius.vertical(
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
                  Text(
                    'BÖLÜM SEÇ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: ink,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Tam ekranda yalnızca seçtiğin bölümü görürsün.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _ModeRow(
                    label: 'Takvim',
                    subtitle: 'Saatli planlar',
                    icon: Icons.event_rounded,
                    accent: AppColors.homeSectionCalendarBlue,
                    onTap: () => Navigator.of(ctx).pop(FocusSection.calendar),
                  ),
                  _ModeRow(
                    label: 'Alışkanlıklar',
                    subtitle: 'Rutin kartları',
                    icon: Icons.repeat_rounded,
                    accent: AppColors.homeSectionHabitsCoral,
                    onTap: () => Navigator.of(ctx).pop(FocusSection.habits),
                  ),
                  _ModeRow(
                    label: 'Yapılacaklar',
                    subtitle: 'Görev listesi',
                    icon: Icons.checklist_rounded,
                    accent: AppColors.homeSectionTodosOrange,
                    onTap: () => Navigator.of(ctx).pop(FocusSection.todos),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
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
    final track = context.track;
    final scheme = context.scheme;
    final ink = track.brutalistInk;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.smMd),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.smMd + 2,
        ),
        decoration: BoxDecoration(
          color: track.brutalistSurface,
          border: Border.all(color: ink, width: 3),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: [BoxShadow(color: ink, offset: const Offset(4, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: ink, width: 2),
              ),
              child: Icon(icon, size: 22, color: scheme.onPrimary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      color: ink,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: ink),
          ],
        ),
      ),
    );
  }
}

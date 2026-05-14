import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/track_custom_colors.dart';
import '../data/models/record_model.dart';

Future<void> showAddRecordModal(
  BuildContext context, {
  required void Function(RecordType type) onTypeSelected,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _AddRecordSheet(onTypeSelected: onTypeSelected),
  );
}

class _AddRecordSheet extends StatelessWidget {
  const _AddRecordSheet({required this.onTypeSelected});

  final void Function(RecordType type) onTypeSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final track = context.track;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.marginMobile,
        AppSpacing.md,
        AppSpacing.marginMobile,
        AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Ne Eklemek İstersin?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: track.brutalistInk,
                  ),
            ),
            const SizedBox(height: AppSpacing.cardPadding),
            _TypeTile(
              icon: Icons.calendar_today_rounded,
              label: 'TAKVİME\nEKLE',
              subtitle: 'Etkinlik veya randevunu kaydet',
              backgroundColor: AppColors.homeSectionCalendarBlue,
              labelColor: Colors.white,
              subtitleColor: Colors.white.withValues(alpha: 0.9),
              onTap: () => onTypeSelected(RecordType.event),
            ),
            const SizedBox(height: AppSpacing.md),
            _TypeTile(
              icon: Icons.star_border_rounded,
              label: 'ALIŞKANLIK\nEKLE',
              subtitle: 'Günlük rutinini şekillendir',
              backgroundColor: AppColors.homeSectionHabitsCoral,
              labelColor: Colors.white,
              subtitleColor: Colors.white.withValues(alpha: 0.9),
              onTap: () => onTypeSelected(RecordType.habit),
            ),
            const SizedBox(height: AppSpacing.md),
            _TypeTile(
              icon: Icons.check_box_outlined,
              label: 'YAPILACAK\nEKLE',
              subtitle: 'Hızlı görev oluştur',
              backgroundColor: AppColors.homeSectionTodosOrange,
              labelColor: Colors.white,
              subtitleColor: Colors.white.withValues(alpha: 0.9),
              onTap: () => onTypeSelected(RecordType.todo),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _TypeTile extends StatelessWidget {
  const _TypeTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.backgroundColor,
    required this.onTap,
    this.labelColor,
    this.subtitleColor,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color backgroundColor;
  final VoidCallback onTap;
  final Color? labelColor;
  final Color? subtitleColor;

  @override
  Widget build(BuildContext context) {
    final track = context.track;
    final ink = track.brutalistInk;
    final titleColor = labelColor ?? ink;
    final subColor =
        subtitleColor ?? Theme.of(context).colorScheme.onSurfaceVariant;
    final iconColor = labelColor != null ? backgroundColor : ink;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: ink, width: 4),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: ink, offset: const Offset(6, 6))],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: track.brutalistSurface,
                shape: BoxShape.circle,
                border: Border.all(color: ink, width: 4),
              ),
              child: Icon(icon, size: 32, color: iconColor),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: titleColor,
                height: 1.2,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: subColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

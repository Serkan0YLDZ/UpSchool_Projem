// Sprint 6: US-604 — En uzun seri bilgisi

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Rozet dokunuşunda gösterilen kısa istatistik diyaloğu.
Future<void> showStreakStatsDialog(
  BuildContext context, {
  required int longestStreak,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.brutalistBlack, width: 3),
            boxShadow: const [
              BoxShadow(color: AppColors.brutalistBlack, offset: Offset(4, 4)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_fire_department, color: AppColors.streakFire, size: 40),
              const SizedBox(height: AppSpacing.md),
              Text(
                'En uzun serin: $longestStreak gün',
                textAlign: TextAlign.center,
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.brutalistBlack,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  'Tamam',
                  style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryContainer,
                      ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

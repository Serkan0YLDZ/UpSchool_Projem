import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';
import '../core/theme/track_custom_colors.dart';

Future<void> showStreakStatsDialog(
  BuildContext context, {
  required int longestStreak,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) {
      final scheme = ctx.scheme;
      final track = ctx.track;
      final ink = track.brutalistInk;

      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: ink, width: 3),
            boxShadow: [BoxShadow(color: ink, offset: const Offset(4, 4))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_fire_department, color: track.streakFire, size: 40),
              const SizedBox(height: AppSpacing.md),
              Text(
                'En uzun serin: $longestStreak gün',
                textAlign: TextAlign.center,
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: ink,
                    ),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  'Tamam',
                  style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: scheme.primaryContainer,
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

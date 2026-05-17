import 'package:flutter/material.dart';

import 'package:track_calendar_tasks_habits/core/theme/app_spacing.dart';
import 'package:track_calendar_tasks_habits/core/theme/app_typography.dart';
import 'package:track_calendar_tasks_habits/core/theme/track_custom_colors.dart';

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.textColor,
  });

  final String label;
  final IconData? icon;
  final Color? color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final bg = color ?? scheme.primaryContainer;
    final fg = textColor ?? scheme.onPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.smMd,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(label, style: AppTypography.labelSm.copyWith(color: fg)),
        ],
      ),
    );
  }
}

class PriorityBadge extends StatelessWidget {
  const PriorityBadge({super.key, required this.priorityLabel});

  final String priorityLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final track = context.track;
    final (color, textColor) = switch (priorityLabel.toLowerCase()) {
      'high' || 'yüksek' => (scheme.error.withAlpha(26), scheme.error),
      'medium' ||
      'orta' =>
        (track.streakFire.withAlpha(26), track.streakFire),
      _ => (scheme.surfaceContainerHigh, scheme.onSurfaceVariant),
    };

    return AppBadge(label: priorityLabel, color: color, textColor: textColor);
  }
}

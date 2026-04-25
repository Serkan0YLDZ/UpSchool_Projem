// Sprint 1: Core widget — Rozet (badge) bileşeni
// Kural: const zorunlu; design token kullanımı.

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Küçük bilgi rozeti — streak sayısı, öncelik etiketi vb. için kullanılır.
///
/// Tasarım: pill shape, düşük doygunluklu arka plan rengi.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.icon,
    this.color = AppColors.primaryContainer,
    this.textColor = AppColors.onPrimary,
  });

  final String label;
  final IconData? icon;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.smMd,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(label, style: AppTypography.labelSm.copyWith(color: textColor)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Öncelik seviyesine göre önceden renklendirilmiş rozet.
class PriorityBadge extends StatelessWidget {
  const PriorityBadge({super.key, required this.priorityLabel});

  final String priorityLabel;

  @override
  Widget build(BuildContext context) {
    final (color, textColor) = switch (priorityLabel.toLowerCase()) {
      'high' || 'yüksek' => (
          AppColors.error.withAlpha(26),
          AppColors.error,
        ),
      'medium' || 'orta' => (
          AppColors.streakFire.withAlpha(26),
          AppColors.streakFire,
        ),
      _ => (
          AppColors.surfaceContainerHigh,
          AppColors.onSurfaceVariant,
        ),
    };

    return AppBadge(
      label: priorityLabel,
      color: color,
      textColor: textColor,
    );
  }
}

// Sprint 1: Core widget — Boş durum (empty state) gösterici
// Kural: Her liste/bölüm 3 state'i yönetmek zorunda: loading, error, empty.

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Veri olmadığında gösterilen merkezi boş durum widget'ı.
///
/// [message] zorunludur; [ctaLabel] ve [onCtaPressed] opsiyoneldir.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.message,
    this.emoji = '📭',
    this.ctaLabel,
    this.onCtaPressed,
  });

  final String message;
  final String emoji;
  final String? ctaLabel;
  final VoidCallback? onCtaPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            if (ctaLabel != null && onCtaPressed != null) ...[
              const SizedBox(height: AppSpacing.md),
              TextButton.icon(
                onPressed: onCtaPressed,
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: Text(ctaLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

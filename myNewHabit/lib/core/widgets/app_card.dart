// Sprint 1: Core widget — Yeniden kullanılabilir kart
// Kural: Hardcode padding/radius yok; AppSpacing kullanılır.

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Uygulamada kullanılan standart kart konteyneri.
///
/// Tasarım kuralı: Kenarlık yok, ambient shadow, 16dp radius.
/// Tıklanabilir kartlar için [onTap] parametresi sağlanır.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.color = AppColors.surfaceContainerLowest,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color color;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppSpacing.radiusLg);

    return Material(
      color: color,
      borderRadius: radius,
      shadowColor: AppColors.ambientShadow,
      elevation: 1,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        splashColor: AppColors.primaryContainer.withAlpha(20),
        highlightColor: AppColors.primaryContainer.withAlpha(10),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

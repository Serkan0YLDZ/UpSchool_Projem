import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'brutalist_container.dart';

class BrutalistBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final double rotatedOffset;
  final TextStyle? textStyle;

  const BrutalistBadge({
    super.key,
    required this.text,
    this.backgroundColor = AppColors.neoBadgeDefaultYellow,
    this.rotatedOffset = 0.0,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return BrutalistContainer(
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      borderRadius: AppSpacing.radiusSm,
      shadowOffset: 4.0,
      borderWidth: 3.0,
      rotatedOffset: rotatedOffset,
      child: Text(
        text,
        style: textStyle ??
            Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.brutalistBlack,
                  letterSpacing: -0.5,
                ),
      ),
    );
  }
}

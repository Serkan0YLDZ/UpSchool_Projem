import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/track_custom_colors.dart';
import 'brutalist_container.dart';

class BrutalistBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final double rotatedOffset;
  final TextStyle? textStyle;
  final double borderRadius;
  final double shadowOffset;
  final double borderWidth;

  const BrutalistBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.rotatedOffset = 0.0,
    this.textStyle,
    this.borderRadius = AppSpacing.radiusSm,
    this.shadowOffset = 4.0,
    this.borderWidth = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    final track = context.track;
    return BrutalistContainer(
      backgroundColor: backgroundColor ?? track.neoBadgeDefaultYellow,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      borderRadius: borderRadius,
      shadowOffset: shadowOffset,
      borderWidth: borderWidth,
      rotatedOffset: rotatedOffset,
      child: Text(
        text,
        style: textStyle ??
            Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: track.brutalistInk,
                  letterSpacing: -0.5,
                ),
      ),
    );
  }
}

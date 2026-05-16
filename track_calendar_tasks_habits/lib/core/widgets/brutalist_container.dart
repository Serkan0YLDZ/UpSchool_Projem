import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/track_custom_colors.dart';

class BrutalistContainer extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final double borderWidth;
  final double shadowOffset;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final double rotatedOffset;

  const BrutalistContainer({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderWidth = 4.0,
    this.shadowOffset = 6.0,
    this.borderRadius = AppSpacing.radiusXl,
    this.padding,
    this.margin,
    this.onTap,
    this.rotatedOffset = 0.0,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final track = context.track;
    final bg = backgroundColor ?? track.brutalistSurface;
    final ink = track.brutalistInk;

    Widget content = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: ink, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: ink,
            offset: Offset(shadowOffset, shadowOffset),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius - borderWidth),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.md),
            child: child,
          ),
        ),
      ),
    );

    if (rotatedOffset != 0.0) {
      content = Transform.rotate(
        angle: rotatedOffset * 3.1415926535897932 / 180,
        child: content,
      );
    }

    return content;
  }
}

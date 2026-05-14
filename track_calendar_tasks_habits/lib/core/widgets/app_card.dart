import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/track_custom_colors.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.color,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final track = context.track;
    final bg = color ?? scheme.surfaceContainerLowest;
    final radius = borderRadius ?? BorderRadius.circular(AppSpacing.radiusLg);

    return Material(
      color: bg,
      borderRadius: radius,
      shadowColor: track.ambientShadow,
      elevation: 1,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        splashColor: scheme.primaryContainer.withAlpha(20),
        highlightColor: scheme.primaryContainer.withAlpha(10),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

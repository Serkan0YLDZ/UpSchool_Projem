import 'package:flutter/material.dart';

import 'package:track_calendar_tasks_habits/core/theme/app_spacing.dart';
import 'package:track_calendar_tasks_habits/core/theme/app_typography.dart';
import 'package:track_calendar_tasks_habits/core/theme/track_custom_colors.dart';
import 'package:track_calendar_tasks_habits/core/widgets/brutalist_container.dart';

class ProfileSignInRow extends StatelessWidget {
  const ProfileSignInRow({
    super.key,
    required this.label,
    required this.onTap,
    this.leading,
    this.backgroundColor,
    this.rotatedOffset = 0.0,
  });

  final String label;
  final VoidCallback? onTap;
  final Widget? leading;
  final Color? backgroundColor;
  final double rotatedOffset;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final track = context.track;
    final bg = backgroundColor ?? track.brutalistSurface;

    return BrutalistContainer(
      onTap: onTap,
      backgroundColor: bg,
      rotatedOffset: rotatedOffset,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.smMd,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Text(
              label,
              style: AppTypography.labelLg.copyWith(
                color: onTap == null
                    ? scheme.onSurfaceVariant
                    : scheme.onSurface,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: scheme.onSurfaceVariant,
            size: 28,
          ),
        ],
      ),
    );
  }
}

class GoogleSignInLeading extends StatelessWidget {
  const GoogleSignInLeading({super.key});

  @override
  Widget build(BuildContext context) {
    final track = context.track;
    final scheme = context.scheme;
    final ink = track.brutalistInk;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: track.googleBrandBlue,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: ink, width: 2.5),
      ),
      alignment: Alignment.center,
      child: Text(
        'G',
        style: AppTypography.headlineSm.copyWith(
          color: scheme.onPrimary,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

class AppleSignInLeading extends StatelessWidget {
  const AppleSignInLeading({super.key});

  @override
  Widget build(BuildContext context) {
    final track = context.track;
    final ink = track.brutalistInk;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: ink,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: ink, width: 2.5),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.phone_iphone_rounded,
        color: track.brutalistSurface,
        size: 22,
      ),
    );
  }
}

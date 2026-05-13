import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/brutalist_container.dart';

/// Tek satırlık giriş seçeneği (Google / Apple / e-posta mock).
class ProfileSignInRow extends StatelessWidget {
  const ProfileSignInRow({
    super.key,
    required this.label,
    required this.onTap,
    this.leading,
    this.backgroundColor = AppColors.brutalistWhite,
    this.rotatedOffset = 0.0,
  });

  final String label;
  final VoidCallback? onTap;
  final Widget? leading;
  final Color backgroundColor;
  final double rotatedOffset;

  @override
  Widget build(BuildContext context) {
    return BrutalistContainer(
      onTap: onTap,
      backgroundColor: backgroundColor,
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
                    ? AppColors.onSurfaceVariant
                    : AppColors.onSurface,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.onSurfaceVariant,
            size: 28,
          ),
        ],
      ),
    );
  }
}

/// Google “G” rozeti.
class GoogleSignInLeading extends StatelessWidget {
  const GoogleSignInLeading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.googleBrandBlue,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.brutalistBlack, width: 2.5),
      ),
      alignment: Alignment.center,
      child: Text(
        'G',
        style: AppTypography.headlineSm.copyWith(
          color: AppColors.onPrimary,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

/// Apple tarzı siyah kutu + beyaz simge (marka asset’i yok; metin tabanlı).
class AppleSignInLeading extends StatelessWidget {
  const AppleSignInLeading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.brutalistBlack,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.brutalistBlack, width: 2.5),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.phone_iphone_rounded,
        color: AppColors.brutalistWhite,
        size: 22,
      ),
    );
  }
}

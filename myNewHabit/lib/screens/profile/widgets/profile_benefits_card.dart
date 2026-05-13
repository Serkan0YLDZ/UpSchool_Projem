import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/brutalist_container.dart';

/// Giriş yapmanın faydalarını anlatan kart (misafir görünümü).
class ProfileBenefitsCard extends StatelessWidget {
  const ProfileBenefitsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BrutalistContainer(
      rotatedOffset: -0.8,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Giriş yapınca neler olur?',
            style: AppTypography.headlineSm.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.smMd),
          _bullet(
            'Alışkanlık ve görev verilerin bulutta güvenle saklanır.',
          ),
          const SizedBox(height: AppSpacing.sm),
          _bullet(
            'Telefon veya tablette aynı hesapla otomatik senkron olur.',
          ),
          const SizedBox(height: AppSpacing.sm),
          _bullet(
            'İlerlemen, seriler ve özet grafikler hesabına bağlandığında burada görünür.',
          ),
          const SizedBox(height: AppSpacing.smMd),
          Text(
            'Giriş yapmadan da uygulamanın tamamını kullanmaya devam edebilirsin; veriler şimdilik yalnızca bu cihazda kalır.',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '•',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.primaryContainer,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

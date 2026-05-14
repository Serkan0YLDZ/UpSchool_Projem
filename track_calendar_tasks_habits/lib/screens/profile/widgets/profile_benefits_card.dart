import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/track_custom_colors.dart';
import '../../../core/widgets/brutalist_container.dart';

class ProfileBenefitsCard extends StatelessWidget {
  const ProfileBenefitsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return BrutalistContainer(
      rotatedOffset: -0.8,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Giriş yapınca neler olur?',
            style: AppTypography.headlineSm.copyWith(color: scheme.onSurface),
          ),
          const SizedBox(height: AppSpacing.smMd),
          _Bullet(
            text: 'Alışkanlık ve görev verilerin bulutta güvenle saklanır.',
          ),
          const SizedBox(height: AppSpacing.sm),
          _Bullet(
            text: 'Telefon veya tablette aynı hesapla otomatik senkron olur.',
          ),
          const SizedBox(height: AppSpacing.sm),
          _Bullet(
            text:
                'İlerlemen, seriler ve özet grafikler hesabına bağlandığında burada görünür.',
          ),
          const SizedBox(height: AppSpacing.smMd),
          Text(
            'Giriş yapmadan da uygulamanın tamamını kullanmaya devam edebilirsin; veriler şimdilik yalnızca bu cihazda kalır.',
            style: AppTypography.bodySm.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '•',
            style: AppTypography.bodyMd.copyWith(
              color: scheme.primaryContainer,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyMd.copyWith(color: scheme.onSurface),
          ),
        ),
      ],
    );
  }
}

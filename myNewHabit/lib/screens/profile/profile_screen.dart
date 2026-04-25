// Sprint 1: Profile screen placeholder
// Sprint 5'te Minimal MVP profil içeriği eklenecek.

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/empty_state_widget.dart';

/// Profil ekranı — Sprint 5'te tam implemente edilecek.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'Profil',
          style: AppTypography.headlineSm,
        ),
      ),
      body: const EmptyStateWidget(
        emoji: '👤',
        message:
            'Profil istatistikleri\n(Toplam alışkanlık, en uzun seri, günlük tamamlanma)\nSprint 5\'te burada olacak!',
      ),
    );
  }
}

// Sprint 1: Home screen placeholder
// Sprint 3'te tam implement edilecek; şimdi altyapı var, içerik boş.

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/empty_state_widget.dart';

/// Ana sayfa ekranı — Sprint 3'te tam implemente edilecek.
///
/// Sprint 1'de sadece iskelet yapıyı doğrular.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(child: _HomeBody()),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

// Not: _NotificationIconButton artık kullanılmıyor, istendiğinde Home ekranı body'sine veya profil sayfasına eklenebilir.

// ─────────────────────────────────────────────────────────────────────────────

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      emoji: '🌊',
      message:
          'Takvim ve alışkanlık listesi\nSprint 3\'te burada olacak!\n\nŞimdilik navigasyonu test edebilirsin.',
      ctaLabel: 'Kayıt Ekle (Sprint 2)',
    );
  }
}

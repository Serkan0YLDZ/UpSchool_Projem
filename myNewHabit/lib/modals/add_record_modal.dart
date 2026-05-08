// Sprint 5: Modal — Adım 1: "Ne Eklemek İstersin?" tip seçimi (Neo-Brutalism)

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../data/models/record_model.dart';

/// Ekleme akışının 1. adımı: kullanıcı kayıt tipini seçer.
///
/// Seçim yapılınca [onTypeSelected] callback'i tetiklenir;
/// ekranı kapatan ve bir sonraki sheet'i açan mantık çağıran taraftadır (SRP).
Future<void> showAddRecordModal(
  BuildContext context, {
  required void Function(RecordType type) onTypeSelected,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _AddRecordSheet(onTypeSelected: onTypeSelected),
  );
}

class _AddRecordSheet extends StatelessWidget {
  final void Function(RecordType type) onTypeSelected;

  const _AddRecordSheet({required this.onTypeSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.marginMobile,
        AppSpacing.md,
        AppSpacing.marginMobile,
        AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _DragHandle(),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Ne Eklemek İstersin?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.brutalistBlack,
              ),
            ),
            const SizedBox(height: AppSpacing.cardPadding),
            _TypeTile(
              icon: Icons.calendar_today_rounded,
              label: 'TAKVİME\nEKLE',
              subtitle: 'Etkinlik veya randevunu kaydet',
              backgroundColor: const Color(0xFFC4EDF8), // Takvim blue
              onTap: () => onTypeSelected(RecordType.event),
            ),
            const SizedBox(height: AppSpacing.md),
            _TypeTile(
              icon: Icons.star_border_rounded,
              label: 'ALIŞKANLIK\nEKLE',
              subtitle: 'Günlük rutinini şekillendir',
              backgroundColor: const Color(0xFFFDE074), // Habit yellow
              onTap: () => onTypeSelected(RecordType.habit),
            ),
            const SizedBox(height: AppSpacing.md),
            _TypeTile(
              icon: Icons.check_box_outlined,
              label: 'YAPILACAK\nEKLE',
              subtitle: 'Hızlı görev oluştur',
              backgroundColor: const Color(0xFFD0BCFF), // Todo purple
              onTap: () => onTypeSelected(RecordType.todo),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 48,
        height: 6,
        decoration: BoxDecoration(
          color: AppColors.outlineVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
      ),
    );
  }
}

class _TypeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _TypeTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: AppColors.brutalistBlack, width: 4),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: AppColors.brutalistBlack,
              offset: Offset(6, 6),
              blurRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.brutalistWhite,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.brutalistBlack, width: 4),
              ),
              child: Icon(icon, size: 32, color: AppColors.brutalistBlack),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.brutalistBlack,
                height: 1.2,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

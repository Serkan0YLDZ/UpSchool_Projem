// Sprint 2: Modal — Adım 1: "Ne Eklemek İstersin?" tip seçimi

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
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.marginMobile,
        AppSpacing.sm,
        AppSpacing.marginMobile,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _DragHandle(),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Ne Eklemek İstersin?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.cardPadding),
          _TypeTile(
            icon: '🔄',
            label: 'Yeni Alışkanlık',
            subtitle: 'Her gün tekrarlayan rutinler',
            onTap: () => onTypeSelected(RecordType.habit),
          ),
          const SizedBox(height: AppSpacing.sm),
          _TypeTile(
            icon: '📅',
            label: 'Takvime Ekle',
            subtitle: 'Belirli tarihe bağlı tek seferlik işler',
            onTap: () => onTypeSelected(RecordType.event),
          ),
          const SizedBox(height: AppSpacing.sm),
          _TypeTile(
            icon: '☑️',
            label: 'Yapılacak Ekle',
            subtitle: 'Bitiş tarihi olan yapılacaklar listesi',
            onTap: () => onTypeSelected(RecordType.todo),
          ),
        ],
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
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
      ),
    );
  }
}

class _TypeTile extends StatelessWidget {
  final String icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _TypeTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.smMd,
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

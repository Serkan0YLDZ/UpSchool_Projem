// Sprint 3: Ana Sayfa & Takvim — FilterChipBar (US-308)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../providers/record_provider.dart';

/// Yatay kaydırılabilir filtre chip satırı.
///
/// Aktif filtre vurgulanır; aynı chip'e tekrar basılırsa "all"'a döner.
class FilterChipBar extends StatelessWidget {
  const FilterChipBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordProvider>(
      builder: (context, provider, _) {
        return _ChipRow(activeFilter: provider.activeFilter);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.activeFilter});

  final FilterType activeFilter;

  static const _filters = [
    (FilterType.mostImportant, '⭐ En Önemli'),
    (FilterType.earliest, '⏰ En Erken'),
    (FilterType.thisWeek, '📅 Bu Hafta'),
    (FilterType.thisMonth, '🗓 Bu Ay'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: _filters.map((entry) {
          final (type, label) = entry;
          final isActive = activeFilter == type;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: _FilterItem(type: type, label: label, isActive: isActive),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _FilterItem extends StatelessWidget {
  const _FilterItem({
    required this.type,
    required this.label,
    required this.isActive,
  });

  final FilterType type;
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isActive,
      onSelected: (_) => context.read<RecordProvider>().applyFilter(type),
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isActive ? Colors.white : AppColors.onSurfaceVariant,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
      backgroundColor: AppColors.surfaceContainerLow,
      side: BorderSide(
        color: isActive ? AppColors.primary : AppColors.outlineVariant,
        width: 1,
      ),
      shape: const StadiumBorder(),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/track_custom_colors.dart';
import '../../../providers/record_provider.dart';

/// Yatay kaydırılabilir filtre chip satırı.
class FilterChipBar extends StatelessWidget {
  const FilterChipBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordProvider>(
      builder: (context, provider, _) =>
          _ChipRow(activeFilters: provider.activeFilters),
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.activeFilters});

  final Set<FilterType> activeFilters;

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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: _filters.map((entry) {
          final (type, label) = entry;
          final isActive = activeFilters.contains(type);
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: _FilterItem(type: type, label: label, isActive: isActive),
          );
        }).toList(),
      ),
    );
  }
}

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
    final scheme = context.scheme;
    final track = context.track;
    final ink = track.brutalistInk;

    return GestureDetector(
      onTap: () => context.read<RecordProvider>().toggleFilter(type),
      child: Transform.translate(
        offset: isActive ? const Offset(2, 2) : Offset.zero,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? scheme.primaryContainer : track.brutalistSurface,
            border: Border.all(color: ink, width: 3),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? []
                : [BoxShadow(color: ink, offset: const Offset(4, 4))],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: isActive ? scheme.onPrimary : ink,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

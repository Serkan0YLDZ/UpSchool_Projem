import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../providers/record_provider.dart';

/// Yapılacaklar bölümü filtre butonu (Ana sayfa ve odak ekranında ortak).
class TodoFilterButton extends StatelessWidget {
  const TodoFilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordProvider>(
      builder: (context, provider, _) {
        return GestureDetector(
          onTap: () => _showFilterSheet(context, provider),
          child: Transform.rotate(
            angle: -2.0 * 3.1415 / 180,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.brutalistWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.brutalistBlack, width: 4.0),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.brutalistBlack,
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.filter_list_rounded,
                size: 24,
                color: AppColors.brutalistBlack,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFilterSheet(BuildContext context, RecordProvider initialProvider) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Consumer<RecordProvider>(
        builder: (consumerCtx, provider, _) => Container(
          decoration: const BoxDecoration(
            color: AppColors.brutalistWhite,
            border: Border(
              top: BorderSide(color: AppColors.brutalistBlack, width: 4),
              left: BorderSide(color: AppColors.brutalistBlack, width: 4),
              right: BorderSide(color: AppColors.brutalistBlack, width: 4),
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'YAPILACAKLARI FİLTRELE',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.brutalistBlack,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Text(
                      'DURUM',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppColors.brutalistBlack,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TodoFilterOption(
                      label: 'Yapılanlar',
                      icon: Icons.check_circle_outline,
                      isSelected: provider.activeFilters.contains(
                        FilterType.todoDone,
                      ),
                      onTap: () => provider.toggleFilter(FilterType.todoDone),
                    ),
                    TodoFilterOption(
                      label: 'Yapılacaklar',
                      icon: Icons.pending_actions,
                      isSelected: provider.activeFilters.contains(
                        FilterType.todoTodo,
                      ),
                      onTap: () => provider.toggleFilter(FilterType.todoTodo),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Text(
                      'SIRALAMA',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppColors.brutalistBlack,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TodoFilterOption(
                      label: 'En Önemli',
                      icon: Icons.star_border_rounded,
                      isSelected: provider.activeFilters.contains(
                        FilterType.mostImportant,
                      ),
                      onTap: () =>
                          provider.toggleFilter(FilterType.mostImportant),
                    ),
                    TodoFilterOption(
                      label: 'En Yakın Bitiş Tarihi',
                      icon: Icons.access_time_rounded,
                      isSelected: provider.activeFilters.contains(
                        FilterType.earliest,
                      ),
                      onTap: () => provider.toggleFilter(FilterType.earliest),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Text(
                      'ZAMAN ARALIĞI',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppColors.brutalistBlack,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TodoFilterOption(
                      label: 'Bu Hafta',
                      icon: Icons.calendar_view_week_rounded,
                      isSelected: provider.activeFilters.contains(
                        FilterType.thisWeek,
                      ),
                      onTap: () => provider.toggleFilter(FilterType.thisWeek),
                    ),
                    TodoFilterOption(
                      label: 'Bu Ay',
                      icon: Icons.calendar_month_rounded,
                      isSelected: provider.activeFilters.contains(
                        FilterType.thisMonth,
                      ),
                      onTap: () => provider.toggleFilter(FilterType.thisMonth),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TodoFilterOption extends StatelessWidget {
  const TodoFilterOption({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.translate(
        offset: isSelected ? const Offset(2, 2) : Offset.zero,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.sectionBannerPurple
                : AppColors.brutalistWhite,
            border: Border.all(color: AppColors.brutalistBlack, width: 3),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? const []
                : const [
                    BoxShadow(
                      color: AppColors.brutalistBlack,
                      offset: Offset(4, 4),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? AppColors.onPrimary : AppColors.brutalistBlack,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected ? AppColors.onPrimary : AppColors.brutalistBlack,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_rounded, color: AppColors.onPrimary, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

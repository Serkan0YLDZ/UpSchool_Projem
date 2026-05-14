import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/track_custom_colors.dart';
import '../../../providers/record_provider.dart';

class TodoFilterButton extends StatelessWidget {
  const TodoFilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordProvider>(
      builder: (context, provider, _) {
        final track = context.track;
        final ink = track.brutalistInk;

        return GestureDetector(
          onTap: () => _showFilterSheet(context, provider),
          child: Transform.rotate(
            angle: -2.0 * 3.1415 / 180,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: track.brutalistSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ink, width: 4.0),
                boxShadow: [
                  BoxShadow(color: ink, offset: const Offset(4, 4)),
                ],
              ),
              child: Icon(Icons.filter_list_rounded, size: 24, color: ink),
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
        builder: (consumerCtx, provider, _) {
          final track = consumerCtx.track;
          final ink = track.brutalistInk;

          return Container(
            decoration: BoxDecoration(
              color: track.brutalistSurface,
              border: Border(
                top: BorderSide(color: ink, width: 4),
                left: BorderSide(color: ink, width: 4),
                right: BorderSide(color: ink, width: 4),
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'YAPILACAKLARI FİLTRELE',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: ink,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _SectionLabel('DURUM', ink: ink),
                      const SizedBox(height: AppSpacing.sm),
                      TodoFilterOption(
                        label: 'Yapılanlar',
                        icon: Icons.check_circle_outline,
                        isSelected: provider.activeFilters
                            .contains(FilterType.todoDone),
                        onTap: () => provider.toggleFilter(FilterType.todoDone),
                        ink: ink,
                      ),
                      TodoFilterOption(
                        label: 'Yapılacaklar',
                        icon: Icons.pending_actions,
                        isSelected: provider.activeFilters
                            .contains(FilterType.todoTodo),
                        onTap: () => provider.toggleFilter(FilterType.todoTodo),
                        ink: ink,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _SectionLabel('SIRALAMA', ink: ink),
                      const SizedBox(height: AppSpacing.sm),
                      TodoFilterOption(
                        label: 'En Önemli',
                        icon: Icons.star_border_rounded,
                        isSelected: provider.activeFilters
                            .contains(FilterType.mostImportant),
                        onTap: () =>
                            provider.toggleFilter(FilterType.mostImportant),
                        ink: ink,
                      ),
                      TodoFilterOption(
                        label: 'En Yakın Bitiş Tarihi',
                        icon: Icons.access_time_rounded,
                        isSelected: provider.activeFilters
                            .contains(FilterType.earliest),
                        onTap: () => provider.toggleFilter(FilterType.earliest),
                        ink: ink,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _SectionLabel('ZAMAN ARALIĞI', ink: ink),
                      const SizedBox(height: AppSpacing.sm),
                      TodoFilterOption(
                        label: 'Bu Hafta',
                        icon: Icons.calendar_view_week_rounded,
                        isSelected: provider.activeFilters
                            .contains(FilterType.thisWeek),
                        onTap: () => provider.toggleFilter(FilterType.thisWeek),
                        ink: ink,
                      ),
                      TodoFilterOption(
                        label: 'Bu Ay',
                        icon: Icons.calendar_month_rounded,
                        isSelected: provider.activeFilters
                            .contains(FilterType.thisMonth),
                        onTap: () => provider.toggleFilter(FilterType.thisMonth),
                        ink: ink,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {required this.ink});
  final String text;
  final Color ink;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: ink,
          letterSpacing: 1.0,
        ),
      );
}

class TodoFilterOption extends StatelessWidget {
  const TodoFilterOption({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.ink,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final track = context.track;

    return GestureDetector(
      onTap: onTap,
      child: Transform.translate(
        offset: isSelected ? const Offset(2, 2) : Offset.zero,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.homeSectionTodosOrange : track.brutalistSurface,
            border: Border.all(color: ink, width: 3),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? []
                : [BoxShadow(color: ink, offset: const Offset(4, 4))],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? scheme.onPrimary : ink,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected ? scheme.onPrimary : ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_rounded, color: scheme.onPrimary, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

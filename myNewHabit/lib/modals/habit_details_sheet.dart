// Sprint 2: Modal — Alışkanlık Detayları (gün seçici + önem derecesi)

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Alışkanlık ekleme akışının son adımı: gün seçimi.
Future<({List<String> repeatDays, int? intervalDays})?> showHabitDetailsSheet(
  BuildContext context, {
  List<String> initialRepeatDays = const [],
  int? initialIntervalDays,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _HabitDetailsSheet(
      initialRepeatDays: initialRepeatDays,
      initialIntervalDays: initialIntervalDays,
    ),
  );
}

class _HabitDetailsSheet extends StatefulWidget {
  final List<String> initialRepeatDays;
  final int? initialIntervalDays;

  const _HabitDetailsSheet({
    required this.initialRepeatDays,
    this.initialIntervalDays,
  });

  @override
  State<_HabitDetailsSheet> createState() => _HabitDetailsSheetState();
}

class _HabitDetailsSheetState extends State<_HabitDetailsSheet> {
  late Set<String> _selectedDays;
  int? _intervalDays;

  @override
  void initState() {
    super.initState();
    _selectedDays = widget.initialRepeatDays.toSet();
    _intervalDays = widget.initialIntervalDays;
  }

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
        AppSpacing.cardPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: _DragHandle()),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Alışkanlık Detayları',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceContainerLow,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Tekrar Sıklığı',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.smMd),
          _DaySelector(
            selectedDays: _selectedDays,
            onToggle: (code) => setState(() {
              if (_selectedDays.contains(code)) {
                _selectedDays.remove(code);
              } else {
                _selectedDays.add(code);
                _intervalDays =
                    null; // Gün seçildiğinde aralık sıfırlanır (XOR)
              }
            }),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Veya "X" günde bir tekrarla',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.smMd),
          _IntervalSelector(
            value: _intervalDays,
            onChanged: (val) {
              setState(() {
                _intervalDays = val;
                if (val != null) {
                  _selectedDays
                      .clear(); // Aralık seçildiğinde günler sıfırlanır (XOR)
                }
              });
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeight,
            child: ElevatedButton.icon(
              onPressed: _isValid ? _onSave : null,
              icon: const Icon(Icons.check_rounded),
              label: const Text('Kaydet'),
            ),
          ),
        ],
      ),
    );
  }

  // Hem gün boş, hem aralık boşsa geçersiz
  bool get _isValid => _selectedDays.isNotEmpty || _intervalDays != null;

  void _onSave() {
    Navigator.of(
      context,
    ).pop((repeatDays: _selectedDays.toList(), intervalDays: _intervalDays));
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
    );
  }
}

class _DaySelector extends StatelessWidget {
  static const _days = ['PZT', 'SAL', 'ÇAR', 'PER', 'CUM', 'CTS', 'PAZ'];
  static const _codes = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  final Set<String> selectedDays;
  final void Function(String code) onToggle;

  const _DaySelector({required this.selectedDays, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_days.length, (i) {
        final isSelected = selectedDays.contains(_codes[i]);
        return _DayChip(
          label: _days[i],
          isSelected: isSelected,
          onTap: () => onToggle(_codes[i]),
        );
      }),
    );
  }
}

class _DayChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: isSelected
              ? null
              : Border.all(color: AppColors.outlineVariant),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isSelected
                ? AppColors.onPrimaryContainer
                : AppColors.outline,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _IntervalSelector extends StatelessWidget {
  final int? value;
  final ValueChanged<int?> onChanged;

  const _IntervalSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: value != null ? AppColors.tertiary : Colors.transparent,
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value == null ? 'Seçilmedi' : '$value günde bir tekrarla',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: value == null
                    ? AppColors.onSurfaceVariant
                    : AppColors.onSurface,
                fontWeight: value == null ? FontWeight.normal : FontWeight.w600,
              ),
            ),
            Icon(
              Icons.unfold_more_rounded,
              color: value != null
                  ? AppColors.tertiary
                  : AppColors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5, // Ekranın yarısı
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusXl),
            ),
          ),
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Tekrar Sıklığı',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: ListView.builder(
                  itemCount: 31,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final isSelected = value == null;
                      return ListTile(
                        title: Text(
                          'Seçilmedi',
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.tertiary
                                : AppColors.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: const Text('Haftanın günleri ile devam et'),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_rounded,
                                color: AppColors.tertiary,
                              )
                            : null,
                        onTap: () {
                          onChanged(null);
                          Navigator.pop(ctx);
                        },
                      );
                    }
                    final val = index;
                    final isSelected = value == val;
                    return ListTile(
                      title: Text(
                        '$val günde bir tekrarla',
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.tertiary
                              : AppColors.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              color: AppColors.tertiary,
                            )
                          : null,
                      onTap: () {
                        onChanged(val);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

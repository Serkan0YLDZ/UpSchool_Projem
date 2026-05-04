// Sprint 2: Modal — Görev Detayları (Bitiş Tarihi + Öncelik)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../data/models/record_model.dart';

/// Görev ekleme akışının son adımı: opsiyonel bitiş tarihi ve önem derecesi.
Future<({DateTime? dueDate, Priority priority})?> showTodoDetailsSheet(
  BuildContext context, {
  DateTime? initialDueDate,
  Priority initialPriority = Priority.medium,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _TodoDetailsSheet(
      initialDueDate: initialDueDate,
      initialPriority: initialPriority,
    ),
  );
}

class _TodoDetailsSheet extends StatefulWidget {
  final DateTime? initialDueDate;
  final Priority initialPriority;

  const _TodoDetailsSheet({this.initialDueDate, required this.initialPriority});

  @override
  State<_TodoDetailsSheet> createState() => _TodoDetailsSheetState();
}

class _TodoDetailsSheetState extends State<_TodoDetailsSheet> {
  DateTime? _dueDate;
  late Priority _priority;
  bool _showDueDate = false;

  @override
  void initState() {
    super.initState();
    _dueDate = widget.initialDueDate;
    _showDueDate = _dueDate != null;
    _priority = widget.initialPriority;
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
        AppSpacing.cardPadding,
        AppSpacing.sm,
        AppSpacing.cardPadding,
        AppSpacing.marginMobile,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: _DragHandle()),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Görev Detayları',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.md),

          Text(
            'Önem Derecesi',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.smMd),
          _PrioritySelector(
            currentPriority: _priority,
            onChanged: (p) => setState(() => _priority = p),
          ),
          const SizedBox(height: AppSpacing.md),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bitiş Tarihi (Opsiyonel)',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Switch(
                value: _showDueDate,
                onChanged: _toggleDueDate,
                activeThumbColor: AppColors.tertiary,
              ),
            ],
          ),
          if (_showDueDate) ...[
            const SizedBox(height: AppSpacing.smMd),
            _DateSelector(
              date: _dueDate ?? DateTime.now(),
              onDateTap: _pickDueDate,
            ),
          ],

          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeight,
            child: ElevatedButton(
              onPressed: _onSave,
              child: const Text('Oluştur'),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleDueDate(bool value) {
    setState(() {
      _showDueDate = value;
      if (!value) {
        _dueDate = null;
      } else {
        _dueDate = DateTime.now();
      }
    });
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _onSave() {
    Navigator.of(context).pop((dueDate: _dueDate, priority: _priority));
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

class _DateSelector extends StatelessWidget {
  final DateTime date;
  final VoidCallback onDateTap;

  const _DateSelector({required this.date, required this.onDateTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDateTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_rounded,
              color: AppColors.tertiary,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.smMd),
            Expanded(
              child: Text(
                DateFormat('d MMM yyyy', 'tr').format(date),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrioritySelector extends StatelessWidget {
  final Priority currentPriority;
  final ValueChanged<Priority> onChanged;

  const _PrioritySelector({
    required this.currentPriority,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: Priority.values.map((priority) {
        final isSelected = priority == currentPriority;
        final String label;
        final Color activeColor;

        switch (priority) {
          case Priority.high:
            label = 'Yüksek';
            activeColor = AppColors.error;
            break;
          case Priority.medium:
            label = 'Orta';
            activeColor = AppColors.streakFire;
            break;
          case Priority.low:
            label = 'Düşük';
            activeColor = AppColors.onSurfaceVariant;
            break;
        }

        final bgColor = isSelected
            ? activeColor.withAlpha(26)
            : AppColors.surfaceContainerLow;
        final textColor = isSelected ? activeColor : AppColors.onSurfaceVariant;
        final borderColor = isSelected
            ? activeColor.withAlpha(50)
            : AppColors.surfaceContainerHigh;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InkWell(
              onTap: () => onChanged(priority),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: borderColor),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// Sprint 2: Modal — Takvime Ekle Zamanlaması (Tarih + Saat ve Opsiyonel Bitiş)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Görev ekleme akışının son adımı: başlangıç tarihi/saati ve bitiş tarihi/saati.
Future<({DateTime startDate, String startTime, DateTime? endDate})?> showTaskTimingSheet(
  BuildContext context, {
  DateTime? initialStartDate,
  String? initialStartTime,
  DateTime? initialEndDate,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _TaskTimingSheet(
      initialStartDate: initialStartDate,
      initialStartTime: initialStartTime,
      initialEndDate: initialEndDate,
    ),
  );
}

class _TaskTimingSheet extends StatefulWidget {
  final DateTime? initialStartDate;
  final String? initialStartTime;
  final DateTime? initialEndDate;

  const _TaskTimingSheet({
    this.initialStartDate,
    this.initialStartTime,
    this.initialEndDate,
  });

  @override
  State<_TaskTimingSheet> createState() => _TaskTimingSheetState();
}

class _TaskTimingSheetState extends State<_TaskTimingSheet> {
  late DateTime _startDate;
  late TimeOfDay _startTime;

  DateTime? _endDate;
  TimeOfDay? _endTime;

  bool _showEndDate = false;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate ?? DateTime.now();
    
    if (widget.initialStartTime != null) {
      final parts = widget.initialStartTime!.split(':');
      _startTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } else {
      _startTime = TimeOfDay.now();
    }

    _endDate = widget.initialEndDate;
    if (_endDate != null) {
      _endTime = TimeOfDay.fromDateTime(_endDate!);
    }
    _showEndDate = _endDate != null;
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
          Text('Zamanlama', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Başlangıç',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.smMd),
          _DateTimeSelector(
            date: _startDate,
            time: _startTime,
            onDateTap: _pickStartDate,
            onTimeTap: _pickStartTime,
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
                value: _showEndDate,
                onChanged: _toggleEndDate,
                activeColor: AppColors.tertiary,
              ),
            ],
          ),
          if (_showEndDate) ...[
            const SizedBox(height: AppSpacing.smMd),
            _DateTimeSelector(
              date: _endDate ?? DateTime.now(),
              time: _endTime ?? const TimeOfDay(hour: 23, minute: 59),
              onDateTap: _pickEndDate,
              onTimeTap: _pickEndTime,
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

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        // Eğer bitiş tarihi varsa ve başlangıç tarihinden önceyse, bitişi temizle
        if (_endDate != null && _endDate!.isBefore(_startDate)) {
          _endDate = null;
          _showEndDate = false;
        }
      });
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  void _toggleEndDate(bool value) {
    setState(() {
      _showEndDate = value;
      if (!value) {
        _endDate = null;
        _endTime = null;
      } else {
        _endDate = _startDate;
        _endTime = const TimeOfDay(hour: 23, minute: 59);
      }
    });
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? const TimeOfDay(hour: 23, minute: 59),
    );
    if (picked != null) setState(() => _endTime = picked);
  }

  void _onSave() {
    final startT = '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}';
    
    DateTime? finalEndDate;
    if (_showEndDate && _endDate != null && _endTime != null) {
      finalEndDate = DateTime(
        _endDate!.year,
        _endDate!.month,
        _endDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );
    }

    Navigator.of(context).pop((
      startDate: _startDate,
      startTime: startT,
      endDate: finalEndDate,
    ));
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

class _DateTimeSelector extends StatelessWidget {
  final DateTime date;
  final TimeOfDay time;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;

  const _DateTimeSelector({
    required this.date,
    required this.time,
    required this.onDateTap,
    required this.onTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: GestureDetector(
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
                  const Icon(Icons.calendar_month_rounded, color: AppColors.tertiary, size: 20),
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
          ),
        ),
        const SizedBox(width: AppSpacing.smMd),
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: onTimeTap,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time_rounded, color: AppColors.tertiary, size: 20),
                  const SizedBox(width: AppSpacing.smMd),
                  Text(
                    '$h:$m',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

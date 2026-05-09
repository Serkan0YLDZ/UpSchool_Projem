// Sprint 5: Modal — Görev Detayları (Bitiş Tarihi + Öncelik) (Neo-Brutalism)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../data/models/record_model.dart';

/// Görev ekleme akışının son adımı: bitiş tarihi/saati ve önem derecesi.
Future<({DateTime? dueDate, Priority priority, bool goBack})?> showTodoDetailsSheet(
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
  TimeOfDay? _dueTime;
  late Priority _priority;

  @override
  void initState() {
    super.initState();
    _dueDate = widget.initialDueDate;
    if (_dueDate != null) {
      _dueTime = TimeOfDay.fromDateTime(_dueDate!);
    }
    _priority = widget.initialPriority;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    const bgColor = Color(0xFFF8FBFF);
    const yellowTitleBg = Color(0xFFFFE599);
    const blueBtnBg = Color(0xFF0077B6);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: const BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(top: BorderSide(color: AppColors.brutalistBlack, width: 4)),
        ),
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          24 + bottomPadding,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context, (dueDate: null, priority: _priority, goBack: true)),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.brutalistWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.brutalistBlack, width: 2),
                        boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(3, 3))],
                      ),
                      child: const Icon(Icons.arrow_back, color: AppColors.brutalistBlack),
                    ),
                  ),
                  // Progress indicator (Step 3)
                  Row(
                    children: [
                      Container(
                        width: 12, height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.brutalistWhite,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.brutalistBlack, width: 2),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 12, height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.brutalistWhite,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.brutalistBlack, width: 2),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Transform.rotate(
                        angle: -0.05,
                        child: Container(
                          width: 20, height: 12,
                          decoration: BoxDecoration(
                            color: blueBtnBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.brutalistBlack, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Title Card
              Transform.rotate(
                angle: -0.02,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: yellowTitleBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.brutalistBlack, width: 3),
                    boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(4, 4))],
                  ),
                  child: const Text(
                    'YAPILACAK ŞEYİN\nDETAYLARI',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.brutalistBlack,
                      height: 1.2,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Priority Selection
              Transform.rotate(
                angle: -0.01,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.brutalistWhite,
                    border: Border.all(color: AppColors.brutalistBlack, width: 4),
                    boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(6, 6))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Önem Derecesi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.brutalistBlack,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _PriorityButton(
                              label: '🟢 Düşük',
                              isSelected: _priority == Priority.low,
                              onTap: () => setState(() => _priority = Priority.low),
                              activeColor: const Color(0xFFBBF7D0), // green-200
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _PriorityButton(
                              label: '🟡 Orta',
                              isSelected: _priority == Priority.medium,
                              onTap: () => setState(() => _priority = Priority.medium),
                              activeColor: const Color(0xFFFEF08A), // yellow-200
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _PriorityButton(
                              label: '🔴 Yüksek',
                              isSelected: _priority == Priority.high,
                              onTap: () => setState(() => _priority = Priority.high),
                              activeColor: const Color(0xFFFECACA), // red-200
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Time Section
              Transform.rotate(
                angle: 0.02,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.brutalistWhite,
                    border: Border.all(color: AppColors.brutalistBlack, width: 4),
                    boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(6, 6))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Zaman',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.brutalistBlack,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DateTimeSelector(
                        date: _dueDate,
                        time: _dueTime,
                        onDateTap: _pickDueDate,
                        onTimeTap: _pickDueTime,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Create Button
              Transform.rotate(
                angle: 0.01,
                child: GestureDetector(
                  onTap: _onSave,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: blueBtnBg,
                      border: Border.all(color: AppColors.brutalistBlack, width: 4),
                      boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(6, 6))],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'OLUŞTUR',
                          style: TextStyle(
                            color: AppColors.brutalistWhite,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: AppColors.brutalistWhite, size: 28),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
        if (_dueTime == null) {
          _dueTime = TimeOfDay.now();
        }
      });
    }
  }

  Future<void> _pickDueTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _dueTime = picked;
        if (_dueDate == null) {
          _dueDate = DateTime.now();
        }
      });
    }
  }

  void _onSave() {
    DateTime? finalDueDate;
    if (_dueDate != null) {
      finalDueDate = DateTime(
        _dueDate!.year,
        _dueDate!.month,
        _dueDate!.day,
        _dueTime?.hour ?? 0,
        _dueTime?.minute ?? 0,
      );
    }
    Navigator.of(context).pop((dueDate: finalDueDate, priority: _priority, goBack: false));
  }
}

class _PriorityButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;

  const _PriorityButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.translate(
        offset: isSelected ? const Offset(0, -4) : Offset.zero,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : AppColors.brutalistWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.brutalistBlack, width: 3),
            boxShadow: isSelected 
                ? const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(4, 4))]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.brutalistBlack,
            ),
          ),
        ),
      ),
    );
  }
}

class _DateTimeSelector extends StatelessWidget {
  final DateTime? date;
  final TimeOfDay? time;
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
    final dateStr = date != null ? DateFormat('d MMM yyyy', 'tr').format(date!) : 'Tarih Seç';
    final h = time?.hour.toString().padLeft(2, '0') ?? '--';
    final m = time?.minute.toString().padLeft(2, '0') ?? '--';

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: GestureDetector(
            onTap: onDateTap,
            child: Transform.rotate(
              angle: -0.01,
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.brutalistWhite,
                  border: Border.all(color: AppColors.brutalistBlack, width: 3),
                  boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(3, 3))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: date != null ? AppColors.brutalistBlack : Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today,
                      color: AppColors.brutalistBlack,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: onTimeTap,
            child: Transform.rotate(
              angle: 0.01,
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.brutalistWhite,
                  border: Border.all(color: AppColors.brutalistBlack, width: 3),
                  boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(3, 3))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$h:$m',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: time != null ? AppColors.brutalistBlack : Colors.grey,
                      ),
                    ),
                    const Icon(
                      Icons.access_time_filled,
                      color: AppColors.brutalistBlack,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

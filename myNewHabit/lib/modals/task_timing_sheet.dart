// Sprint 2: Modal — Takvime Ekle Zamanlaması (Tarih + Saat ve Opsiyonel Bitiş)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Görev ekleme akışının son adımı: başlangıç tarihi/saati ve bitiş tarihi/saati.
Future<({DateTime startDate, String startTime, DateTime? endDate, bool goBack})?>
showTaskTimingSheet(
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
                    onTap: () => Navigator.pop(context, (startDate: _startDate, startTime: '', endDate: null, goBack: true)),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ZAMANLAMA',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.brutalistBlack,
                          height: 1.2,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Projenizin ne zaman başlayıp biteceğini seçin.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brutalistBlack,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Start Date Section
              Transform.rotate(
                angle: -0.01,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1E9FF),
                    border: Border.all(color: AppColors.brutalistBlack, width: 4),
                    boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(6, 6))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Başlangıç',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.brutalistBlack,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DateTimeSelector(
                        date: _startDate,
                        time: _startTime,
                        onDateTap: _pickStartDate,
                        onTimeTap: _pickStartTime,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // End Date Toggle Row
              Transform.rotate(
                angle: -0.01,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.brutalistWhite,
                    border: Border.all(color: AppColors.brutalistBlack, width: 4),
                    boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(6, 6))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bitiş Tarihi',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.brutalistBlack,
                            ),
                          ),
                          Text(
                            '(İsteğe Bağlı)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _toggleEndDate(!_showEndDate),
                        child: Container(
                          width: 56,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.brutalistWhite,
                            border: Border.all(color: AppColors.brutalistBlack, width: 2),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Align(
                            alignment: _showEndDate ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: _showEndDate ? blueBtnBg : Colors.grey,
                                border: Border.all(color: AppColors.brutalistBlack, width: 2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              if (_showEndDate) ...[
                const SizedBox(height: 24),
                Transform.rotate(
                  angle: 0.01,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1E9FF),
                      border: Border.all(color: AppColors.brutalistBlack, width: 4),
                      boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(6, 6))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bitiş',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.brutalistBlack,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _DateTimeSelector(
                          date: _endDate ?? DateTime.now(),
                          time: _endTime ?? const TimeOfDay(hour: 23, minute: 59),
                          onDateTap: _pickEndDate,
                          onTimeTap: _pickEndTime,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              
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
    final startT =
        '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}';

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

    Navigator.of(
      context,
    ).pop((startDate: _startDate, startTime: startT, endDate: finalEndDate, goBack: false));
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
                        DateFormat('d MMM yyyy', 'tr').format(date),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brutalistBlack,
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brutalistBlack,
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

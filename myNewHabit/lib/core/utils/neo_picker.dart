import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

/// %100 Özel Neo-Brutalist Tarih Seçici
Future<DateTime?> showNeoDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  return showGeneralDialog<DateTime>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Kapat',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, anim1, anim2) {
      return _NeoDatePickerDialog(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return Transform.scale(
        scale: anim1.value,
        child: Opacity(
          opacity: anim1.value,
          child: child,
        ),
      );
    },
  );
}

/// %100 Özel Neo-Brutalist Saat Seçici
Future<TimeOfDay?> showNeoTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) {
  return showGeneralDialog<TimeOfDay>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Kapat',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, anim1, anim2) {
      return _NeoTimePickerDialog(
        initialTime: initialTime,
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return Transform.scale(
        scale: anim1.value,
        child: Opacity(
          opacity: anim1.value,
          child: child,
        ),
      );
    },
  );
}

class _NeoDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const _NeoDatePickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_NeoDatePickerDialog> createState() => _NeoDatePickerDialogState();
}

class _NeoDatePickerDialogState extends State<_NeoDatePickerDialog> {
  late DateTime _selectedDate;
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _focusedMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    const yellowBg = Color(0xFFFFE599);
    final daysInMonth = DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final firstDayOffset = DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday - 1; // 0 = Mon, 6 = Sun

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Transform.rotate(
        angle: -0.01,
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: yellowBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.brutalistBlack, width: 4),
            boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(6, 6))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NeoIconButton(icon: Icons.chevron_left, onTap: _previousMonth),
                  Text(
                    DateFormat('MMMM yyyy', 'tr').format(_focusedMonth).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.brutalistBlack,
                      letterSpacing: 1.0,
                    ),
                  ),
                  _NeoIconButton(icon: Icons.chevron_right, onTap: _nextMonth),
                ],
              ),
              const SizedBox(height: 32),

              // WEEKDAYS
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz']
                    .map((d) => Expanded(
                          child: Text(
                            d,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.brutalistBlack),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),

              // GRID
              GridView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: daysInMonth + firstDayOffset,
                itemBuilder: (context, index) {
                  if (index < firstDayOffset) return const SizedBox();
                  final day = index - firstDayOffset + 1;
                  final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
                  final isSelected = date.year == _selectedDate.year &&
                      date.month == _selectedDate.month &&
                      date.day == _selectedDate.day;
                  final isToday = date.year == DateTime.now().year &&
                      date.month == DateTime.now().month &&
                      date.day == DateTime.now().day;
                  final isOutOfRange = date.isBefore(widget.firstDate) || date.isAfter(widget.lastDate);

                  return GestureDetector(
                    onTap: isOutOfRange
                        ? null
                        : () {
                            setState(() => _selectedDate = date);
                          },
                    child: Transform.rotate(
                      angle: isSelected ? -0.05 : 0.0,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? AppColors.primaryContainer 
                              : isOutOfRange 
                                  ? Colors.transparent 
                                  : AppColors.brutalistWhite,
                          border: Border.all(
                            color: isOutOfRange ? Colors.grey : AppColors.brutalistBlack,
                            width: isSelected || isToday ? 3 : 2,
                          ),
                          boxShadow: isSelected 
                              ? const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(2, 2))]
                              : [],
                        ),
                        child: Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: isOutOfRange 
                                ? Colors.grey 
                                : (isSelected ? AppColors.brutalistWhite : AppColors.brutalistBlack),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // BOTTOM BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _NeoTextButton(
                    text: 'İPTAL',
                    color: Colors.grey.shade300,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  _NeoTextButton(
                    text: 'SEÇ',
                    color: const Color(0xFF93C5FD), // blue-300
                    onTap: () => Navigator.pop(context, _selectedDate),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NeoTimePickerDialog extends StatefulWidget {
  final TimeOfDay initialTime;

  const _NeoTimePickerDialog({required this.initialTime});

  @override
  State<_NeoTimePickerDialog> createState() => _NeoTimePickerDialogState();
}

class _NeoTimePickerDialogState extends State<_NeoTimePickerDialog> {
  late int _hour;
  late int _minute;

  @override
  void initState() {
    super.initState();
    _hour = widget.initialTime.hour;
    _minute = widget.initialTime.minute;
  }



  @override
  Widget build(BuildContext context) {
    const blueBg = Color(0xFFD1E9FF);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Transform.rotate(
        angle: 0.01,
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: blueBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.brutalistBlack, width: 4),
            boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(8, 8))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'SAAT SEÇ',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.brutalistBlack,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // HOUR
                  Container(
                    height: 180,
                    width: 80,
                    decoration: BoxDecoration(
                      color: AppColors.brutalistWhite,
                      border: Border.all(color: AppColors.brutalistBlack, width: 4),
                      boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(4, 4))],
                    ),
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 60,
                      perspective: 0.005,
                      diameterRatio: 1.5,
                      physics: const FixedExtentScrollPhysics(),
                      controller: FixedExtentScrollController(initialItem: _hour),
                      onSelectedItemChanged: (index) => setState(() => _hour = index),
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 24,
                        builder: (context, index) {
                          final isSelected = index == _hour;
                          return Center(
                            child: Text(
                              index.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: isSelected ? 40 : 28,
                                fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                                color: isSelected ? AppColors.brutalistBlack : Colors.grey.shade400,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  const Text(
                    ':',
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.brutalistBlack),
                  ),
                  const SizedBox(width: 24),
                  // MINUTE
                  Container(
                    height: 180,
                    width: 80,
                    decoration: BoxDecoration(
                      color: AppColors.brutalistWhite,
                      border: Border.all(color: AppColors.brutalistBlack, width: 4),
                      boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(4, 4))],
                    ),
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 60,
                      perspective: 0.005,
                      diameterRatio: 1.5,
                      physics: const FixedExtentScrollPhysics(),
                      controller: FixedExtentScrollController(initialItem: _minute),
                      onSelectedItemChanged: (index) => setState(() => _minute = index),
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 60,
                        builder: (context, index) {
                          final isSelected = index == _minute;
                          return Center(
                            child: Text(
                              index.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: isSelected ? 40 : 28,
                                fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                                color: isSelected ? AppColors.brutalistBlack : Colors.grey.shade400,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // BOTTOM BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _NeoTextButton(
                    text: 'İPTAL',
                    color: Colors.grey.shade300,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  _NeoTextButton(
                    text: 'SEÇ',
                    color: const Color(0xFFFFE599), // yellow
                    onTap: () => Navigator.pop(context, TimeOfDay(hour: _hour, minute: _minute)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NeoIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NeoIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.brutalistWhite,
          border: Border.all(color: AppColors.brutalistBlack, width: 2),
          boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(2, 2))],
        ),
        child: Icon(icon, color: AppColors.brutalistBlack, size: 24),
      ),
    );
  }
}

class _NeoTextButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onTap;

  const _NeoTextButton({required this.text, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: AppColors.brutalistBlack, width: 3),
          boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(3, 3))],
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppColors.brutalistBlack,
          ),
        ),
      ),
    );
  }
}

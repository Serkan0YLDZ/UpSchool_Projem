import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:track_calendar_tasks_habits/core/theme/app_colors.dart';
import 'package:track_calendar_tasks_habits/core/theme/track_custom_colors.dart';

/// Neo-Brutalist tarih seçici.
/// [accentColor] parametresi picker arka planını ve seçili günü renklendirir;
/// geçilmezse varsayılan olarak [AppColors.homeSectionCalendarBlue] kullanılır.
Future<DateTime?> showNeoDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  Color? accentColor,
}) {
  return showGeneralDialog<DateTime>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Kapat',
    barrierColor: context.scheme.scrim.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, anim1, anim2) => _NeoDatePickerDialog(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      accentColor: accentColor ?? AppColors.homeSectionCalendarBlue,
    ),
    transitionBuilder: (context, anim1, anim2, child) => Transform.scale(
      scale: anim1.value,
      child: Opacity(opacity: anim1.value, child: child),
    ),
  );
}

/// Neo-Brutalist saat seçici.
/// [accentColor] parametresi picker arka planını renklendirir;
/// geçilmezse varsayılan olarak [AppColors.homeSectionCalendarBlue] kullanılır.
Future<TimeOfDay?> showNeoTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  Color? accentColor,
}) {
  return showGeneralDialog<TimeOfDay>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Kapat',
    barrierColor: context.scheme.scrim.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, anim1, anim2) =>
        _NeoTimePickerDialog(
          initialTime: initialTime,
          accentColor: accentColor ?? AppColors.homeSectionCalendarBlue,
        ),
    transitionBuilder: (context, anim1, anim2, child) => Transform.scale(
      scale: anim1.value,
      child: Opacity(opacity: anim1.value, child: child),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class _NeoDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Color accentColor;

  const _NeoDatePickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.accentColor,
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

  void _previousMonth() => setState(() {
        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
      });

  void _nextMonth() => setState(() {
        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
      });

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final track = context.track;
    final accent = widget.accentColor;
    final panelBg = Color.lerp(accent, Colors.white, 0.52)!;
    final daysInMonth =
        DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final firstDayOffset =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday - 1;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Transform.rotate(
        angle: -0.01,
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: panelBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: track.brutalistInk, width: 4),
            boxShadow: [
              BoxShadow(color: track.brutalistInk, offset: const Offset(6, 6)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NeoIconButton(icon: Icons.chevron_left, onTap: _previousMonth),
                  Text(
                    DateFormat('MMMM yyyy', 'tr')
                        .format(_focusedMonth)
                        .toUpperCase(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: track.brutalistInk,
                      letterSpacing: 1.0,
                    ),
                  ),
                  _NeoIconButton(icon: Icons.chevron_right, onTap: _nextMonth),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children:
                    ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz']
                        .map(
                          (d) => Expanded(
                            child: Text(
                              d,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: track.brutalistInk,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: daysInMonth + firstDayOffset,
                itemBuilder: (context, index) {
                  if (index < firstDayOffset) return const SizedBox();
                  final day = index - firstDayOffset + 1;
                  final date = DateTime(
                      _focusedMonth.year, _focusedMonth.month, day);
                  final isSelected = date.year == _selectedDate.year &&
                      date.month == _selectedDate.month &&
                      date.day == _selectedDate.day;
                  final isToday = date.year == DateTime.now().year &&
                      date.month == DateTime.now().month &&
                      date.day == DateTime.now().day;
                  final isOutOfRange = date.isBefore(widget.firstDate) ||
                      date.isAfter(widget.lastDate);

                  return GestureDetector(
                    onTap: isOutOfRange
                        ? null
                        : () => setState(() => _selectedDate = date),
                    child: Transform.rotate(
                      angle: isSelected ? -0.05 : 0.0,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? accent
                              : isOutOfRange
                                  ? Colors.transparent
                                  : track.brutalistSurface,
                          border: Border.all(
                            color: isOutOfRange
                                ? scheme.outlineVariant
                                : track.brutalistInk,
                            width: isSelected || isToday ? 3 : 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: track.brutalistInk,
                                    offset: const Offset(2, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: isOutOfRange
                                ? scheme.outline
                                : (isSelected
                                    ? AppColors.neoStackOnFace
                                    : track.brutalistInk),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _NeoTextButton(
                    text: 'İPTAL',
                    backgroundColor: scheme.surfaceContainerHigh,
                    foregroundColor: track.brutalistInk,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  _NeoTextButton(
                    text: 'SEÇ',
                    backgroundColor: accent,
                    foregroundColor: AppColors.neoStackOnFace,
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

// ─────────────────────────────────────────────────────────────────────────────

class _NeoTimePickerDialog extends StatefulWidget {
  final TimeOfDay initialTime;
  final Color accentColor;

  const _NeoTimePickerDialog({
    required this.initialTime,
    required this.accentColor,
  });

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
    final scheme = context.scheme;
    final track = context.track;
    final accent = widget.accentColor;
    final panelBg = Color.lerp(accent, Colors.white, 0.48)!;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Transform.rotate(
        angle: 0.01,
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: panelBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: track.brutalistInk, width: 4),
            boxShadow: [
              BoxShadow(color: track.brutalistInk, offset: const Offset(8, 8)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SAAT SEÇ',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: track.brutalistInk,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _WheelBox(
                    count: 24,
                    initialItem: _hour,
                    onChanged: (v) => setState(() => _hour = v),
                  ),
                  const SizedBox(width: 24),
                  Text(
                    ':',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: track.brutalistInk,
                    ),
                  ),
                  const SizedBox(width: 24),
                  _WheelBox(
                    count: 60,
                    initialItem: _minute,
                    onChanged: (v) => setState(() => _minute = v),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _NeoTextButton(
                    text: 'İPTAL',
                    backgroundColor: scheme.surfaceContainerHigh,
                    foregroundColor: track.brutalistInk,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  _NeoTextButton(
                    text: 'SEÇ',
                    backgroundColor: accent,
                    foregroundColor: AppColors.neoStackOnFace,
                    onTap: () => Navigator.pop(
                      context,
                      TimeOfDay(hour: _hour, minute: _minute),
                    ),
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

class _WheelBox extends StatelessWidget {
  final int count;
  final int initialItem;
  final ValueChanged<int> onChanged;

  const _WheelBox({
    required this.count,
    required this.initialItem,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final track = context.track;
    final scheme = context.scheme;
    return Container(
      height: 180,
      width: 80,
      decoration: BoxDecoration(
        color: track.brutalistSurface,
        border: Border.all(color: track.brutalistInk, width: 4),
        boxShadow: [
          BoxShadow(color: track.brutalistInk, offset: const Offset(4, 4)),
        ],
      ),
      child: ListWheelScrollView.useDelegate(
        itemExtent: 60,
        perspective: 0.005,
        diameterRatio: 1.5,
        physics: const FixedExtentScrollPhysics(),
        controller: FixedExtentScrollController(initialItem: initialItem),
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: count,
          builder: (context, index) {
            final isSelected = index == initialItem;
            return Center(
              child: Text(
                index.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontSize: isSelected ? 40 : 28,
                  fontWeight:
                      isSelected ? FontWeight.w900 : FontWeight.bold,
                  color: isSelected
                      ? track.brutalistInk
                      : scheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
            );
          },
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
          color: context.track.brutalistSurface,
          border: Border.all(color: context.track.brutalistInk, width: 2),
          boxShadow: [
            BoxShadow(color: context.track.brutalistInk, offset: Offset(2, 2)),
          ],
        ),
        child: Icon(icon, color: context.track.brutalistInk, size: 24),
      ),
    );
  }
}

class _NeoTextButton extends StatelessWidget {
  const _NeoTextButton({
    required this.text,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  final String text;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ink = context.track.brutalistInk;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: ink, width: 3),
          boxShadow: [
            BoxShadow(color: ink, offset: const Offset(3, 3)),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: foregroundColor,
          ),
        ),
      ),
    );
  }
}

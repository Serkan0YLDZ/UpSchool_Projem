import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/record_type_accent.dart';
import '../../core/theme/track_custom_colors.dart';
import '../../core/utils/neo_picker.dart';
import '../../core/enums/item_type.dart';

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
  const _TaskTimingSheet({this.initialStartDate, this.initialStartTime, this.initialEndDate});
  final DateTime? initialStartDate;
  final String? initialStartTime;
  final DateTime? initialEndDate;
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
      _startTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } else {
      _startTime = TimeOfDay.now();
    }
    _endDate = widget.initialEndDate;
    if (_endDate != null) _endTime = TimeOfDay.fromDateTime(_endDate!);
    _showEndDate = _endDate != null;
  }

  void _onSave() {
    final startT = '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}';
    DateTime? finalEnd;
    if (_showEndDate && _endDate != null && _endTime != null) {
      finalEnd = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, _endTime!.hour, _endTime!.minute);
    }
    Navigator.of(context).pop((startDate: _startDate, startTime: startT, endDate: finalEnd, goBack: false));
  }

  Future<void> _pickStartDate() async {
    final picked = await showNeoDatePicker(
      context: context, initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate)) {
          _endDate = null;
          _showEndDate = false;
        }
      });
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showNeoTimePicker(context: context, initialTime: _startTime);
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndDate() async {
    final picked = await showNeoDatePicker(
      context: context, initialDate: _endDate ?? _startDate, firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showNeoTimePicker(
      context: context, initialTime: _endTime ?? const TimeOfDay(hour: 23, minute: 59));
    if (picked != null) setState(() => _endTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final accent = recordTypeSectionAccent(ItemType.event);
    final titleStripBg = Color.lerp(accent, Colors.white, 0.52)!;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: BoxDecoration(
          color: context.scheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(top: BorderSide(color: context.track.brutalistInk, width: 4)),
        ),
        padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomPadding),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context,
                        (startDate: _startDate, startTime: '', endDate: null, goBack: true)),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: context.track.brutalistSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.track.brutalistInk, width: 2),
                        boxShadow: [BoxShadow(color: context.track.brutalistInk, offset: Offset(3, 3))]),
                      child: Icon(Icons.arrow_back, color: context.track.brutalistInk),
                    ),
                  ),
                  Row(children: [
                    _dot(false), const SizedBox(width: 6),
                    _dot(false), const SizedBox(width: 6),
                    _dot(true, accent),
                  ]),
                ],
              ),
              const SizedBox(height: 24),
              Transform.rotate(
                angle: -0.02,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: titleStripBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.track.brutalistInk, width: 3),
                    boxShadow: [BoxShadow(color: context.track.brutalistInk, offset: Offset(4, 4))]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ZAMANLAMA', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900,
                          color: context.track.brutalistInk, letterSpacing: 1.0)),
                      SizedBox(height: 8),
                      Text('Başlangıç ve bitiş tarihini seçin.',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.track.brutalistInk)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _section(color: context.scheme.secondaryContainer, title: 'Başlangıç',
                child: _DateTimeSelector(date: _startDate, time: _startTime,
                  onDateTap: _pickStartDate, onTimeTap: _pickStartTime)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: context.track.brutalistSurface,
                  border: Border.all(color: context.track.brutalistInk, width: 4),
                  boxShadow: [BoxShadow(color: context.track.brutalistInk, offset: Offset(6, 6))]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bitiş Tarihi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: context.track.brutalistInk)),
                        Text('(İsteğe Bağlı)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => setState(() {
                        _showEndDate = !_showEndDate;
                        if (!_showEndDate) { _endDate = null; _endTime = null; }
                        else { _endDate = _startDate; _endTime = const TimeOfDay(hour: 23, minute: 59); }
                      }),
                      child: Container(
                        width: 56, height: 32,
                        decoration: BoxDecoration(color: context.track.brutalistSurface,
                          border: Border.all(color: context.track.brutalistInk, width: 2)),
                        padding: const EdgeInsets.all(4),
                        child: Align(
                          alignment: _showEndDate ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(width: 20, height: 20,
                            decoration: BoxDecoration(
                              color: _showEndDate ? accent : context.scheme.outline,
                              border: Border.all(color: context.track.brutalistInk, width: 2))),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_showEndDate) ...[
                const SizedBox(height: 24),
                _section(color: context.scheme.secondaryContainer, title: 'Bitiş',
                  child: _DateTimeSelector(
                    date: _endDate ?? DateTime.now(),
                    time: _endTime ?? const TimeOfDay(hour: 23, minute: 59),
                    onDateTap: _pickEndDate, onTimeTap: _pickEndTime)),
              ],
              const SizedBox(height: 32),
              GestureDetector(
                onTap: _onSave,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(color: accent,
                    border: Border.all(color: context.track.brutalistInk, width: 4),
                    boxShadow: [BoxShadow(color: context.track.brutalistInk, offset: Offset(6, 6))]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('OLUŞTUR', style: TextStyle(color: context.track.brutalistSurface, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: context.track.brutalistSurface, size: 28),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section({required Color color, required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color,
        border: Border.all(color: context.track.brutalistInk, width: 4),
        boxShadow: [BoxShadow(color: context.track.brutalistInk, offset: Offset(6, 6))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: context.track.brutalistInk)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _dot(bool active, [Color? color]) {
    return Transform.rotate(
      angle: active ? -0.05 : 0,
      child: Container(
        width: active ? 20 : 12, height: 12,
        decoration: BoxDecoration(
          color: active ? (color ?? recordTypeSectionAccent(ItemType.event)) : context.track.brutalistSurface,
          borderRadius: BorderRadius.circular(active ? 12 : 6),
          border: Border.all(color: context.track.brutalistInk, width: 2)),
      ),
    );
  }
}

class _DateTimeSelector extends StatelessWidget {
  const _DateTimeSelector({required this.date, required this.time, required this.onDateTap, required this.onTimeTap});
  final DateTime date;
  final TimeOfDay time;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;

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
            child: Container(
              height: 56, padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: context.track.brutalistSurface,
                border: Border.all(color: context.track.brutalistInk, width: 3),
                boxShadow: [BoxShadow(color: context.track.brutalistInk, offset: Offset(3, 3))]),
              child: Row(children: [
                Expanded(child: Text(DateFormat('d MMM yyyy', 'tr').format(date),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.track.brutalistInk),
                  overflow: TextOverflow.ellipsis)),
                Icon(Icons.calendar_today, color: context.track.brutalistInk, size: 20),
              ]),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: onTimeTap,
            child: Container(
              height: 56, padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: context.track.brutalistSurface,
                border: Border.all(color: context.track.brutalistInk, width: 3),
                boxShadow: [BoxShadow(color: context.track.brutalistInk, offset: Offset(3, 3))]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$h:$m', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.track.brutalistInk)),
                  Icon(Icons.access_time_filled, color: context.track.brutalistInk, size: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

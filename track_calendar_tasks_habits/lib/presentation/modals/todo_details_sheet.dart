import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/record_type_accent.dart';
import '../../core/theme/track_custom_colors.dart';
import '../../core/utils/neo_picker.dart';
import '../../core/enums/item_type.dart';
import '../../data/models/todo_model.dart';

Future<({DateTime? dueDate, TodoPriority priority, bool goBack})?> showTodoDetailsSheet(
  BuildContext context, {
  DateTime? initialDueDate,
  TodoPriority initialPriority = TodoPriority.medium,
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
  const _TodoDetailsSheet({this.initialDueDate, required this.initialPriority});
  final DateTime? initialDueDate;
  final TodoPriority initialPriority;
  @override
  State<_TodoDetailsSheet> createState() => _TodoDetailsSheetState();
}

class _TodoDetailsSheetState extends State<_TodoDetailsSheet> {
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  late TodoPriority _priority;
  bool _showDueDate = false;

  @override
  void initState() {
    super.initState();
    _dueDate = widget.initialDueDate;
    if (_dueDate != null) { _dueTime = TimeOfDay.fromDateTime(_dueDate!); _showDueDate = true; }
    _priority = widget.initialPriority;
  }

  Future<void> _pickDueDate() async {
    final picked = await showNeoDatePicker(context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)));
    if (picked != null) setState(() { _dueDate = picked; _dueTime ??= TimeOfDay.now(); });
  }

  Future<void> _pickDueTime() async {
    final picked = await showNeoTimePicker(context: context, initialTime: _dueTime ?? TimeOfDay.now());
    if (picked != null) setState(() { _dueTime = picked; _dueDate ??= DateTime.now(); });
  }

  void _onSave() {
    DateTime? finalDue;
    if (_showDueDate && _dueDate != null) {
      finalDue = DateTime(_dueDate!.year, _dueDate!.month, _dueDate!.day,
          _dueTime?.hour ?? 0, _dueTime?.minute ?? 0);
    }
    Navigator.of(context).pop((dueDate: finalDue, priority: _priority, goBack: false));
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final accent = recordTypeSectionAccent(ItemType.todo);
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
                    onTap: () => Navigator.pop(context, (dueDate: null, priority: _priority, goBack: true)),
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
                  child: Text('YAPILACAK ŞEYİN\nDETAYLARI',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900,
                        color: context.track.brutalistInk, height: 1.2, letterSpacing: 1.0)),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: context.track.brutalistSurface,
                  border: Border.all(color: context.track.brutalistInk, width: 4),
                  boxShadow: [BoxShadow(color: context.track.brutalistInk, offset: Offset(6, 6))]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Önem Derecesi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: context.track.brutalistInk)),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                        child: _PriorityButton(
                          label: 'Düşük',
                          isSelected: _priority == TodoPriority.low,
                          onTap: () => setState(() => _priority = TodoPriority.low),
                          activeColor: context.track.todoPriorityLow,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _PriorityButton(
                          label: 'Orta',
                          isSelected: _priority == TodoPriority.medium,
                          onTap: () => setState(() => _priority = TodoPriority.medium),
                          activeColor: context.track.todoPriorityMedium,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _PriorityButton(
                          label: 'Yüksek',
                          isSelected: _priority == TodoPriority.high,
                          onTap: () => setState(() => _priority = TodoPriority.high),
                          activeColor: context.track.todoPriorityHigh,
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: context.track.brutalistSurface,
                  border: Border.all(color: context.track.brutalistInk, width: 4),
                  boxShadow: [BoxShadow(color: context.track.brutalistInk, offset: Offset(6, 6))]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Bitiş Tarihi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: context.track.brutalistInk)),
                          Text('(İsteğe Bağlı)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                        ]),
                        GestureDetector(
                          onTap: () => setState(() {
                            _showDueDate = !_showDueDate;
                            if (!_showDueDate) { _dueDate = null; _dueTime = null; }
                          }),
                          child: Container(
                            width: 56, height: 32,
                            decoration: BoxDecoration(color: context.track.brutalistSurface,
                              border: Border.all(color: context.track.brutalistInk, width: 2)),
                            padding: const EdgeInsets.all(4),
                            child: Align(
                              alignment: _showDueDate ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(width: 20, height: 20,
                                decoration: BoxDecoration(
                                  color: _showDueDate ? accent : context.scheme.outline,
                                  border: Border.all(color: context.track.brutalistInk, width: 2))),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_showDueDate) ...[
                      const SizedBox(height: 16),
                      _TodoDateTimeSelector(date: _dueDate, time: _dueTime,
                        onDateTap: _pickDueDate, onTimeTap: _pickDueTime),
                    ],
                  ],
                ),
              ),
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

  Widget _dot(bool active, [Color? color]) => Container(
    width: active ? 20 : 12, height: 12,
    decoration: BoxDecoration(
      color: active ? (color ?? recordTypeSectionAccent(ItemType.todo)) : context.track.brutalistSurface,
      borderRadius: BorderRadius.circular(active ? 12 : 6),
      border: Border.all(color: context.track.brutalistInk, width: 2)));
}

class _PriorityButton extends StatelessWidget {
  const _PriorityButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final ink = context.track.brutalistInk;
    return GestureDetector(
      onTap: onTap,
      child: Transform.translate(
        offset: isSelected ? const Offset(0, -4) : Offset.zero,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : context.track.brutalistSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ink, width: 3),
            boxShadow: isSelected ? [BoxShadow(color: ink, offset: const Offset(4, 4))] : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ).copyWith(color: ink),
          ),
        ),
      ),
    );
  }
}

class _TodoDateTimeSelector extends StatelessWidget {
  const _TodoDateTimeSelector({required this.date, required this.time, required this.onDateTap, required this.onTimeTap});
  final DateTime? date; final TimeOfDay? time;
  final VoidCallback onDateTap; final VoidCallback onTimeTap;

  @override
  Widget build(BuildContext context) {
    final dateStr = date != null ? DateFormat('d MMM yyyy', 'tr').format(date!) : 'Tarih Seç';
    final h = time?.hour.toString().padLeft(2, '0') ?? '--';
    final m = time?.minute.toString().padLeft(2, '0') ?? '--';
    return Row(children: [
      Expanded(flex: 5, child: GestureDetector(onTap: onDateTap,
        child: Container(height: 56, padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: context.track.brutalistSurface,
            border: Border.all(color: context.track.brutalistInk, width: 3),
            boxShadow: [BoxShadow(color: context.track.brutalistInk, offset: Offset(3, 3))]),
          child: Row(children: [
            Expanded(child: Text(dateStr, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
              color: date != null ? context.track.brutalistInk : context.scheme.outline), overflow: TextOverflow.ellipsis)),
            Icon(Icons.calendar_today, color: context.track.brutalistInk, size: 20),
          ])))),
      const SizedBox(width: 12),
      Expanded(flex: 3, child: GestureDetector(onTap: onTimeTap,
        child: Container(height: 56, padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: context.track.brutalistSurface,
            border: Border.all(color: context.track.brutalistInk, width: 3),
            boxShadow: [BoxShadow(color: context.track.brutalistInk, offset: Offset(3, 3))]),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('$h:$m', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
              color: time != null ? context.track.brutalistInk : context.scheme.outline)),
            Icon(Icons.access_time_filled, color: context.track.brutalistInk, size: 20),
          ])))),
    ]);
  }
}

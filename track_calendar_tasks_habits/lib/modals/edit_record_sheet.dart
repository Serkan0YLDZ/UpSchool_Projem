import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/theme/record_type_accent.dart';
import '../core/theme/track_custom_colors.dart';
import '../core/utils/calendar_date.dart';
import '../core/utils/habit_icons.dart';
import '../core/utils/neo_picker.dart';
import '../data/models/record_model.dart';

Future<RecordModel?> showEditRecordSheet(BuildContext context, RecordModel record) async {
  return showModalBottomSheet<RecordModel>(
    context: context,
    backgroundColor: Colors.transparent,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (ctx) => _EditRecordSheet(record: record),
  );
}

class _EditRecordSheet extends StatefulWidget {
  const _EditRecordSheet({required this.record});
  final RecordModel record;
  @override
  State<_EditRecordSheet> createState() => _EditRecordSheetState();
}

class _EditRecordSheetState extends State<_EditRecordSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _targetController;
  late final TextEditingController _unitController;

  Priority? _selectedPriority;
  DateTime? _dueDate;
  bool _showTodoDueDate = false;

  String? _scheduledDate;
  String? _scheduledTime;
  String? _endDate;
  String? _endTime;
  bool _showEndDate = false;

  Set<String> _selectedDays = {};
  int? _intervalDays;

  // Alışkanlık ikon & renk
  late String _selectedIconKey;
  late int _selectedIconColor;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _titleController = TextEditingController(text: r.title);
    _targetController = TextEditingController(text: r.targetProgress.toString());
    _unitController = TextEditingController(text: r.targetUnit ?? '');
    _selectedPriority = r.priority;
    _dueDate = r.dueDate;
    _showTodoDueDate = _dueDate != null;
    _scheduledDate = r.scheduledDate;
    _scheduledTime = r.scheduledTime;
    _endDate = r.endDate;
    _endTime = r.endTime;
    _showEndDate = _endDate != null || _endTime != null;
    _selectedDays = r.repeatDays.toSet();
    _intervalDays = r.intervalDays;
    _selectedIconKey = r.icon ?? HabitIcons.defaultKey;
    _selectedIconColor = r.iconColor ?? HabitIcons.defaultColor;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Color get _accent => recordTypeSectionAccent(widget.record.type);

  void _save() {
    final targetVal = int.tryParse(_targetController.text.trim()) ?? 100;
    final unitVal = _unitController.text.trim();
    final newRecord = RecordModel(
      id: widget.record.id,
      type: widget.record.type,
      createdAt: widget.record.createdAt,
      isActive: widget.record.isActive,
      title: _titleController.text.trim(),
      description: widget.record.description,
      icon: widget.record.type == RecordType.habit ? _selectedIconKey : widget.record.icon,
      iconColor: widget.record.type == RecordType.habit ? _selectedIconColor : widget.record.iconColor,
      targetProgress: targetVal,
      targetUnit: unitVal.isEmpty ? null : unitVal,
      priority: _selectedPriority,
      dueDate: _showTodoDueDate ? _dueDate : null,
      scheduledDate: _scheduledDate,
      scheduledTime: _scheduledTime,
      endDate: _showEndDate ? _endDate : null,
      endTime: _showEndDate ? _endTime : null,
      repeatDays: _selectedDays.toList(),
      intervalDays: _intervalDays,
    );
    Navigator.pop(context, newRecord);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final accent = _accent;
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
              Transform.rotate(
                angle: -0.02,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: titleStripBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.track.brutalistInk, width: 3),
                    boxShadow: [BoxShadow(color: context.track.brutalistInk, offset: Offset(4, 4))],
                  ),
                  child: Text(
                    widget.record.type == RecordType.habit ? 'ALIŞKANLIĞI\nDÜZENLE'
                        : widget.record.type == RecordType.event ? 'ETKİNLİĞİ\nDÜZENLE'
                        : 'YAPILACAK ŞEYİ\nDÜZENLE',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900,
                        color: context.track.brutalistInk, height: 1.2, letterSpacing: 1.0),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: context.track.brutalistSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.track.brutalistInk, width: 3),
                  boxShadow: [BoxShadow(color: context.track.brutalistInk, offset: Offset(4, 4))],
                ),
                child: TextField(
                  controller: _titleController,
                  autofocus: true,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.track.brutalistInk),
                  decoration: const InputDecoration(
                    hintText: 'İsim...',
                    hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (widget.record.type == RecordType.todo) _buildTodoFields(),
              if (widget.record.type == RecordType.event) _buildEventFields(),
              if (widget.record.type == RecordType.habit) _buildHabitFields(),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: _save,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.track.brutalistInk, width: 3),
                    boxShadow: [BoxShadow(color: context.track.brutalistInk, offset: Offset(4, 4))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('KAYDET', style: TextStyle(color: context.track.brutalistSurface, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      SizedBox(width: 8),
                      Icon(Icons.save, color: context.track.brutalistSurface),
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

  Widget _buildTodoFields() {
    final accent = _accent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('ÖNCELİK'),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: _PriorityChip(
              'Düşük',
              Priority.low,
              context.track.todoPriorityLow,
              _selectedPriority,
              onTap: () => setState(() => _selectedPriority = _selectedPriority == Priority.low ? null : Priority.low),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _PriorityChip(
              'Orta',
              Priority.medium,
              context.track.todoPriorityMedium,
              _selectedPriority,
              onTap: () => setState(() => _selectedPriority = _selectedPriority == Priority.medium ? null : Priority.medium),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _PriorityChip(
              'Yüksek',
              Priority.high,
              context.track.todoPriorityHigh,
              _selectedPriority,
              onTap: () => setState(() => _selectedPriority = _selectedPriority == Priority.high ? null : Priority.high),
            ),
          ),
        ]),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _FieldLabel('BİTİŞ TARİHİ'),
              Text('(İsteğe Bağlı)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            ]),
            _ToggleSwitch(
              value: _showTodoDueDate, accentColor: accent,
              onChanged: (v) => setState(() {
                _showTodoDueDate = v;
                if (!v) { _dueDate = null; } else { _dueDate = DateTime.now(); }
              }),
            ),
          ],
        ),
        if (_showTodoDueDate) ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _NeoPicker(
              text: _dueDate != null ? DateFormat('d MMM yyyy', 'tr').format(_dueDate!) : 'Tarih',
              icon: Icons.calendar_today, onTap: () async {
                final date = await showNeoDatePicker(context: context,
                  accentColor: accent,
                  initialDate: _scheduledDate != null ? DateTime.parse(_scheduledDate!) : DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)));
                if (date != null) {
                  setState(() {
                    _dueDate = _dueDate != null
                        ? DateTime(date.year, date.month, date.day, _dueDate!.hour, _dueDate!.minute)
                        : date;
                  });
                }
              })),
            const SizedBox(width: 12),
            Expanded(child: _NeoPicker(
              text: _dueDate != null ? DateFormat('HH:mm').format(_dueDate!) : 'Saat',
              icon: Icons.access_time, onTap: () async {
                final time = await showNeoTimePicker(context: context, accentColor: accent, initialTime: TimeOfDay.now());
                if (time != null) {
                  setState(() {
                    final d = _dueDate ?? DateTime.now();
                    _dueDate = DateTime(d.year, d.month, d.day, time.hour, time.minute);
                  });
                }
              })),
          ]),
        ],
      ],
    );
  }

  Widget _buildEventFields() {
    final accent = _accent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('BAŞLANGIÇ'),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _NeoPicker(
            text: _scheduledDate ?? 'Tarih', icon: Icons.calendar_today, onTap: () async {
              final initial = _scheduledDate != null ? DateTime.tryParse(_scheduledDate!) : null;
              final date = await showNeoDatePicker(context: context,
                accentColor: accent,
                initialDate: initial ?? DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365 * 5)));
              if (date != null) setState(() => _scheduledDate = CalendarDate.ymd(date));
            })),
          const SizedBox(width: 12),
          Expanded(child: _NeoPicker(
            text: _scheduledTime ?? 'Saat', icon: Icons.access_time, onTap: () async {
              TimeOfDay? init;
              if (_scheduledTime?.contains(':') == true) {
                final p = _scheduledTime!.split(':');
                init = TimeOfDay(hour: int.tryParse(p[0]) ?? 0, minute: int.tryParse(p[1]) ?? 0);
              }
              final time = await showNeoTimePicker(context: context, accentColor: accent, initialTime: init ?? TimeOfDay.now());
              if (time != null) {
                final h = time.hour.toString().padLeft(2, '0');
                final m = time.minute.toString().padLeft(2, '0');
                setState(() => _scheduledTime = '$h:$m');
              }
            })),
        ]),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _FieldLabel('BİTİŞ TARİHİ'),
              Text('(İsteğe Bağlı)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            ]),
            _ToggleSwitch(
              value: _showEndDate, accentColor: accent,
              onChanged: (v) => setState(() { _showEndDate = v; if (!v) { _endDate = null; _endTime = null; } }),
            ),
          ],
        ),
        if (_showEndDate) ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _NeoPicker(
              text: _endDate ?? 'Tarih', icon: Icons.calendar_today, onTap: () async {
                final first = _scheduledDate != null ? DateTime.parse(_scheduledDate!) : DateTime.now();
                final date = await showNeoDatePicker(context: context,
                  accentColor: accent,
                  initialDate: _endDate != null ? DateTime.parse(_endDate!) : first,
                  firstDate: first, lastDate: DateTime.now().add(const Duration(days: 365 * 5)));
                if (date != null) setState(() => _endDate = CalendarDate.ymd(date));
              })),
            const SizedBox(width: 12),
            Expanded(child: _NeoPicker(
              text: _endTime ?? 'Saat', icon: Icons.access_time, onTap: () async {
                TimeOfDay? init;
                if (_endTime?.contains(':') == true) {
                  final p = _endTime!.split(':');
                  init = TimeOfDay(hour: int.tryParse(p[0]) ?? 0, minute: int.tryParse(p[1]) ?? 0);
                }
                final time = await showNeoTimePicker(context: context, accentColor: accent, initialTime: init ?? TimeOfDay.now());
                if (time != null) {
                  final h = time.hour.toString().padLeft(2, '0');
                  final m = time.minute.toString().padLeft(2, '0');
                  setState(() => _endTime = '$h:$m');
                }
              })),
          ]),
        ],
      ],
    );
  }

  Widget _buildHabitFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('HEDEF'),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(flex: 2, child: _BrutalistField(controller: _targetController, hint: 'Hedef...', keyboardType: TextInputType.number)),
          const SizedBox(width: 12),
          Expanded(flex: 1, child: _BrutalistField(controller: _unitController, hint: 'Birim')),
        ]),
        const SizedBox(height: 24),
        const _FieldLabel('TEKRAR SIKLIĞI'),
        const SizedBox(height: 12),
        _EditDaySelector(
          selectedDays: _selectedDays,
          accentColor: _accent,
          onToggle: (code) => setState(() {
          if (_selectedDays.contains(code)) { _selectedDays.remove(code); }
          else { _selectedDays.add(code); _intervalDays = null; }
        })),
        const SizedBox(height: 24),
        const _FieldLabel('VEYA X GÜNDE BİR:'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: context.track.brutalistSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.track.brutalistInk, width: 3),
            boxShadow: [BoxShadow(color: context.track.brutalistInk, offset: Offset(3, 3))],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              value: _intervalDays, isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: context.track.brutalistInk),
              style: TextStyle(fontWeight: FontWeight.bold, color: context.track.brutalistInk, fontSize: 16),
              hint: Text('Seçilmedi', style: TextStyle(fontWeight: FontWeight.bold, color: context.track.brutalistInk)),
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('Seçilmedi')),
                ...List.generate(30, (i) => DropdownMenuItem<int?>(value: i + 1, child: Text('${i + 1} günde bir'))),
              ],
              onChanged: (val) => setState(() { _intervalDays = val; if (val != null) _selectedDays.clear(); }),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // ── İkon & Renk Seçici ────────────────────────────────────────────
        _EditIconColorPicker(
          selectedIconKey: _selectedIconKey,
          selectedColor: _selectedIconColor,
          onIconSelected: (key) => setState(() => _selectedIconKey = key),
          onColorSelected: (color) => setState(() => _selectedIconColor = color),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: context.track.brutalistInk, letterSpacing: 1.0));
}

class _NeoPicker extends StatelessWidget {
  const _NeoPicker({required this.text, required this.icon, required this.onTap});
  final String text; final IconData icon; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(color: context.track.brutalistSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.track.brutalistInk, width: 3),
        boxShadow: [BoxShadow(color: context.track.brutalistInk, offset: Offset(3, 3))]),
      child: Row(children: [
        Icon(icon, color: context.track.brutalistInk, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(text,
          style: TextStyle(fontWeight: FontWeight.bold, color: context.track.brutalistInk),
          maxLines: 1, overflow: TextOverflow.ellipsis)),
      ]),
    ),
  );
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip(
    this.label,
    this.value,
    this.activeColor,
    this.current, {
    required this.onTap,
  });

  final String label;
  final Priority value;
  final Color activeColor;
  final Priority? current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = current == value;
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                  color: ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleSwitch extends StatelessWidget {
  const _ToggleSwitch({required this.value, required this.accentColor, required this.onChanged});
  final bool value; final Color accentColor; final void Function(bool) onChanged;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => onChanged(!value),
    child: Container(
      width: 56, height: 32,
      decoration: BoxDecoration(color: context.track.brutalistSurface, border: Border.all(color: context.track.brutalistInk, width: 2)),
      padding: const EdgeInsets.all(4),
      child: Align(
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(width: 20, height: 20,
          decoration: BoxDecoration(color: value ? accentColor : context.scheme.outline,
            border: Border.all(color: context.track.brutalistInk, width: 2))),
      ),
    ),
  );
}

class _BrutalistField extends StatelessWidget {
  const _BrutalistField({required this.controller, required this.hint, this.keyboardType});
  final TextEditingController controller; final String hint; final TextInputType? keyboardType;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: context.track.brutalistSurface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: context.track.brutalistInk, width: 3),
      boxShadow: [BoxShadow(color: context.track.brutalistInk, offset: Offset(3, 3))]),
    child: TextField(
      controller: controller, keyboardType: keyboardType,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.track.brutalistInk),
      decoration: InputDecoration(hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), border: InputBorder.none),
    ),
  );
}

class _EditDaySelector extends StatelessWidget {
  static const _days = ['PZT', 'SAL', 'ÇAR', 'PER', 'CUM', 'CTS', 'PAZ'];
  static const _codes = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  const _EditDaySelector({
    required this.selectedDays,
    required this.accentColor,
    required this.onToggle,
  });
  final Set<String> selectedDays;
  final Color accentColor;
  final void Function(String) onToggle;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final itemWidth = (constraints.maxWidth - (6 * 8)) / 7;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_days.length, (i) {
          final isSelected = selectedDays.contains(_codes[i]);
          return GestureDetector(
            onTap: () => onToggle(_codes[i]),
            child: Container(
              width: itemWidth, height: itemWidth,
              decoration: BoxDecoration(
                color: isSelected ? accentColor : context.track.brutalistSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.track.brutalistInk, width: 2),
                boxShadow: isSelected ? [] : [BoxShadow(color: context.track.brutalistInk, offset: Offset(2, 2))]),
              alignment: Alignment.center,
              child: Text(_days[i], style: TextStyle(color: context.track.brutalistInk, fontSize: 12, fontWeight: FontWeight.w900)),
            ),
          );
        }),
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Düzenleme ekranı için İkon & Renk Seçici

class _EditIconColorPicker extends StatelessWidget {
  const _EditIconColorPicker({
    required this.selectedIconKey,
    required this.selectedColor,
    required this.onIconSelected,
    required this.onColorSelected,
  });

  final String selectedIconKey;
  final int selectedColor;
  final ValueChanged<String> onIconSelected;
  final ValueChanged<int> onColorSelected;

  @override
  Widget build(BuildContext context) {
    final ink = context.track.brutalistInk;
    final surface = context.track.brutalistSurface;
    final iconEntries = HabitIcons.icons.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.palette_rounded, color: ink, size: 18),
            const SizedBox(width: 8),
            Text(
              'İKON & RENK',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: ink,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // ── İkon satırı ──────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: iconEntries.map((entry) {
            final isSelected = entry.key == selectedIconKey;
            return GestureDetector(
              onTap: () => onIconSelected(entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected ? Color(selectedColor) : surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: ink, width: isSelected ? 3 : 2),
                  boxShadow: isSelected
                      ? [BoxShadow(color: ink, offset: const Offset(3, 3))]
                      : [],
                ),
                child: Icon(entry.value, color: ink, size: 22),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        // ── Renk satırı ──────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: HabitIcons.palette.map((colorInt) {
            final isSelected = colorInt == selectedColor;
            return GestureDetector(
              onTap: () => onColorSelected(colorInt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Color(colorInt),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? ink : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: ink, offset: const Offset(2, 2))]
                      : [],
                ),
                child: isSelected
                    ? Icon(Icons.check_rounded, color: ink, size: 18)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

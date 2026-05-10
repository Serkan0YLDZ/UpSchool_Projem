import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_new_habit/core/theme/app_colors.dart';
import 'package:my_new_habit/core/utils/neo_picker.dart';

import 'package:my_new_habit/data/models/record_model.dart';

Future<RecordModel?> showEditRecordSheet(
  BuildContext context,
  RecordModel record,
) async {
  return showModalBottomSheet<RecordModel>(
    context: context,
    backgroundColor: Colors.transparent,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (ctx) => _EditRecordSheet(record: record),
  );
}

class _EditRecordSheet extends StatefulWidget {
  final RecordModel record;
  const _EditRecordSheet({required this.record});

  @override
  State<_EditRecordSheet> createState() => _EditRecordSheetState();
}

class _EditRecordSheetState extends State<_EditRecordSheet> {
  late TextEditingController _titleController;
  late TextEditingController _targetController;
  late TextEditingController _unitController;
  
  // Todo
  Priority? _selectedPriority;
  DateTime? _dueDate;
  bool _showTodoDueDate = false;

  // Event
  String? _scheduledDate;
  String? _scheduledTime;
  String? _endDate;
  String? _endTime;
  bool _showEndDate = false;

  // Habit
  Set<String> _selectedDays = {};
  int? _intervalDays;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.record.title);
    _targetController = TextEditingController(text: widget.record.targetProgress.toString());
    _unitController = TextEditingController(text: widget.record.targetUnit ?? '');
    
    _selectedPriority = widget.record.priority;
    _dueDate = widget.record.dueDate;
    _showTodoDueDate = _dueDate != null;
    
    _scheduledDate = widget.record.scheduledDate;
    _scheduledTime = widget.record.scheduledTime;
    _endDate = widget.record.endDate;
    _endTime = widget.record.endTime;
    _showEndDate = _endDate != null || _endTime != null;
    
    _selectedDays = widget.record.repeatDays.toSet();
    _intervalDays = widget.record.intervalDays;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    const bgColor = Color(0xFFF8F9FA);
    const yellowTitleBg = Color(0xFFFFE599);
    const blueBtnBg = Color(0xFF0088CC);

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
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
                ],
              ),
              const SizedBox(height: 24),
              
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
                  child: Text(
                    widget.record.type == RecordType.habit ? 'ALIŞKANLIĞI\nDÜZENLE' 
                    : widget.record.type == RecordType.event ? 'ETKİNLİĞİ\nDÜZENLE' 
                    : 'YAPILACAK ŞEYİ\nDÜZENLE',
                    style: const TextStyle(
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

              Transform.rotate(
                angle: 0.01,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.brutalistWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.brutalistBlack, width: 3),
                    boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(4, 4))],
                  ),
                  child: TextField(
                    controller: _titleController,
                    autofocus: true,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.brutalistBlack),
                    decoration: const InputDecoration(
                      hintText: 'İsim...',
                      hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                      contentPadding: EdgeInsets.all(16),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              if (widget.record.type == RecordType.todo) _buildTodoFields(),
              if (widget.record.type == RecordType.event) _buildEventFields(),
              if (widget.record.type == RecordType.habit) _buildHabitFields(),
              
              const SizedBox(height: 32),

              Transform.rotate(
                angle: -0.01,
                child: GestureDetector(
                  onTap: () {
                    final targetVal = int.tryParse(_targetController.text.trim()) ?? 100;
                    final unitVal = _unitController.text.trim();
                    final newRecord = RecordModel(
                      id: widget.record.id,
                      type: widget.record.type,
                      createdAt: widget.record.createdAt,
                      isActive: widget.record.isActive,
                      title: _titleController.text.trim(),
                      description: widget.record.description,
                      icon: widget.record.icon,
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
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: blueBtnBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.brutalistBlack, width: 3),
                      boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(4, 4))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'KAYDET',
                          style: TextStyle(
                            color: AppColors.brutalistWhite,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.save, color: AppColors.brutalistWhite),
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

  Widget _buildTodoFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ÖNCELİK',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: AppColors.brutalistBlack,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPriorityChip('🔵 Düşük', Priority.low, const Color(0xFF93C5FD)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPriorityChip('🟡 Orta', Priority.medium, const Color(0xFFFEF08A)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPriorityChip('🔴 Yüksek', Priority.high, const Color(0xFFFECACA)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BİTİŞ TARİHİ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.brutalistBlack,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  '(İsteğe Bağlı)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _showTodoDueDate = !_showTodoDueDate;
                  if (!_showTodoDueDate) {
                    _dueDate = null;
                  } else {
                    _dueDate = DateTime.now();
                  }
                });
              },
              child: Container(
                width: 56,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.brutalistWhite,
                  border: Border.all(color: AppColors.brutalistBlack, width: 2),
                ),
                padding: const EdgeInsets.all(4),
                child: Align(
                  alignment: _showTodoDueDate ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _showTodoDueDate ? const Color(0xFF0088CC) : Colors.grey,
                      border: Border.all(color: AppColors.brutalistBlack, width: 2),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_showTodoDueDate) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildNeoPicker(
                  text: _dueDate != null ? DateFormat('d MMM yyyy', 'tr').format(_dueDate!) : 'Tarih',
                  icon: Icons.calendar_today,
                  onTap: () async {
                    final date = await showNeoDatePicker(
                      context: context,
                      initialDate: _scheduledDate != null ? DateTime.parse(_scheduledDate!) : DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365*5)),
                    );
                    if (date != null) {
                      setState(() {
                        if (_dueDate != null) {
                          _dueDate = DateTime(date.year, date.month, date.day, _dueDate!.hour, _dueDate!.minute);
                        } else {
                          _dueDate = date;
                        }
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNeoPicker(
                  text: _dueDate != null ? DateFormat('HH:mm').format(_dueDate!) : 'Saat',
                  icon: Icons.access_time,
                  onTap: () async {
                    final time = await showNeoTimePicker(
                      context: context,
                      initialTime: _scheduledTime != null 
                          ? TimeOfDay(hour: int.parse(_scheduledTime!.split(':')[0]), minute: int.parse(_scheduledTime!.split(':')[1])) 
                          : TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        final d = _dueDate ?? DateTime.now();
                        _dueDate = DateTime(d.year, d.month, d.day, time.hour, time.minute);
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPriorityChip(String label, Priority priority, Color color) {
    final selected = _selectedPriority == priority;
    return GestureDetector(
      onTap: () => setState(() => _selectedPriority = selected ? null : priority),
      child: Transform.translate(
        offset: selected ? const Offset(0, -4) : Offset.zero,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color : AppColors.brutalistWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.brutalistBlack, width: 3),
            boxShadow: selected 
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

  Widget _buildEventFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BAŞLANGIÇ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: AppColors.brutalistBlack,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildNeoPicker(
                text: _scheduledDate ?? 'Tarih',
                icon: Icons.calendar_today,
                onTap: () async {
                  final initial = _scheduledDate != null ? DateTime.tryParse(_scheduledDate!) : null;
                  final date = await showNeoDatePicker(
                    context: context,
                    initialDate: initial ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365*5)),
                  );
                  if (date != null) setState(() => _scheduledDate = DateFormat('yyyy-MM-dd').format(date));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNeoPicker(
                text: _scheduledTime ?? 'Saat',
                icon: Icons.access_time,
                onTap: () async {
                  TimeOfDay? initialTime;
                  if (_scheduledTime != null && _scheduledTime!.contains(':')) {
                    final parts = _scheduledTime!.split(':');
                    if (parts.length == 2) {
                      initialTime = TimeOfDay(hour: int.tryParse(parts[0]) ?? 0, minute: int.tryParse(parts[1]) ?? 0);
                    }
                  }
                  final time = await showNeoTimePicker(
                    context: context,
                    initialTime: initialTime ?? TimeOfDay.now(),
                  );
                  if (time != null) {
                    final h = time.hour.toString().padLeft(2, '0');
                    final m = time.minute.toString().padLeft(2, '0');
                    setState(() => _scheduledTime = '$h:$m');
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BİTİŞ TARİHİ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.brutalistBlack,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  '(İsteğe Bağlı)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _showEndDate = !_showEndDate;
                  if (!_showEndDate) {
                    _endDate = null;
                    _endTime = null;
                  }
                });
              },
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
                      color: _showEndDate ? const Color(0xFF0077B6) : Colors.grey,
                      border: Border.all(color: AppColors.brutalistBlack, width: 2),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_showEndDate) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildNeoPicker(
                  text: _endDate ?? 'Tarih',
                  icon: Icons.calendar_today,
                  onTap: () async {
                    final first = _scheduledDate != null ? DateTime.parse(_scheduledDate!) : DateTime.now();
                    final date = await showNeoDatePicker(
                      context: context,
                      initialDate: _endDate != null ? DateTime.parse(_endDate!) : first,
                      firstDate: first,
                      lastDate: DateTime.now().add(const Duration(days: 365*5)),
                    );
                    if (date != null) {
                      setState(() => _endDate = DateFormat('yyyy-MM-dd').format(date));
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNeoPicker(
                  text: _endTime ?? 'Saat',
                  icon: Icons.access_time,
                  onTap: () async {
                    TimeOfDay? initialTime;
                    if (_endTime != null && _endTime!.contains(':')) {
                      final parts = _endTime!.split(':');
                      if (parts.length == 2) {
                        initialTime = TimeOfDay(hour: int.tryParse(parts[0]) ?? 0, minute: int.tryParse(parts[1]) ?? 0);
                      }
                    }
                    final time = await showNeoTimePicker(
                      context: context,
                      initialTime: initialTime ?? TimeOfDay.now(),
                    );
                    if (time != null) {
                      final h = time.hour.toString().padLeft(2, '0');
                      final m = time.minute.toString().padLeft(2, '0');
                      setState(() => _endTime = '$h:$m');
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildNeoPicker({required String text, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.brutalistWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.brutalistBlack, width: 3),
          boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(3, 3))],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.brutalistBlack, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.brutalistBlack),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HEDEF',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: AppColors.brutalistBlack,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Transform.rotate(
                angle: -0.01,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.brutalistWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.brutalistBlack, width: 3),
                    boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(3, 3))],
                  ),
                  child: TextField(
                    controller: _targetController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.brutalistBlack),
                    decoration: const InputDecoration(
                      hintText: 'Hedef... (örn: 5)',
                      hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                      contentPadding: EdgeInsets.all(16),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: Transform.rotate(
                angle: 0.01,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.brutalistWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.brutalistBlack, width: 3),
                    boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(3, 3))],
                  ),
                  child: TextField(
                    controller: _unitController,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.brutalistBlack),
                    decoration: const InputDecoration(
                      hintText: 'Birim (lt, vs.)',
                      hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                      contentPadding: EdgeInsets.all(16),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'TEKRAR SIKLIĞI',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: AppColors.brutalistBlack,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        _EditDaySelector(
          selectedDays: _selectedDays,
          onToggle: (code) => setState(() {
            if (_selectedDays.contains(code)) {
              _selectedDays.remove(code);
            } else {
              _selectedDays.add(code);
              _intervalDays = null;
            }
          })
        ),
        const SizedBox(height: 24),
        const Text(
          'VEYA X GÜNDE BİR:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: AppColors.brutalistBlack,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.brutalistWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.brutalistBlack, width: 3),
            boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(3, 3))],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              value: _intervalDays,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.brutalistBlack),
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.brutalistBlack, fontSize: 16),
              hint: const Text('Seçilmedi', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.brutalistBlack)),
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('Seçilmedi')),
                ...List.generate(30, (i) => DropdownMenuItem<int?>(
                  value: i + 1,
                  child: Text('${i + 1} günde bir tekrarla'),
                )),
              ],
              onChanged: (val) {
                setState(() {
                  _intervalDays = val;
                  if (val != null) _selectedDays.clear();
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _EditDaySelector extends StatelessWidget {
  static const _days = ['PZT', 'SAL', 'ÇAR', 'PER', 'CUM', 'CTS', 'PAZ'];
  static const _codes = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  final Set<String> selectedDays;
  final void Function(String code) onToggle;

  const _EditDaySelector({required this.selectedDays, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - (6 * 8)) / 7;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_days.length, (i) {
            final isSelected = selectedDays.contains(_codes[i]);
            return GestureDetector(
              onTap: () => onToggle(_codes[i]),
              child: Container(
                width: itemWidth,
                height: itemWidth,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryContainer : AppColors.brutalistWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.brutalistBlack, width: 2),
                  boxShadow: isSelected ? const [] : const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(2, 2))],
                ),
                alignment: Alignment.center,
                child: Text(
                  _days[i],
                  style: TextStyle(
                    color: AppColors.brutalistBlack,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            );
          }),
        );
      }
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_new_habit/core/theme/app_colors.dart';
import 'package:my_new_habit/core/theme/app_spacing.dart';
import 'package:my_new_habit/data/models/record_model.dart';

Future<RecordModel?> showEditRecordSheet(
  BuildContext context,
  RecordModel record,
) async {
  return showModalBottomSheet<RecordModel>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: _EditRecordSheet(record: record),
    ),
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
  
  // Todo
  Priority? _selectedPriority;
  DateTime? _dueDate;

  // Event
  String? _scheduledDate;
  String? _scheduledTime;
  String? _endDate;
  String? _endTime;

  // Habit
  Set<String> _selectedDays = {};
  int? _intervalDays;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.record.title);
    
    _selectedPriority = widget.record.priority;
    _dueDate = widget.record.dueDate;
    
    _scheduledDate = widget.record.scheduledDate;
    _scheduledTime = widget.record.scheduledTime;
    _endDate = widget.record.endDate;
    _endTime = widget.record.endTime;
    
    _selectedDays = widget.record.repeatDays.toSet();
    _intervalDays = widget.record.intervalDays;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Düzenle', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'İsim',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              
              if (widget.record.type == RecordType.todo) _buildTodoFields(),
              if (widget.record.type == RecordType.event) _buildEventFields(),
              if (widget.record.type == RecordType.habit) _buildHabitFields(),
              
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    final newRecord = widget.record.copyWith(
                      title: _titleController.text.trim(),
                      priority: _selectedPriority,
                      dueDate: _dueDate,
                      scheduledDate: _scheduledDate,
                      scheduledTime: _scheduledTime,
                      endDate: _endDate,
                      endTime: _endTime,
                      repeatDays: _selectedDays.toList(),
                      intervalDays: _intervalDays,
                    );
                    Navigator.pop(context, newRecord);
                  },
                  child: const Text('Kaydet'),
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
        const SizedBox(height: AppSpacing.md),
        Text('Öncelik', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          children: [
            _PriorityChip(
              label: 'Yüksek',
              color: AppColors.relapseDanger,
              selected: _selectedPriority == Priority.high,
              onSelected: (val) => setState(() => _selectedPriority = val ? Priority.high : null),
            ),
            _PriorityChip(
              label: 'Orta',
              color: AppColors.tertiary,
              selected: _selectedPriority == Priority.medium,
              onSelected: (val) => setState(() => _selectedPriority = val ? Priority.medium : null),
            ),
            _PriorityChip(
              label: 'Düşük',
              color: Colors.blueAccent,
              selected: _selectedPriority == Priority.low,
              onSelected: (val) => setState(() => _selectedPriority = val ? Priority.low : null),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Bitiş Tarihi'),
          trailing: Text(
             _dueDate != null ? DateFormat('d MMM yyyy', 'tr_TR').format(_dueDate!) : 'Seçilmedi',
             style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _dueDate ?? DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365*5)),
            );
            if (date != null) setState(() => _dueDate = date);
          },
        ),
      ],
    );
  }

  Widget _buildEventFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.md),
        _buildDateTimePicker(
          title: 'Başlangıç Tarihi',
          value: _scheduledDate,
          isDate: true,
          onChanged: (val) => setState(() => _scheduledDate = val),
        ),
        _buildDateTimePicker(
          title: 'Başlangıç Saati',
          value: _scheduledTime,
          isDate: false,
          onChanged: (val) => setState(() => _scheduledTime = val),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Divider(),
        const SizedBox(height: AppSpacing.sm),
        _buildDateTimePicker(
          title: 'Bitiş Tarihi',
          value: _endDate,
          isDate: true,
          onChanged: (val) => setState(() => _endDate = val),
        ),
        _buildDateTimePicker(
          title: 'Bitiş Saati',
          value: _endTime,
          isDate: false,
          onChanged: (val) => setState(() => _endTime = val),
        ),
      ],
    );
  }

  Widget _buildDateTimePicker({
    required String title,
    required String? value,
    required bool isDate,
    required Function(String?) onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: Text(value ?? 'Seçilmedi', style: const TextStyle(fontWeight: FontWeight.bold)),
      onTap: () async {
        if (isDate) {
          final initial = value != null ? DateTime.tryParse(value) : null;
          final date = await showDatePicker(
            context: context,
            initialDate: initial ?? DateTime.now(),
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now().add(const Duration(days: 365*5)),
          );
          if (date != null) onChanged(DateFormat('yyyy-MM-dd').format(date));
        } else {
          TimeOfDay? initialTime;
          if (value != null && value.contains(':')) {
            final parts = value.split(':');
            if (parts.length == 2) {
              initialTime = TimeOfDay(hour: int.tryParse(parts[0]) ?? 0, minute: int.tryParse(parts[1]) ?? 0);
            }
          }
          final time = await showTimePicker(
            context: context,
            initialTime: initialTime ?? TimeOfDay.now(),
          );
          if (time != null) {
            final h = time.hour.toString().padLeft(2, '0');
            final m = time.minute.toString().padLeft(2, '0');
            onChanged('$h:$m');
          }
        }
      },
    );
  }

  Widget _buildHabitFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.md),
        Text('Tekrar Sıklığı', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
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
        const SizedBox(height: AppSpacing.md),
        Text('Veya X günde bir:', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              value: _intervalDays,
              isExpanded: true,
              hint: const Text('Seçilmedi'),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_days.length, (i) {
        final isSelected = selectedDays.contains(_codes[i]);
        return GestureDetector(
          onTap: () => onToggle(_codes[i]),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryContainer : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: isSelected ? null : Border.all(color: AppColors.outlineVariant),
            ),
            alignment: Alignment.center,
            child: Text(
              _days[i],
              style: TextStyle(
                color: isSelected ? AppColors.onPrimaryContainer : AppColors.outline,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final Function(bool) onSelected;

  const _PriorityChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      label: Text(label),
      selectedColor: color.withAlpha(50),
      checkmarkColor: color,
      backgroundColor: AppColors.surfaceContainerLow,
      side: BorderSide(color: selected ? color : Colors.transparent),
      onSelected: onSelected,
    );
  }
}

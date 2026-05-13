// Sprint 5: Modal — Alışkanlık Detayları (Neo-Brutalism)

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

Future<({List<String> repeatDays, int? intervalDays, bool goBack})?> showHabitDetailsSheet(
  BuildContext context, {
  List<String> initialRepeatDays = const [],
  int? initialIntervalDays,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _HabitDetailsSheet(
      initialRepeatDays: initialRepeatDays,
      initialIntervalDays: initialIntervalDays,
    ),
  );
}

class _HabitDetailsSheet extends StatefulWidget {
  final List<String> initialRepeatDays;
  final int? initialIntervalDays;

  const _HabitDetailsSheet({
    required this.initialRepeatDays,
    this.initialIntervalDays,
  });

  @override
  State<_HabitDetailsSheet> createState() => _HabitDetailsSheetState();
}

class _HabitDetailsSheetState extends State<_HabitDetailsSheet> {
  /// Yeni alışkanlıkta boş başlangıç → PRD’deki “her gün” ile aynı: tüm günler seçili.
  static const _allWeekdayCodes = [
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
    'SUN',
  ];

  late Set<String> _selectedDays;
  int? _intervalDays;

  @override
  void initState() {
    super.initState();
    if (widget.initialRepeatDays.isEmpty && widget.initialIntervalDays == null) {
      _selectedDays = {..._allWeekdayCodes};
    } else {
      _selectedDays = widget.initialRepeatDays.toSet();
    }
    _intervalDays = widget.initialIntervalDays;
  }

  bool get _isValid => _selectedDays.isNotEmpty || _intervalDays != null;

  void _onSave() {
    Navigator.of(context).pop((repeatDays: _selectedDays.toList(), intervalDays: _intervalDays, goBack: false));
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF8FBFC);
    const brandBlue = Color(0xFF0088CC);

    return Container(
      decoration: const BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: AppColors.brutalistBlack, width: 4)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context, (repeatDays: const <String>[], intervalDays: null, goBack: true)),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.brutalistWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.brutalistBlack, width: 2),
                      boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(2, 2))],
                    ),
                    child: const Icon(Icons.arrow_back, color: AppColors.brutalistBlack),
                  ),
                ),
                // Progress
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
                        width: 24, height: 12,
                        decoration: BoxDecoration(
                          color: brandBlue,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.brutalistBlack, width: 2),
                          boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(2, 2))],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Title
            Transform.rotate(
              angle: -0.02,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE599),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.brutalistBlack, width: 3),
                  boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(3, 3))],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alışkanlık\nDetayları',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, height: 1.1, color: AppColors.brutalistBlack),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Hangi günler bu alışkanlığı yerine getireceksin? Sana en uygun düzeni oluştur.',
                      style: TextStyle(fontSize: 16, color: AppColors.brutalistBlack, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Haftalık Plan
            const Text(
              'Haftalık Plan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.brutalistBlack),
            ),
            const SizedBox(height: 16),
            _DaySelector(
              selectedDays: _selectedDays,
              brandBlue: brandBlue,
              onToggle: (code) => setState(() {
                if (_selectedDays.contains(code)) {
                  _selectedDays.remove(code);
                } else {
                  _selectedDays.add(code);
                  _intervalDays = null;
                }
              }),
            ),
            const SizedBox(height: 32),
            
            // Tekrar Sıklığı
            Transform.rotate(
              angle: -0.02,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.brutalistWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.brutalistBlack, width: 2),
                  boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(6, 6))],
                ),
                child: Transform.rotate(
                  angle: 0.02,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'VEYA X GÜNDE BİR:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.brutalistBlack,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 16),
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
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            // Footer Action
            Transform.rotate(
              angle: 0.02,
              child: GestureDetector(
                onTap: _isValid ? _onSave : null,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _isValid ? brandBlue : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.brutalistBlack, width: 2),
                    boxShadow: _isValid ? const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(6, 6))] : [],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.rotate(
                        angle: -0.02,
                        child: const Text(
                          'Oluştur',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.brutalistWhite),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Transform.rotate(
                        angle: -0.02,
                        child: const Icon(Icons.arrow_forward, color: AppColors.brutalistWhite),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DaySelector extends StatelessWidget {
  static const _days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cts', 'Paz'];
  static const _codes = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  final Set<String> selectedDays;
  final Color brandBlue;
  final void Function(String code) onToggle;

  const _DaySelector({
    required this.selectedDays,
    required this.brandBlue,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: List.generate(_days.length, (i) {
        final isSelected = selectedDays.contains(_codes[i]);
        final rotation = (i % 2 == 0) ? -0.05 : 0.05;
        return GestureDetector(
          onTap: () => onToggle(_codes[i]),
          child: Transform.rotate(
            angle: rotation,
            child: Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? brandBlue : AppColors.brutalistWhite,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.brutalistBlack, width: 2),
                boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(4, 4))],
              ),
              child: Text(
                _days[i],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? AppColors.brutalistWhite : AppColors.brutalistBlack,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

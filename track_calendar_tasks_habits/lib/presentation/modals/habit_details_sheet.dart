import 'package:flutter/material.dart';

import '../../core/theme/record_type_accent.dart';
import '../../core/theme/track_custom_colors.dart';
import '../../core/enums/item_type.dart';
/// 3. adım: Gün & interval seçimi. İkon/renk 4. adımda.
Future<({List<String> repeatDays, int? intervalDays, bool goBack})?>
showHabitDetailsSheet(
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
  const _HabitDetailsSheet({
    required this.initialRepeatDays,
    this.initialIntervalDays,
  });
  final List<String> initialRepeatDays;
  final int? initialIntervalDays;

  @override
  State<_HabitDetailsSheet> createState() => _HabitDetailsSheetState();
}

class _HabitDetailsSheetState extends State<_HabitDetailsSheet> {
  late Set<String> _selectedDays;
  int? _intervalDays;

  @override
  void initState() {
    super.initState();
    _selectedDays = widget.initialRepeatDays.toSet();
    _intervalDays = widget.initialIntervalDays;
  }

  bool get _isValid => _selectedDays.isNotEmpty || _intervalDays != null;

  void _onSave() => Navigator.of(context).pop((
    repeatDays: _selectedDays.toList(),
    intervalDays: _intervalDays,
    goBack: false,
  ));

  @override
  Widget build(BuildContext context) {
    final accent = recordTypeSectionAccent(ItemType.habit);
    final titleStripBg = Color.lerp(accent, Colors.white, 0.52)!;
    return Container(
      decoration: BoxDecoration(
        color: context.scheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: context.track.brutalistInk, width: 4)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context, (
                    repeatDays: const <String>[],
                    intervalDays: null,
                    goBack: true,
                  )),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.track.brutalistSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.track.brutalistInk, width: 2),
                      boxShadow: [BoxShadow(color: context.track.brutalistInk, offset: Offset(2, 2))],
                    ),
                    child: Icon(Icons.arrow_back, color: context.track.brutalistInk),
                  ),
                ),
                // 4 adım göstergesi — 3. aktif
                Row(children: [
                  _stepDot(false), const SizedBox(width: 6),
                  _stepDot(false), const SizedBox(width: 6),
                  _stepDot(true, accent), const SizedBox(width: 6),
                  _stepDot(false),
                ]),
              ],
            ),
            const SizedBox(height: 32),
            Transform.rotate(
              angle: -0.02,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: titleStripBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.track.brutalistInk, width: 3),
                  boxShadow: [BoxShadow(color: context.track.brutalistInk, offset: Offset(3, 3))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Alışkanlık\nDetayları',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, height: 1.1, color: context.track.brutalistInk)),
                    SizedBox(height: 8),
                    Text('Hangi günler bu alışkanlığı yerine getireceksin?',
                        style: TextStyle(fontSize: 16, color: context.track.brutalistInk, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text('Haftalık Plan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: context.track.brutalistInk)),
            const SizedBox(height: 16),
            _DaySelector(selectedDays: _selectedDays, accent: accent,
              onToggle: (code) => setState(() {
                if (_selectedDays.contains(code)) { _selectedDays.remove(code); }
                else { _selectedDays.add(code); _intervalDays = null; }
              }),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.track.brutalistSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.track.brutalistInk, width: 2),
                boxShadow: [BoxShadow(color: context.track.brutalistInk, offset: Offset(6, 6))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('VEYA X GÜNDE BİR:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: context.track.brutalistInk, letterSpacing: 1.0)),
                  const SizedBox(height: 16),
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
                ],
              ),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: _isValid ? _onSave : null,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _isValid ? accent : context.scheme.outline,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.track.brutalistInk, width: 2),
                  boxShadow: _isValid ? [BoxShadow(color: context.track.brutalistInk, offset: Offset(6, 6))] : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Devam Et', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: context.track.brutalistSurface)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: context.track.brutalistSurface),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepDot(bool active, [Color? color]) {
    return Transform.rotate(
      angle: active ? -0.05 : 0,
      child: Container(
        width: active ? 24 : 12, height: 12,
        decoration: BoxDecoration(
          color: active ? (color ?? recordTypeSectionAccent(ItemType.habit)) : context.track.brutalistSurface,
          borderRadius: BorderRadius.circular(active ? 12 : 6),
          border: Border.all(color: context.track.brutalistInk, width: 2),
          boxShadow: active ? [BoxShadow(color: context.track.brutalistInk, offset: Offset(2, 2))] : [],
        ),
      ),
    );
  }
}

class _DaySelector extends StatelessWidget {
  static const _days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cts', 'Paz'];
  static const _codes = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  const _DaySelector({required this.selectedDays, required this.accent, required this.onToggle});
  final Set<String> selectedDays;
  final Color accent;
  final void Function(String) onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12, runSpacing: 16, alignment: WrapAlignment.center,
      children: List.generate(_days.length, (i) {
        final isSelected = selectedDays.contains(_codes[i]);
        return GestureDetector(
          onTap: () => onToggle(_codes[i]),
          child: Transform.rotate(
            angle: i % 2 == 0 ? -0.05 : 0.05,
            child: Container(
              width: 56, height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? accent : context.track.brutalistSurface,
                shape: BoxShape.circle,
                border: Border.all(color: context.track.brutalistInk, width: 2),
                boxShadow: [BoxShadow(color: context.track.brutalistInk, offset: Offset(4, 4))],
              ),
              child: Text(_days[i], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
                color: isSelected ? context.track.brutalistSurface : context.track.brutalistInk)),
            ),
          ),
        );
      }),
    );
  }
}

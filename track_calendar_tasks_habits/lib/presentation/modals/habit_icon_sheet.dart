import 'package:flutter/material.dart';

import '../../core/theme/record_type_accent.dart';
import '../../core/theme/track_custom_colors.dart';
import '../../core/utils/habit_icons.dart';
import '../../core/enums/item_type.dart';
/// 4. adım: İkon & Renk seçimi.
Future<({String iconKey, int iconColor, bool goBack})?>
showHabitIconSheet(
  BuildContext context, {
  String? initialIconKey,
  int? initialIconColor,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _HabitIconSheet(
      initialIconKey: initialIconKey,
      initialIconColor: initialIconColor,
    ),
  );
}

class _HabitIconSheet extends StatefulWidget {
  const _HabitIconSheet({this.initialIconKey, this.initialIconColor});
  final String? initialIconKey;
  final int? initialIconColor;

  @override
  State<_HabitIconSheet> createState() => _HabitIconSheetState();
}

class _HabitIconSheetState extends State<_HabitIconSheet> {
  late String _selectedIconKey;
  late int _selectedIconColor;

  @override
  void initState() {
    super.initState();
    _selectedIconKey = widget.initialIconKey ?? HabitIcons.defaultKey;
    _selectedIconColor = widget.initialIconColor ?? HabitIcons.defaultColor;
  }

  void _onSave() => Navigator.of(context).pop((
    iconKey: _selectedIconKey,
    iconColor: _selectedIconColor,
    goBack: false,
  ));

  @override
  Widget build(BuildContext context) {
    final accent = recordTypeSectionAccent(ItemType.habit);
    final titleStripBg = Color.lerp(accent, Colors.white, 0.52)!;
    final ink = context.track.brutalistInk;
    final surface = context.track.brutalistSurface;
    final iconEntries = HabitIcons.icons.entries.toList();

    return Container(
      decoration: BoxDecoration(
        color: context.scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: ink, width: 4)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Üst bar: geri + adım göstergesi ─────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context, (
                    iconKey: _selectedIconKey,
                    iconColor: _selectedIconColor,
                    goBack: true,
                  )),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ink, width: 2),
                      boxShadow: [BoxShadow(color: ink, offset: const Offset(2, 2))],
                    ),
                    child: Icon(Icons.arrow_back, color: ink),
                  ),
                ),
                // 4 adım — 4. aktif
                Row(children: [
                  _stepDot(context, false, accent),
                  const SizedBox(width: 6),
                  _stepDot(context, false, accent),
                  const SizedBox(width: 6),
                  _stepDot(context, false, accent),
                  const SizedBox(width: 6),
                  _stepDot(context, true, accent),
                ]),
              ],
            ),
            const SizedBox(height: 32),
            // ── Başlık kartı ─────────────────────────────────────────────
            Transform.rotate(
              angle: -0.02,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: titleStripBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ink, width: 3),
                  boxShadow: [BoxShadow(color: ink, offset: const Offset(3, 3))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'İkon & Renk\nSeç',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                        color: ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Alışkanlığını temsil eden ikon ve rengi seç.',
                      style: TextStyle(
                        fontSize: 16,
                        color: ink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // ── Önizleme ────────────────────────────────────────────────
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Color(_selectedIconColor),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ink, width: 3),
                  boxShadow: [BoxShadow(color: ink, offset: const Offset(5, 5))],
                ),
                child: Icon(
                  HabitIcons.resolve(_selectedIconKey),
                  color: ink,
                  size: 44,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // ── İkon seçici ─────────────────────────────────────────────
            Text(
              'İKON SEÇ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: ink,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: iconEntries.map((entry) {
                final isSelected = entry.key == _selectedIconKey;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIconKey = entry.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected ? Color(_selectedIconColor) : surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ink, width: isSelected ? 3 : 2),
                      boxShadow: isSelected
                          ? [BoxShadow(color: ink, offset: const Offset(3, 3))]
                          : [],
                    ),
                    child: Icon(entry.value, color: ink, size: 26),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            // ── Renk seçici ─────────────────────────────────────────────
            Text(
              'RENK SEÇ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: ink,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: HabitIcons.palette.map((colorInt) {
                final isSelected = colorInt == _selectedIconColor;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIconColor = colorInt),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Color(colorInt),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? ink : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: ink, offset: const Offset(3, 3))]
                          : [],
                    ),
                    child: isSelected
                        ? Icon(Icons.check_rounded, color: ink, size: 22)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            // ── Oluştur butonu ───────────────────────────────────────────
            GestureDetector(
              onTap: _onSave,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ink, width: 2),
                  boxShadow: [BoxShadow(color: ink, offset: const Offset(6, 6))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Oluştur',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: surface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.check_rounded, color: surface),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepDot(BuildContext context, bool active, Color accent) {
    final ink = context.track.brutalistInk;
    return Transform.rotate(
      angle: active ? -0.05 : 0,
      child: Container(
        width: active ? 24 : 12,
        height: 12,
        decoration: BoxDecoration(
          color: active ? accent : context.track.brutalistSurface,
          borderRadius: BorderRadius.circular(active ? 12 : 6),
          border: Border.all(color: ink, width: 2),
          boxShadow: active ? [BoxShadow(color: ink, offset: const Offset(2, 2))] : [],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../core/theme/record_type_accent.dart';
import '../core/theme/track_custom_colors.dart';
import '../data/models/record_model.dart';

Future<({String title, int target, String? targetUnit, bool goBack})?>  showNamingModal(
  BuildContext context, {
  required RecordType type,
  String? initialTitle,
  int? initialTarget,
  String? initialTargetUnit,
}) {
  return showModalBottomSheet<({String title, int target, String? targetUnit, bool goBack})>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _NamingSheet(
      type: type,
      initialTitle: initialTitle,
      initialTarget: initialTarget,
      initialTargetUnit: initialTargetUnit,
    ),
  );
}

class _NamingSheet extends StatefulWidget {
  const _NamingSheet({
    required this.type,
    this.initialTitle,
    this.initialTarget,
    this.initialTargetUnit,
  });

  final RecordType type;
  final String? initialTitle;
  final int? initialTarget;
  final String? initialTargetUnit;

  @override
  State<_NamingSheet> createState() => _NamingSheetState();
}

class _NamingSheetState extends State<_NamingSheet> {
  late final TextEditingController _controller;
  late final TextEditingController _targetController;
  late final TextEditingController _unitController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle ?? '');
    _targetController = TextEditingController(text: widget.initialTarget?.toString() ?? '');
    _unitController = TextEditingController(text: widget.initialTargetUnit ?? '');
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _targetController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  bool get _isTitleEmpty => _controller.text.trim().isEmpty;

  // Alışkanlık önerileri: emoji kaldırıldı, "Erken Uyan" çıkarıldı
  List<String> get _suggestions => switch (widget.type) {
    RecordType.habit => ['Su İç 💧', 'Kitap Oku 📚', 'Spor Yap 🏃', 'Meditasyon 🧘'],
    RecordType.event => ['Toplantı 💼', 'Randevu 📅', 'Sinema 🍿', 'Kutlama 🎉'],
    RecordType.todo => ['Alışveriş 🛒', 'Fatura Öde 💳', 'Mail Gönder 📧', 'Evi Temizle 🧹'],
  };

  String get _hintText => switch (widget.type) {
    RecordType.habit => 'Alışkanlık adı...',
    RecordType.event => 'Etkinlik adı...',
    RecordType.todo => 'Yapılacak şeyin adı...',
  };

  /// Öneri tıklandığında başlık + otomatik hedef/birim set eder.
  void _applySuggestion(String raw) {
    // Emojiyi temizle, sade metni al
    final clean = raw.replaceAll(RegExp(r'[^\w\sğüşıöçĞÜŞİÖÇ]'), '').trim();
    _controller.text = clean;

    // Yalnızca habit için otomatik hedef
    if (widget.type == RecordType.habit) {
      final lower = clean.toLowerCase();
      if (lower.contains('su iç') || lower.contains('su ic')) {
        _targetController.text = '5';
        _unitController.text = 'lt';
      } else if (lower.contains('kitap')) {
        _targetController.text = '50';
        _unitController.text = 'sayfa';
      } else if (lower.contains('spor')) {
        _targetController.text = '30';
        _unitController.text = 'dk';
      } else if (lower.contains('meditasyon')) {
        _targetController.text = '10';
        _unitController.text = 'dk';
      }
    }
  }

  void _onContinue() {
    final title = _controller.text.trim();
    if (title.isEmpty) return;
    final target = int.tryParse(_targetController.text.trim()) ?? 100;
    final unit = _unitController.text.trim();
    Navigator.of(context).pop((
      title: title,
      target: target,
      targetUnit: unit.isEmpty ? null : unit,
      goBack: false,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final bgColor = context.scheme.surface;
    final accent = recordTypeSectionAccent(widget.type);
    final titleStripBg = Color.lerp(accent, Colors.white, 0.52)!;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
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
                    onTap: () => Navigator.pop(context, (
                        title: '',
                        target: 100,
                        targetUnit: null,
                        iconKey: null,
                        iconColor: null,
                        goBack: true,
                      )),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.track.brutalistSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.track.brutalistInk, width: 2),
                        boxShadow: [BoxShadow(color: context.track.brutalistInk, offset: Offset(3, 3))],
                      ),
                      child: Icon(Icons.arrow_back, color: context.track.brutalistInk),
                    ),
                  ),
                  Row(
                    children: [
                      _StepDot(active: false, type: widget.type),
                      const SizedBox(width: 6),
                      _StepDot(active: true, color: accent, type: widget.type),
                      const SizedBox(width: 6),
                      _StepDot(active: false, type: widget.type),
                      if (widget.type == RecordType.habit) ...[
                        const SizedBox(width: 6),
                        _StepDot(active: false, type: widget.type),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
                    widget.type == RecordType.habit
                        ? 'ALIŞKANLIĞINA BİR\nİSİM VER!'
                        : widget.type == RecordType.event
                            ? 'ETKİNLİĞİNE BİR\nİSİM VER!'
                            : 'YAPILACAK ŞEYE\nBİR İSİM VER!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: context.track.brutalistInk,
                      height: 1.2,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Transform.rotate(
                angle: 0.02,
                child: Container(
                  decoration: BoxDecoration(
                    color: context.track.brutalistSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.track.brutalistInk, width: 3),
                    boxShadow: [BoxShadow(color: context.track.brutalistInk, offset: Offset(4, 4))],
                  ),
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: context.track.brutalistInk),
                    decoration: InputDecoration(
                      hintText: _hintText,
                      hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                      contentPadding: const EdgeInsets.all(16),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(Icons.flash_on, color: context.track.brutalistInk, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'HIZLI ÖNERİLER',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: context.track.brutalistInk,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _suggestions.asMap().entries.map((e) {
                  final angle = e.key % 2 == 0 ? -0.03 : 0.03;
                  return GestureDetector(
                    onTap: () => _applySuggestion(e.value),
                    child: Transform.rotate(
                      angle: angle,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: context.track.brutalistSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.track.brutalistInk, width: 2),
                          boxShadow: [BoxShadow(color: context.track.brutalistInk, offset: Offset(3, 3))],
                        ),
                        child: Text(
                          e.value,
                          style: TextStyle(fontWeight: FontWeight.bold, color: context.track.brutalistInk),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              if (widget.type == RecordType.habit) ...[
                Text(
                  'HEDEF',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: context.track.brutalistInk,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _BrutalistTextField(
                        controller: _targetController,
                        hintText: 'Hedef... (örn: 5)',
                        keyboardType: TextInputType.number,
                        angle: -0.01,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: _BrutalistTextField(
                        controller: _unitController,
                        hintText: 'Birim (lt, vs.)',
                        angle: 0.01,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
              Transform.rotate(
                angle: 0.02,
                child: GestureDetector(
                  onTap: _isTitleEmpty ? null : _onContinue,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _isTitleEmpty ? context.scheme.outline : accent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.track.brutalistInk, width: 3),
                      boxShadow: _isTitleEmpty
                          ? []
                          : [BoxShadow(color: context.track.brutalistInk, offset: Offset(4, 4))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'DEVAM ET',
                          style: TextStyle(
                            color: _isTitleEmpty ? Colors.white70 : context.track.brutalistSurface,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          color: _isTitleEmpty ? Colors.white70 : context.track.brutalistSurface,
                        ),
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
}

class _StepDot extends StatelessWidget {
  const _StepDot({this.active = false, this.color, required this.type});
  final bool active;
  final Color? color;
  final RecordType type;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: active ? -0.05 : 0,
      child: Container(
        width: active ? 20 : 12,
        height: 12,
        decoration: BoxDecoration(
          color: active
              ? (color ?? recordTypeSectionAccent(type))
              : context.track.brutalistSurface,
          borderRadius: BorderRadius.circular(active ? 12 : 6),
          border: Border.all(color: context.track.brutalistInk, width: 2),
        ),
      ),
    );
  }
}

class _BrutalistTextField extends StatelessWidget {
  const _BrutalistTextField({
    required this.controller,
    required this.hintText,
    this.angle = 0.0,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hintText;
  final double angle;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        decoration: BoxDecoration(
          color: context.track.brutalistSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.track.brutalistInk, width: 3),
          boxShadow: [BoxShadow(color: context.track.brutalistInk, offset: Offset(3, 3))],
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.track.brutalistInk),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            contentPadding: const EdgeInsets.all(16),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

// Sprint 5: Modal — Adım 2: "Buna ne ad verelim?" + hızlı öneri chip'leri (Neo-Brutalism)

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../data/models/record_model.dart';

/// Ekleme akışının 2. adımı: isim girişi ve hızlı öneri chip'leri.
Future<({String title, int target, String? targetUnit, bool goBack})?> showNamingModal(
  BuildContext context, {
  required RecordType type,
  String? initialTitle,
}) {
  return showModalBottomSheet<({String title, int target, String? targetUnit, bool goBack})>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _NamingSheet(type: type, initialTitle: initialTitle),
  );
}

class _NamingSheet extends StatefulWidget {
  final RecordType type;
  final String? initialTitle;

  const _NamingSheet({required this.type, this.initialTitle});

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
    _targetController = TextEditingController();
    _unitController = TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _targetController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  bool get _isTitleEmpty => _controller.text.trim().isEmpty;

  List<String> get _suggestions => switch (widget.type) {
    RecordType.habit => [
      'Su İç 💧',
      'Kitap Oku 📚',
      'Spor Yap 🏃',
      'Meditasyon 🧘',
      'Erken Uyan ⏰',
    ],
    RecordType.event => ['Toplantı 💼', 'Randevu 📅', 'Sinema 🍿', 'Kutlama 🎉'],
    RecordType.todo => ['Alışveriş 🛒', 'Fatura Öde 💳', 'Mail Gönder 📧', 'Evi Temizle 🧹'],
  };

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    
    // HTML tasarımdaki renkler:
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
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context, (title: '', target: 100, targetUnit: null, goBack: true)),
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
                  // Progress indicator (Step 2)
                  Row(
                    children: [
                      Container(
                        width: 16, height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.brutalistWhite,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.brutalistBlack, width: 2),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Transform.rotate(
                        angle: -0.05,
                        child: Container(
                          width: 24, height: 16,
                          decoration: BoxDecoration(
                            color: blueBtnBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.brutalistBlack, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 16, height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.brutalistWhite,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.brutalistBlack, width: 2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Title Card
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
                    widget.type == RecordType.habit ? 'ALIŞKANLIĞINA BİR\nİSİM VER!' 
                    : widget.type == RecordType.event ? 'ETKİNLİĞİNE BİR\nİSİM VER!' 
                    : 'GÖREVİNE BİR\nİSİM VER!',
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
              
              // Input
              Transform.rotate(
                angle: 0.02,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.brutalistWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.brutalistBlack, width: 3),
                    boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(4, 4))],
                  ),
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.brutalistBlack),
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
              
              // Quick Suggestions
              Row(
                children: [
                  const Icon(Icons.flash_on, color: AppColors.brutalistBlack, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'HIZLI ÖNERİLER',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.brutalistBlack,
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
                  final index = e.key;
                  final s = e.value;
                  // Alternate rotation
                  final rotation = index % 2 == 0 ? -0.03 : 0.03;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        // Emoji ve metin önerisini tam olarak kopyala
                        _controller.text = s.replaceAll(RegExp(r'[^\w\sğüşıöçĞÜŞİÖÇ]'), '').trim();
                        
                        if (widget.type == RecordType.habit) {
                          if (s.contains('Su İç')) {
                            _targetController.text = '5';
                            _unitController.text = 'lt';
                          } else if (s.contains('Kitap Oku')) {
                            _targetController.text = '30';
                            _unitController.text = 'sayfa';
                          } else if (s.contains('Spor Yap')) {
                            _targetController.text = '45';
                            _unitController.text = 'dk';
                          } else if (s.contains('Meditasyon')) {
                            _targetController.text = '15';
                            _unitController.text = 'dk';
                          } else if (s.contains('Erken Uyan')) {
                            _targetController.text = '';
                            _unitController.text = '';
                          }
                        }
                      });
                    },
                    child: Transform.rotate(
                      angle: rotation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.brutalistWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.brutalistBlack, width: 2),
                          boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(3, 3))],
                        ),
                        child: Text(
                          s,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.brutalistBlack),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              
              if (widget.type == RecordType.habit) ...[
                const Text(
                  'HEDEF',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.brutalistBlack,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
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
                const SizedBox(height: 32),
              ],
              
              // Continue button
              Transform.rotate(
                angle: 0.02,
                child: GestureDetector(
                  onTap: _isTitleEmpty ? null : _onContinue,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _isTitleEmpty ? Colors.grey : blueBtnBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.brutalistBlack, width: 3),
                      boxShadow: _isTitleEmpty ? const [] : const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(4, 4))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'DEVAM ET',
                          style: TextStyle(
                            color: _isTitleEmpty ? Colors.white70 : AppColors.brutalistWhite,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: _isTitleEmpty ? Colors.white70 : AppColors.brutalistWhite),
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

  String get _hintText => switch (widget.type) {
    RecordType.habit => 'Alışkanlık adı...',
    RecordType.event => 'Etkinlik adı...',
    RecordType.todo => 'Görev adı...',
  };

  void _onContinue() {
    final title = _controller.text.trim();
    if (title.isEmpty) return;
    final targetStr = _targetController.text.trim();
    final target = int.tryParse(targetStr) ?? 100;
    final targetUnit = _unitController.text.trim();
    Navigator.of(context).pop((title: title, target: target, targetUnit: targetUnit.isEmpty ? null : targetUnit, goBack: false));
  }
}

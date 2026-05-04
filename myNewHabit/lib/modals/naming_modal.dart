// Sprint 2: Modal — Adım 2: "Buna ne ad verelim?" + hızlı öneri chip'leri

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../data/models/record_model.dart';

/// Ekleme akışının 2. adımı: isim girişi ve hızlı öneri chip'leri.
///
/// [type] seçilen kayıt tipine göre önerileri değiştirir.
/// [initialTitle] düzenleme modunda mevcut değeri doldurur.
Future<String?> showNamingModal(
  BuildContext context, {
  required RecordType type,
  String? initialTitle,
}) {
  return showModalBottomSheet<String>(
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

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> get _suggestions => switch (widget.type) {
    RecordType.habit => [
      'Sabah Koşusu',
      'Kitap Oku',
      'Su İç',
      'Meditasyon',
      'Egzersiz',
    ],
    RecordType.event => ['Toplantı', 'Randevu', 'Sinema', 'Kutlama'],
    RecordType.todo => [
      'Alışveriş',
      'Fatura Öde',
      'Mail Gönder',
      'Evi Temizle',
    ],
  };

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return GestureDetector(
      // Klavyeyi kapat — 03-clean-code kuralı
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          AppSpacing.marginMobile,
          AppSpacing.sm,
          AppSpacing.marginMobile,
          AppSpacing.cardPadding + bottomPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: _DragHandle()),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: Text(
                'Adım 2',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primaryContainer,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Center(
              child: Text(
                'Buna ne ad verelim?',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: _hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  borderSide: const BorderSide(
                    color: AppColors.primaryContainer,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  borderSide: const BorderSide(
                    color: AppColors.primaryContainer,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.smMd),
            _SuggestionChips(
              suggestions: _suggestions,
              onSelected: (s) => setState(() => _controller.text = s),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              height: AppSpacing.buttonHeight,
              child: ElevatedButton(
                onPressed: _onContinue,
                child: const Text('Devam Et'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _hintText => switch (widget.type) {
    RecordType.habit => 'Örn: Sabah Koşusu...',
    RecordType.event => 'Örn: Toplantı...',
    RecordType.todo => 'Örn: Alışveriş...',
  };

  void _onContinue() {
    final title = _controller.text.trim();
    if (title.isEmpty) return;
    Navigator.of(context).pop(title);
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
    );
  }
}

class _SuggestionChips extends StatelessWidget {
  final List<String> suggestions;
  final void Function(String) onSelected;

  const _SuggestionChips({required this.suggestions, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: suggestions
          .map(
            (s) => ActionChip(
              label: Text(s),
              onPressed: () => onSelected(s),
              backgroundColor: AppColors.surfaceContainer,
            ),
          )
          .toList(),
    );
  }
}

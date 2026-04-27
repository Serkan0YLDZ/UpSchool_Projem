// Sprint 2: Modal — Kötü Alışkanlık (sadece isim + kaydet)

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Kötü alışkanlık ekleme sheet'i.
///
/// Kullanıcı sadece isim girer; sistem otomatik sayaç başlatır (Sprint 4).
/// Null dönerse kullanıcı iptal etmiştir.
Future<String?> showQuitSheet(
  BuildContext context, {
  String? initialTitle,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _QuitSheet(initialTitle: initialTitle),
  );
}

class _QuitSheet extends StatefulWidget {
  final String? initialTitle;

  const _QuitSheet({this.initialTitle});

  @override
  State<_QuitSheet> createState() => _QuitSheetState();
}

class _QuitSheetState extends State<_QuitSheet> {
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

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return GestureDetector(
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
          children: [
            const _DragHandle(),
            const SizedBox(height: AppSpacing.md),
            const _Header(),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Örn: Sigara, Sosyal Medya...',
                prefixIcon: const Icon(
                  Icons.block_rounded,
                  color: AppColors.relapseDanger,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  borderSide: const BorderSide(
                    color: AppColors.relapseDanger,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  borderSide: BorderSide(
                    color: AppColors.relapseDanger.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  borderSide: const BorderSide(
                    color: AppColors.relapseDanger,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.smMd),
            _InfoNote(),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              height: AppSpacing.buttonHeight,
              child: ElevatedButton(
                onPressed: _onSave,
                child: const Text('Kaydet'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSave() {
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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '🚫',
          style: const TextStyle(fontSize: 40),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Bırakmak istediğin\nalışkanlık nedir?',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ],
    );
  }
}

class _InfoNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.smMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Sistem otomatik olarak kaçınılan gün sayacı başlatır.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

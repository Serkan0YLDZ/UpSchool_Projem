import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/track_custom_colors.dart';
import '../../../core/widgets/brutalist_container.dart';

Future<void> showProfileEmailSignInSheet(
  BuildContext context, {
  required Future<void> Function(String email, String password) onSignIn,
}) {
  final ink = context.track.brutalistInk;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: ink.withValues(alpha: 0.35),
    builder: (sheetContext) => _EmailSignInSheetBody(onSignIn: onSignIn),
  );
}

class _EmailSignInSheetBody extends StatefulWidget {
  const _EmailSignInSheetBody({required this.onSignIn});
  final Future<void> Function(String email, String password) onSignIn;

  @override
  State<_EmailSignInSheetBody> createState() => _EmailSignInSheetBodyState();
}

class _EmailSignInSheetBodyState extends State<_EmailSignInSheetBody> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await widget.onSignIn(_emailCtrl.text, _passwordCtrl.text);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  double _scrollBottomPadding(MediaQueryData media) {
    final keyboard = media.viewInsets.bottom;
    if (keyboard > 0) return AppSpacing.md;
    return AppSpacing.mainShellBottomNavHeight +
        media.padding.bottom +
        AppSpacing.lg;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final scrollBottom = _scrollBottomPadding(media);
    final maxH = (media.size.height - media.padding.vertical) * 0.92;
    final scheme = context.scheme;
    final track = context.track;
    final ink = track.brutalistInk;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxH),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.marginMobile,
              AppSpacing.sm,
              AppSpacing.marginMobile,
              scrollBottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppSpacing.smMd),
                    decoration: BoxDecoration(
                      color: ink,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                BrutalistContainer(
                  rotatedOffset: 0.35,
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: scheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusSm,
                                ),
                                border: Border.all(color: ink, width: 3),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.mail_rounded,
                                color: scheme.onSurface,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                'E-posta ile giriş',
                                style: AppTypography.headlineSm,
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              style: IconButton.styleFrom(
                                foregroundColor: scheme.onSurface,
                                side: BorderSide(color: ink, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusSm,
                                  ),
                                ),
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close_rounded, size: 22),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'E-posta',
                            hintText: 'ornek@posta.com',
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'E-posta gerekli';
                            }
                            if (!v.contains('@')) return 'Geçerli bir e-posta gir';
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.smMd),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) {
                            if (!_submitting) _submit();
                          },
                          decoration: const InputDecoration(labelText: 'Şifre'),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Şifre gerekli' : null,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Opacity(
                          key: const ValueKey('email_sheet_submit'),
                          opacity: _submitting ? 0.55 : 1,
                          child: BrutalistContainer(
                            onTap: _submitting ? null : _submit,
                            backgroundColor: scheme.primaryContainer,
                            borderRadius: AppSpacing.radiusFull,
                            borderWidth: 3,
                            shadowOffset: 5,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.cardPadding,
                              vertical: AppSpacing.md,
                            ),
                            child: Center(
                              child: _submitting
                                  ? SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: scheme.onPrimary,
                                      ),
                                    )
                                  : Text(
                                      'Giriş yap',
                                      style: AppTypography.labelLg.copyWith(
                                        color: scheme.onPrimary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Sunucu henüz yok; demo giriş.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySm.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

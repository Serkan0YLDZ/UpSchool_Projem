import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/track_custom_colors.dart';
import '../../core/widgets/brutalist_container.dart';
import '../../providers/auth_session_provider.dart';
import '../../providers/sync_status_provider.dart';
import 'widgets/profile_benefits_card.dart';
import 'widgets/profile_cloud_sync_card.dart';
import 'widgets/profile_email_sign_in_sheet.dart';
import 'widgets/profile_sign_in_row.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static String _methodLabel(AuthMethod m) => switch (m) {
    AuthMethod.google => 'Google',
    AuthMethod.apple => 'Apple',
    AuthMethod.email => 'E-posta',
  };

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthSessionProvider>();
    final sync = context.watch<SyncStatusProvider>();
    final scheme = context.scheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(
          'PROFİL',
          style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.marginMobile,
                vertical: AppSpacing.md,
              ),
              child: auth.isAuthenticated
                  ? _SignedInBody(auth: auth)
                  : _GuestBody(auth: auth),
            ),
            if (auth.isBusy || sync.isBusy)
              Container(
                height: 3,
                width: double.infinity,
                color: scheme.primaryContainer,
              ),
          ],
        ),
      ),
    );
  }
}

class _GuestBody extends StatelessWidget {
  const _GuestBody({required this.auth});
  final AuthSessionProvider auth;

  void _snack(BuildContext context, String message) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: context.track.brutalistInk,
        behavior: SnackBarBehavior.floating,
      ));

  @override
  Widget build(BuildContext context) {
    final busy = auth.isBusy;
    final scheme = context.scheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Merhaba!',
          style: AppTypography.headlineMd.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Hesabın yok veya giriş yapmadın. İstersen misafir olarak devam edebilirsin.',
          style: AppTypography.bodyMd.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Giriş yap',
          style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: AppSpacing.smMd),
        ProfileSignInRow(
          label: 'Google ile devam et',
          leading: const GoogleSignInLeading(),
          rotatedOffset: 0.6,
          onTap: busy
              ? null
              : () async {
                  await context.read<AuthSessionProvider>().signInWithGoogle();
                  if (!context.mounted) return;
                  final a = context.read<AuthSessionProvider>();
                  final msg = a.errorMessage;
                  if (msg != null) {
                    _snack(context, msg);
                    a.clearError();
                  }
                },
        ),
        const SizedBox(height: AppSpacing.smMd),
        ProfileSignInRow(
          label: 'Apple ile devam et',
          leading: const AppleSignInLeading(),
          backgroundColor: Colors.white,
          rotatedOffset: -0.5,
          onTap: busy
              ? null
              : () async {
                  await context.read<AuthSessionProvider>().signInWithApple();
                  if (!context.mounted) return;
                  final a = context.read<AuthSessionProvider>();
                  final msg = a.errorMessage;
                  if (msg != null) {
                    _snack(context, msg);
                    a.clearError();
                  }
                },
        ),
        const SizedBox(height: AppSpacing.smMd),
        ProfileSignInRow(
          label: 'E-posta ile devam et',
          leading: _EmailLeading(),
          rotatedOffset: 0.4,
          onTap: busy
              ? null
              : () {
                  showProfileEmailSignInSheet(
                    context,
                    onSignIn: (email, password) => context
                        .read<AuthSessionProvider>()
                        .signInWithEmail(email: email, password: password),
                  ).then((_) async {
                    if (!context.mounted) return;
                    final a = context.read<AuthSessionProvider>();
                    if (a.isAuthenticated) {
                      final msg = a.errorMessage;
                      if (msg != null) {
                        _snack(context, msg);
                        a.clearError();
                      }
                    }
                  });
                },
        ),
        const SizedBox(height: AppSpacing.xl),
        const ProfileBenefitsCard(),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _EmailLeading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final ink = context.track.brutalistInk;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: ink, width: 2.5),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.mail_rounded, color: scheme.onSurface, size: 22),
    );
  }
}

class _SignedInBody extends StatelessWidget {
  const _SignedInBody({required this.auth});
  final AuthSessionProvider auth;

  Future<void> _confirmSignOut(BuildContext context) async {
    final scheme = context.scheme;
    final track = context.track;
    
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          side: BorderSide(color: track.brutalistInk, width: 3),
        ),
        title: Text(
          'Çıkış yap?',
          style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w900),
        ),
        content: Text(
          'Oturumu kapatıyorsun. Verilerin bu cihazda kalmaya devam eder; bulut senkronu aktif olunca tekrar giriş gerekir.',
          style: AppTypography.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('VAZGEÇ', style: AppTypography.labelLg.copyWith(color: track.brutalistInk)),
          ),
          BrutalistContainer(
            onTap: () => Navigator.pop(ctx, true),
            backgroundColor: scheme.error,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            shadowOffset: 4,
            borderWidth: 2,
            child: const Text(
              'ÇIKIŞ YAP',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
    if (go == true && context.mounted) {
      await context.read<AuthSessionProvider>().signOut();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Başarıyla çıkış yapıldı.'),
            backgroundColor: track.brutalistInk,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final track = context.track;
    final email = auth.email ?? 'Kullanıcı';
    final initial = email.isNotEmpty ? email[0].toUpperCase() : '?';
    final method = auth.method;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BrutalistContainer(
          backgroundColor: scheme.surfaceContainerLowest,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(color: track.brutalistInk, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: track.brutalistInk,
                      offset: const Offset(3, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: AppTypography.headlineMd.copyWith(
                    color: scheme.onPrimary,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      email,
                      style: AppTypography.headlineSm.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (method != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Yöntem: ${ProfileScreen._methodLabel(method)}',
                        style: AppTypography.bodySm.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const ProfileCloudSyncCard(),
        const SizedBox(height: AppSpacing.md),
        BrutalistContainer(
          backgroundColor: track.brutalistSurface,
          rotatedOffset: 0.5,
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Row(
            children: [
              Icon(
                Icons.bar_chart_rounded,
                size: 40,
                color: scheme.primaryContainer,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grafikler ve özetler',
                      style: AppTypography.labelLg.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Tamamlanma eğrisi, seri özeti ve haftalık görünüm gibi grafikler hesabınla eşlendiğinde burada listelenecek.',
                      style: AppTypography.bodySm.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        BrutalistContainer(
          onTap: auth.isBusy ? null : () => _confirmSignOut(context),
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Center(
            child: Text(
              'ÇIKIŞ YAP',
              style: AppTypography.labelLg.copyWith(
                color: scheme.error,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}


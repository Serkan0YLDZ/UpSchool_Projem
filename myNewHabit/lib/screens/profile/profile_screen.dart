// Profil — mock giriş ve tema uyumlu içerik (Sprint 5+).

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/brutalist_container.dart';
import '../../providers/auth_session_provider.dart';
import '../../providers/sync_status_provider.dart';
import 'widgets/profile_benefits_card.dart';
import 'widgets/profile_cloud_sync_card.dart';
import 'widgets/profile_email_sign_in_sheet.dart';
import 'widgets/profile_sign_in_row.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static String _methodLabel(AuthMethod m) {
    return switch (m) {
      AuthMethod.google => 'Google',
      AuthMethod.apple => 'Apple',
      AuthMethod.email => 'E-posta',
    };
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthSessionProvider>();
    final sync = context.watch<SyncStatusProvider>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Profil', style: AppTypography.headlineSm),
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
                color: AppColors.primaryContainer,
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

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final busy = auth.isBusy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Merhaba!',
          style: AppTypography.headlineMd,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Hesabın yok veya giriş yapmadın. İstersen misafir olarak devam edebilirsin.',
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Giriş yap',
          style: AppTypography.headlineSm,
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
          backgroundColor: AppColors.surfaceContainerLow,
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
                    onSignIn: (email, password) =>
                        context.read<AuthSessionProvider>().signInWithEmail(
                              email: email,
                              password: password,
                            ),
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
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.brutalistBlack, width: 2.5),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.mail_rounded,
        color: AppColors.onSurface,
        size: 22,
      ),
    );
  }
}

class _SignedInBody extends StatelessWidget {
  const _SignedInBody({required this.auth});

  final AuthSessionProvider auth;

  Future<void> _confirmSignOut(BuildContext context) async {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Çıkış yap', style: AppTypography.headlineSm),
        content: Text(
          'Oturumu kapatıyorsun. Veriler bu cihazda kalmaya devam eder; bulut senkronu aktif olunca tekrar giriş gerekir.',
          style: AppTypography.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Çıkış yap'),
          ),
        ],
      ),
    );
    if (go == true && context.mounted) {
      await context.read<AuthSessionProvider>().signOut();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Çıkış yapıldı.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = auth.email ?? 'Kullanıcı';
    final initial = email.isNotEmpty ? email[0].toUpperCase() : '?';
    final method = auth.method;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.primaryContainer,
              child: Text(
                initial,
                style: AppTypography.headlineMd.copyWith(
                  color: AppColors.onPrimary,
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
                    style: AppTypography.headlineSm.copyWith(fontSize: 18),
                  ),
                  if (method != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Giriş: ${ProfileScreen._methodLabel(method)}',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const ProfileCloudSyncCard(),
        const SizedBox(height: AppSpacing.md),
        BrutalistContainer(
          backgroundColor: AppColors.surfaceContainerLow,
          rotatedOffset: 0.5,
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Row(
            children: [
              Icon(
                Icons.bar_chart_rounded,
                size: 40,
                color: AppColors.primaryContainer,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grafikler ve özetler',
                      style: AppTypography.labelLg.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Tamamlanma eğrisi, seri özeti ve haftalık görünüm gibi grafikler hesabınla eşlendiğinde burada listelenecek.',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          height: AppSpacing.buttonHeight,
          child: OutlinedButton(
            onPressed: auth.isBusy
                ? null
                : () => _confirmSignOut(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error, width: 2),
            ),
            child: Text(
              'Çıkış yap',
              style: AppTypography.labelLg.copyWith(color: AppColors.error),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

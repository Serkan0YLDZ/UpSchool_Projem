// Sprint 1: Core widget — Yeniden kullanılabilir buton
// Kural: Fonksiyon widget yerine private sınıf; const zorunlu.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Uygulamada kullanılan standart buton.
///
/// [variant] ile birincil, ikincil veya tehlike stili seçilir.
/// Her tıklamada hafif haptic geri bildirim verilir.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: AppSpacing.buttonHeight,
      child: switch (variant) {
        AppButtonVariant.primary => _PrimaryButton(
            label: label,
            onPressed: _wrappedCallback,
            icon: icon,
            isLoading: isLoading,
          ),
        AppButtonVariant.secondary => _SecondaryButton(
            label: label,
            onPressed: _wrappedCallback,
            icon: icon,
            isLoading: isLoading,
          ),
        AppButtonVariant.danger => _DangerButton(
            label: label,
            onPressed: _wrappedCallback,
            icon: icon,
            isLoading: isLoading,
          ),
      },
    );
  }

  VoidCallback? get _wrappedCallback {
    if (onPressed == null || isLoading) return null;
    return () {
      HapticFeedback.lightImpact();
      onPressed!();
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────

enum AppButtonVariant { primary, secondary, danger }

// ─────────────────────────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: _ButtonContent(label: label, icon: icon, isLoading: isLoading),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: _ButtonContent(label: label, icon: icon, isLoading: isLoading),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DangerButton extends StatelessWidget {
  const _DangerButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.error,
        foregroundColor: AppColors.onError,
      ),
      child: _ButtonContent(label: label, icon: icon, isLoading: isLoading),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppColors.onPrimary,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: AppTypography.labelLg),
        ],
      );
    }

    return Text(label, style: AppTypography.labelLg);
  }
}

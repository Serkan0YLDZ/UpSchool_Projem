// Sprint 3: Ana Sayfa & Takvim — QuitCard (US-305, US-307)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/completion_model.dart';
import '../../../data/models/record_model.dart';
import '../../../providers/completion_provider.dart';
import '../../../providers/record_provider.dart';

/// "Bırakılanlar" bölümündeki kart.
///
/// Gün sayacı: kaç gündür yapılmadığını hesaplar.
/// "Yaptım (Sıfırla)" butonu sayacı 0'a sıfırlar ve relapsed işaretler.
class QuitCard extends StatelessWidget {
  const QuitCard({
    super.key,
    required this.record,
    required this.selectedDate,
  });

  final RecordModel record;
  final String selectedDate;

  @override
  Widget build(BuildContext context) {
    return Consumer<CompletionProvider>(
      builder: (context, provider, _) {
        final completion = provider.completionFor(record.id);
        final hasRelapsed =
            completion?.status == CompletionStatus.relapsed;
        return _QuitCardBody(
          record: record,
          hasRelapsed: hasRelapsed,
          onRelapse: () => _handleRelapse(context, provider),
          onLongPress: () => _showDeleteDialog(context),
        );
      },
    );
  }
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.delete_forever, color: AppColors.relapseDanger, size: 40),
                const SizedBox(height: 16),
                Text(
                  'Bu bırakılan kaydı silmek istediğine emin misin?',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Vazgeç'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.relapseDanger,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          final provider = context.read<RecordProvider>();
                          await provider.deleteRecord(record.id);
                        },
                        child: const Text('Sil'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleRelapse(
    BuildContext context,
    CompletionProvider provider,
  ) async {
    // PRD: "Yaptım" basılırsa sayaç sıfırlanır — medium impact geri bildirim.
    await HapticFeedback.mediumImpact();
    await provider.markRelapsed(record.id, selectedDate);
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _QuitCardBody extends StatelessWidget {
  const _QuitCardBody({
    required this.record,
    required this.hasRelapsed,
    required this.onRelapse,
    required this.onLongPress,
  });

  final RecordModel record;
  final bool hasRelapsed;
  final VoidCallback onRelapse;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final dayCount = _daysSinceCreated();

    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border(
            left: BorderSide(
              // Relapse olmuşsa kırmızı, yoksa başarı yeşili tonunda primary
              color: hasRelapsed ? AppColors.relapseDanger : AppColors.primary,
              width: 4,
            ),
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.ambientShadow,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _IconBubble(icon: record.icon),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _QuitInfo(
                title: record.title,
                dayCount: hasRelapsed ? 0 : dayCount,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _RelapseButton(
              hasRelapsed: hasRelapsed,
              onTap: hasRelapsed ? null : onRelapse,
            ),
          ],
        ),
      ),
    );
  }

  /// Oluşturulma tarihinden bugüne kaç gün geçtiğini hesaplar.
  ///
  /// Sprint 4'te StreakService.getDaysSinceLastRelapse() ile değiştirilecek.
  int _daysSinceCreated() {
    final today = DateTime.now();
    final created = DateTime(
      record.createdAt.year,
      record.createdAt.month,
      record.createdAt.day,
    );
    final todayDate = DateTime(today.year, today.month, today.day);
    return todayDate.difference(created).inDays;
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _IconBubble extends StatelessWidget {
  const _IconBubble({required this.icon});

  final String? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainer,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(icon ?? '🚫', style: const TextStyle(fontSize: 20)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _QuitInfo extends StatelessWidget {
  const _QuitInfo({required this.title, required this.dayCount});

  final String title;
  final int dayCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurface,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const Text('🔥', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 4),
            Text(
              dayCount == 0 ? 'Sıfırlandı' : '$dayCount. Gün',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: dayCount == 0
                        ? AppColors.relapseDanger
                        : AppColors.streakFire,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _RelapseButton extends StatelessWidget {
  const _RelapseButton({required this.hasRelapsed, required this.onTap});

  final bool hasRelapsed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = hasRelapsed
        ? AppColors.surfaceContainerHigh
        : AppColors.relapseDanger;
    final fg = hasRelapsed ? AppColors.onSurfaceVariant : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          hasRelapsed ? 'Sıfırlandı' : 'Sıfırla',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

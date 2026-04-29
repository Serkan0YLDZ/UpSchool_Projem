// Sprint 3: Ana Sayfa & Takvim — HabitCard (US-303, US-304, US-306)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/record_model.dart';
import '../../../providers/completion_provider.dart';
import '../../../providers/record_provider.dart';

/// Rutin alışkanlık kartı.
///
/// Sol kenar: öncelik rengi (high=primary, medium=tertiary, low=outlineVariant).
/// Sağ: AnimatedOpacity checkbox ile tamamlama toggle.
/// Seri rozeti: 🔥 gün sayısı (Sprint 4'te streak hesabı entegre edilecek).
class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.record,
    required this.selectedDate,
  });

  final RecordModel record;
  final String selectedDate;

  @override
  Widget build(BuildContext context) {
    return Consumer<CompletionProvider>(
      builder: (context, completionProvider, _) {
        final isDone = completionProvider.isDone(record.id);
        return _CardBody(
          record: record,
          isDone: isDone,
          onToggle: () => _handleToggle(context, completionProvider, isDone),
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
                  'Bu alışkanlığı silmek istediğine emin misin?',
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

  Future<void> _handleToggle(
    BuildContext context,
    CompletionProvider provider,
    bool isDone,
  ) async {
    await HapticFeedback.lightImpact();
    if (isDone) {
      await provider.undoCompletion(record.id);
    } else {
      await provider.markDone(record.id, selectedDate);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────


class _CardBody extends StatelessWidget {
  const _CardBody({
    required this.record,
    required this.isDone,
    required this.onToggle,
    required this.onLongPress,
  });

  final RecordModel record;
  final bool isDone;
  final VoidCallback onToggle;

  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final borderColor = _priorityColor(record.priority);

    return Opacity(
      opacity: isDone ? 0.55 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border(
            left: BorderSide(color: borderColor, width: 4),
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.ambientShadow,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onToggle,
            onLongPress: onLongPress,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  _IconBubble(icon: record.icon),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: _TitleArea(record: record, isDone: isDone)),
                  const SizedBox(width: AppSpacing.sm),
                  _CheckCircle(isDone: isDone),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _priorityColor(Priority? priority) {
    switch (priority) {
      case Priority.high:
        return AppColors.primary;
      case Priority.medium:
        return AppColors.tertiary;
      case Priority.low:
      case null:
        return AppColors.outlineVariant;
    }
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
      child: Text(
        icon ?? '✨',
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _TitleArea extends StatelessWidget {
  const _TitleArea({required this.record, required this.isDone});

  final RecordModel record;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          record.title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurface,
                decoration: isDone ? TextDecoration.lineThrough : null,
                decorationColor: AppColors.onSurface.withValues(alpha: 0.4),
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        // Streak rozeti — Sprint 4'te gerçek veri entegre edilecek.
        const SizedBox(height: 2),
        const _StreakBadge(days: 0),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// 🔥 streak rozeti. Sprint 4'te StreakService'ten gerçek veri alacak.
class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    if (days == 0) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🔥', style: TextStyle(fontSize: 12)),
        const SizedBox(width: 2),
        Text(
          '$days Gün',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.streakFire,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CheckCircle extends StatelessWidget {
  const _CheckCircle({required this.isDone});

  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isDone ? AppColors.primary : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDone ? AppColors.primary : AppColors.outlineVariant,
          width: 2,
        ),
      ),
      child: isDone
          ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
          : null,
    );
  }
}

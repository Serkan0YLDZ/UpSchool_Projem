// Sprint 3: Ana Sayfa & Takvim — HabitCard (US-303, US-304, US-306)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/record_model.dart';
import '../../../providers/completion_provider.dart';
import '../../../providers/record_provider.dart';
import '../../../modals/edit_record_sheet.dart';

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

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: const Text('Düzenle'),
              onTap: () async {
                Navigator.pop(ctx);
                final updated = await showEditRecordSheet(context, record);
                if (updated != null && context.mounted) {
                  context.read<RecordProvider>().updateRecord(updated);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.relapseDanger),
              title: const Text(
                'Sil',
                style: TextStyle(color: AppColors.relapseDanger),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _showDeleteDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CompletionProvider>(
      builder: (context, completionProvider, _) {
        final isDone = completionProvider.isDone(record.id);
        final currentProgress =
            completionProvider.completionFor(record.id)?.progress ?? 0;
        return _CardBody(
          record: record,
          isDone: isDone,
          progress: currentProgress,
          onProgressChanged: (val) {
            completionProvider.updateProgress(
              record.id,
              selectedDate,
              val.toInt(),
              record.targetProgress,
            );
          },
          onLongPress: () => _showContextMenu(context),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 40,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.delete_forever,
                  color: AppColors.relapseDanger,
                  size: 40,
                ),
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
}

// ─────────────────────────────────────────────────────────────────────────────

class _CardBody extends StatelessWidget {
  const _CardBody({
    required this.record,
    required this.isDone,
    required this.progress,
    required this.onProgressChanged,
    required this.onLongPress,
  });

  final RecordModel record;
  final bool isDone;
  final int progress;
  final ValueChanged<double> onProgressChanged;

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
          border: Border(left: BorderSide(color: borderColor, width: 4)),
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
            onLongPress: onLongPress,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      _IconBubble(icon: record.icon),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _TitleArea(record: record, isDone: isDone),
                      ),
                      InkWell(
                        onTap: () {
                          _showProgressSheet(context, progress);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isDone
                                ? Colors.green.withAlpha(30)
                                : AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '%$progress',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDone
                                      ? Colors.green
                                      : AppColors.primary,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showProgressSheet(BuildContext context, int currentProgress) {
    int tempProgress = currentProgress;
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'İlerlemeyi Güncelle',
                      style: Theme.of(ctx).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      '%$tempProgress',
                      style: Theme.of(ctx).textTheme.displaySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Slider(
                      value: tempProgress.toDouble(),
                      min: 0,
                      max: 100, // as was in the current card
                      divisions: 10,
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.primary.withValues(alpha: 0.2),
                      onChanged: (val) {
                        setState(() => tempProgress = val.toInt());
                        onProgressChanged(val);
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                        },
                        child: const Text('Tamam'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
      child: Text(icon ?? '✨', style: const TextStyle(fontSize: 20)),
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

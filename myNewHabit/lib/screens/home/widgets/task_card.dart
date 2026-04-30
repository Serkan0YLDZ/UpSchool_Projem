import '../../../providers/record_provider.dart';
// Sprint 3: Ana Sayfa & Takvim — TaskCard (US-303, US-306)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/record_model.dart';
import '../../../providers/completion_provider.dart';

/// Saatli görev kartı — kronolojik sırayla üst bölümde render edilir.
///
/// Tasarım: pill-shape kart, solda saat etiketi, sağda tamamlama toggle.
class TaskCard extends StatelessWidget {
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
                    'Bu takvim kaydını silmek istediğine emin misin?',
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
  const TaskCard({
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
        final isDone = provider.isDone(record.id);
        return _TaskCardBody(
          record: record,
          isDone: isDone,
          onToggle: () => _handleToggle(context, provider, isDone),
          onLongPress: () => _showDeleteDialog(context),
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


class _TaskCardBody extends StatelessWidget {
  const _TaskCardBody({
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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          _TimeLabel(time: record.scheduledTime ?? ''),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _PillCard(
              record: record,
              isDone: isDone,
              onTap: onToggle,
              onLongPress: onLongPress,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _TimeLabel extends StatelessWidget {
  const _TimeLabel({required this.time});

  final String time;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      child: Text(
        time,
        textAlign: TextAlign.right,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PillCard extends StatelessWidget {
  const _PillCard({
    required this.record,
    required this.isDone,
    required this.onTap,
    required this.onLongPress,
  });

  final RecordModel record;
  final bool isDone;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDone ? 0.55 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(50),
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
            borderRadius: BorderRadius.circular(50),
            onTap: onTap,
            onLongPress: onLongPress,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  _IconBubble(icon: record.icon),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          record.title,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.onSurface,
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                                decorationColor:
                                    AppColors.onSurface.withValues(alpha: 0.4),
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (record.dueDate != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Text('📅', style: TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('d MMM', 'tr_TR').format(record.dueDate!),
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _DoneIndicator(isDone: isDone),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
      child: Text(icon ?? '📋', style: const TextStyle(fontSize: 20)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DoneIndicator extends StatelessWidget {
  const _DoneIndicator({required this.isDone});

  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isDone ? AppColors.primary : AppColors.surfaceContainerHigh,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isDone ? Icons.check_rounded : Icons.chevron_right_rounded,
        size: 18,
        color: isDone ? Colors.white : AppColors.onSurfaceVariant,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/record_model.dart';
import '../../../providers/completion_provider.dart';
import '../../../providers/record_provider.dart';
import '../../../modals/edit_record_sheet.dart';

class TodoCard extends StatelessWidget {
  const TodoCard({super.key, required this.record, required this.selectedDate});

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

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.cardPadding,
            vertical: 40,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.delete_forever,
                  color: AppColors.relapseDanger,
                  size: 40,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Bu yapılacak (To-Do) görevini silmek istediğine emin misin?',
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
                    const SizedBox(width: AppSpacing.smMd),
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

  @override
  Widget build(BuildContext context) {
    return Consumer<CompletionProvider>(
      builder: (context, provider, _) {
        final isDone = provider.isDone(record.id);
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _TodoCardBody(
            record: record,
            isDone: isDone,
            onToggle: () => _handleToggle(context, provider, isDone),
            onLongPress: () => _showContextMenu(context),
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

class _TodoCardBody extends StatelessWidget {
  const _TodoCardBody({
    required this.record,
    required this.isDone,
    required this.onToggle,
    required this.onLongPress,
  });

  final RecordModel record;
  final bool isDone;
  final VoidCallback onToggle;
  final VoidCallback onLongPress;

  Color _getPriorityColor() {
    switch (record.priority) {
      case Priority.high:
        return AppColors.error;
      case Priority.medium:
        return AppColors.streakFire;
      case Priority.low:
        return AppColors.primaryContainer;
      case null:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor();
    final hasPriority = record.priority != null;

    return Opacity(
      opacity: isDone ? 0.55 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: const [
            BoxShadow(
              color: AppColors.ambientShadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onToggle,
            onLongPress: onLongPress,
            child: Stack(
              children: [
                if (hasPriority)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(width: 6, color: priorityColor),
                  ),
                Padding(
                  padding: EdgeInsets.only(
                    left: hasPriority ? AppSpacing.md + 6 : AppSpacing.md,
                    right: AppSpacing.md,
                    top: AppSpacing.md,
                    bottom: AppSpacing.md,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 2,
                        ), // Align visually with first text line
                        child: _TodoCheckbox(isDone: isDone),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              record.title,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.w600,
                                    decoration: isDone
                                        ? TextDecoration.lineThrough
                                        : null,
                                    decorationColor: AppColors.onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                            ),
                            if (record.description != null &&
                                record.description!.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                record.description!,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                      decoration: isDone
                                          ? TextDecoration.lineThrough
                                          : null,
                                      decorationColor: AppColors
                                          .onSurfaceVariant
                                          .withValues(alpha: 0.5),
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            if (record.dueDate != null) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.event_outlined,
                                    size: 16,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat(
                                      'd MMM yyyy, HH:mm',
                                      'tr_TR',
                                    ).format(record.dueDate!),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
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

class _TodoCheckbox extends StatelessWidget {
  const _TodoCheckbox({required this.isDone});

  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isDone ? AppColors.primary : Colors.transparent,
        border: isDone
            ? null
            : Border.all(color: AppColors.outlineVariant, width: 2),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: isDone
          ? const Icon(Icons.check, size: 16, color: Colors.white)
          : null,
    );
  }
}

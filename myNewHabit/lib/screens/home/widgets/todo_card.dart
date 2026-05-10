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
import '../../../core/widgets/brutalist_container.dart';

class TodoCard extends StatelessWidget {
  const TodoCard({super.key, required this.record, required this.selectedDate});

  final RecordModel record;
  final String selectedDate;

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.brutalistBlack, width: 3),
          boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(4, 4))],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.brutalistBlack,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.pop(ctx);
                          final updated = await showEditRecordSheet(context, record);
                          if (updated != null && context.mounted) {
                            context.read<RecordProvider>().updateRecord(updated);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE599),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.brutalistBlack, width: 3),
                            boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(4, 4))],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.edit, color: AppColors.brutalistBlack),
                              SizedBox(width: 8),
                              Text('DÜZENLE', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.brutalistBlack, fontSize: 16, letterSpacing: 1.0)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          _showDeleteDialog(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.relapseDanger,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.brutalistBlack, width: 3),
                            boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(4, 4))],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete, color: AppColors.brutalistWhite),
                              SizedBox(width: 8),
                              Text('SİL', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.brutalistWhite, fontSize: 16, letterSpacing: 1.0)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
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
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.brutalistBlack, width: 3),
              boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(6, 6))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.relapseDanger,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'SİLMEK İSTEDİĞİNE\nEMİN MİSİN?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.brutalistBlack,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Bu yapılacak (To-Do) görevini silmek istediğine emin misin?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.brutalistBlack.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.brutalistWhite,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.brutalistBlack, width: 2),
                            boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(2, 2))],
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'VAZGEÇ',
                            style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.brutalistBlack),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.of(ctx).pop();
                          final provider = context.read<RecordProvider>();
                          await provider.deleteRecord(record.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.relapseDanger,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.brutalistBlack, width: 2),
                            boxShadow: const [BoxShadow(color: AppColors.brutalistBlack, offset: Offset(2, 2))],
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'SİL',
                            style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.brutalistWhite),
                          ),
                        ),
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
        return Color(0xFFFF6B6B); // Lighter Red for Urgent
      case Priority.medium:
        return Color(0xFFFDE074); // Billing Yellow
      case Priority.low:
      case null:
        return AppColors.primaryContainer; // Travel Blue
    }
  }

  String _getPriorityLabel() {
    switch (record.priority) {
      case Priority.high:
        return 'YÜKSEK';
      case Priority.medium:
        return 'ORTA';
      case Priority.low:
        return 'DÜŞÜK';
      case null:
        return 'GÖREV';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Generate pseudo-random rotation between -1 and 1
    final isEven = record.id.length % 2 == 0;
    final rotation = isEven ? 1.0 : -1.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        BrutalistContainer(
          rotatedOffset: -rotation,
          onTap: onToggle,
          margin: const EdgeInsets.only(top: 12), // Give space for badge
          padding: const EdgeInsets.all(16),
          child: GestureDetector(
            onLongPress: onLongPress,
            behavior: HitTestBehavior.opaque,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Brutalist Checkbox
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDone
                        ? AppColors.brutalistBlack
                        : AppColors.brutalistWhite,
                    border: Border.all(
                      color: AppColors.brutalistBlack,
                      width: 4,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isDone
                      ? const Icon(
                          Icons.check,
                          color: AppColors.brutalistWhite,
                          size: 20,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        record.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDone
                              ? AppColors.outline
                              : AppColors.brutalistBlack,
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (record.dueDate != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.brutalistWhite,
                            border: Border.all(
                              color: AppColors.brutalistBlack,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.brutalistBlack,
                                offset: Offset(2, 2),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.access_time, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat(
                                  'd MMM, HH:mm',
                                  'tr_TR',
                                ).format(record.dueDate!),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Badge
        Positioned(
          top: 0,
          left: 16,
          child: Transform.rotate(
            angle: rotation * 2 * 3.1415 / 180,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getPriorityColor(),
                border: Border.all(color: AppColors.brutalistBlack, width: 3),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.brutalistBlack,
                    offset: Offset(3, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Text(
                _getPriorityLabel(),
                style: TextStyle(
                  color: record.priority == Priority.medium
                      ? AppColors.brutalistBlack
                      : AppColors.brutalistWhite,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Sprint 3: Ana Sayfa & Takvim — HabitCard (US-303, US-304, US-306)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/brutalist_container.dart';
import '../../../core/theme/app_colors.dart';
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
                  'Bu alışkanlığı silmek istediğine emin misin?',
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
    // Generate a pseudo-random rotation based on the id's length for stable asymetery
    final rotation = (record.id.length % 2 == 0) ? 1.0 : -1.0;

    // Choose icon and color arbitrarily or map from properties later
    const iconData = Icons.water_drop_rounded;
    final iconColor = const Color(0xFFC4EDF8); // light blue

    final currentTarget = record.targetProgress > 0
        ? record.targetProgress
        : 100;
    final progressPercent = (progress / currentTarget).clamp(0.0, 1.0);

    return BrutalistContainer(
      rotatedOffset: rotation,
      onTap: () {
        // Toggle done logic can be here, simple complete/uncomplete
        onProgressChanged(isDone ? 0 : currentTarget.toDouble());
      },
      child: GestureDetector(
        onLongPress: onLongPress,
        behavior: HitTestBehavior.opaque,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor,
                    border: Border.all(
                      color: AppColors.brutalistBlack,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    iconData,
                    color: AppColors.brutalistBlack,
                    size: 24,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brutalistWhite,
                    border: Border.all(
                      color: AppColors.brutalistBlack,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.brutalistBlack,
                        offset: Offset(3, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.deepOrange,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '12',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$progress / $currentTarget ${record.targetUnit ?? ''}'.trim(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDone
                        ? Colors.purple.withValues(alpha: 0.3)
                        : AppColors.brutalistWhite,
                    border: Border.all(
                      color: AppColors.brutalistBlack,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progressPercent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDone
                            ? Colors.purple
                            : AppColors.primaryContainer,
                        border: Border(
                          right: BorderSide(
                            color: AppColors.brutalistBlack,
                            width: 3,
                          ),
                        ),
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(16),
                          right: progressPercent == 1.0
                              ? Radius.circular(16)
                              : Radius.zero,
                        ),
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
  }
} // End of file

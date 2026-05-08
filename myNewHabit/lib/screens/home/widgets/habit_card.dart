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
                      '$progress / $currentTarget',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    isDone
                        ? const Text(
                            'Done!',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          )
                        : Text(
                            '${(progressPercent * 100).toInt()}%',
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

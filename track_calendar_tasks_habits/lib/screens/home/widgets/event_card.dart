import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/track_custom_colors.dart';
import '../../../core/widgets/brutalist_container.dart';
import '../../../data/models/record_model.dart';
import '../../../modals/edit_record_sheet.dart';
import '../../../providers/completion_provider.dart';
import '../../../providers/record_provider.dart';

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.record, required this.selectedDate});

  final RecordModel record;
  final String selectedDate;

  @override
  Widget build(BuildContext context) {
    return Consumer<CompletionProvider>(
      builder: (context, provider, _) {
        final isDone = provider.isDone(record.id);
        return _EventCardBody(
          record: record,
          isDone: isDone,
          onToggle: () => _handleToggle(context, provider, isDone),
          onLongPress: () => _showContextMenu(context),
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

  void _showContextMenu(BuildContext context) {
    final scheme = context.scheme;
    final track = context.track;
    final ink = track.brutalistInk;

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        minWidth: MediaQuery.sizeOf(context).width,
        maxWidth: MediaQuery.sizeOf(context).width,
      ),
      builder: (ctx) => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: track.neoChromePlate,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(top: BorderSide(color: ink, width: 3)),
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
                  color: ink,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SheetBtn(
                      label: 'DÜZENLE',
                      icon: Icons.edit,
                      color: track.neoStackFace,
                      textColor: track.neoStackOnFace,
                      borderColor: ink,
                      onTap: () async {
                        Navigator.pop(ctx);
                        final updated = await showEditRecordSheet(context, record);
                        if (updated != null && context.mounted) {
                          context.read<RecordProvider>().updateRecord(updated);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _SheetBtn(
                      label: 'SİL',
                      icon: Icons.delete,
                      color: scheme.error,
                      textColor: scheme.onError,
                      borderColor: ink,
                      onTap: () {
                        Navigator.pop(ctx);
                        _showDeleteDialog(context);
                      },
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
    final scheme = context.scheme;
    final track = context.track;
    final ink = track.brutalistInk;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ink, width: 3),
            boxShadow: [BoxShadow(color: ink, offset: const Offset(6, 6))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, color: scheme.error, size: 48),
              const SizedBox(height: 16),
              Text(
                'SİLMEK İSTEDİĞİNE\nEMİN MİSİN?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: ink,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Bu takvim kaydını silmek istediğine emin misin?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ink.withValues(alpha: 0.7),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _DlgBtn(
                      label: 'VAZGEÇ',
                      color: track.brutalistSurface,
                      textColor: ink,
                      borderColor: ink,
                      onTap: () => Navigator.of(ctx).pop(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _DlgBtn(
                      label: 'SİL',
                      color: scheme.error,
                      textColor: track.brutalistSurface,
                      borderColor: ink,
                      onTap: () async {
                        Navigator.of(ctx).pop();
                        await context.read<RecordProvider>().deleteRecord(record.id);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetBtn extends StatelessWidget {
  const _SheetBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.borderColor,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 3),
              boxShadow: [
                BoxShadow(color: borderColor, offset: const Offset(4, 4)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: textColor),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    fontSize: 16,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        );
}

class _DlgBtn extends StatelessWidget {
  const _DlgBtn({
    required this.label,
    required this.color,
    required this.textColor,
    required this.borderColor,
    required this.onTap,
  });
  final String label;
  final Color color;
  final Color textColor;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(color: borderColor, offset: const Offset(2, 2)),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w900, color: textColor),
          ),
        ),
      );
}

class _EventCardBody extends StatelessWidget {
  const _EventCardBody({
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
    final track = context.track;
    final ink = track.brutalistInk;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            child: Text(
              record.scheduledTime ?? '',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: ink,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
            ),
          ),
          SizedBox(
            width: 16,
            child: Center(
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: isDone ? ink : track.brutalistSurface,
                  border: Border.all(color: ink, width: 3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
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
    final track = context.track;
    final ink = track.brutalistInk;

    return Opacity(
      opacity: isDone ? 0.6 : 1.0,
      child: GestureDetector(
        onLongPress: onLongPress,
        behavior: HitTestBehavior.opaque,
        child: BrutalistContainer(
          backgroundColor:
              isDone ? track.tertiaryFixed : track.brutalistSurface,
          borderWidth: 3.0,
          shadowOffset: 4.0,
          borderRadius: 8.0,
          onTap: onTap,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.smMd,
            vertical: AppSpacing.smMd,
          ),
          child: Row(
            children: [
              const SizedBox(width: AppSpacing.smMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      record.title.toUpperCase(),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: ink,
                            fontWeight: FontWeight.w900,
                            decoration:
                                isDone ? TextDecoration.lineThrough : null,
                            decorationThickness: 2.0,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (record.description != null &&
                        record.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        record.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: ink,
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    _EventDateLine(record: record),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _DoneIndicator(isDone: isDone),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoneIndicator extends StatelessWidget {
  const _DoneIndicator({required this.isDone});
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    final track = context.track;
    final ink = track.brutalistInk;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isDone ? ink : track.brutalistSurface,
        border: Border.all(color: ink, width: 2.5),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Icon(
        isDone ? Icons.check : Icons.chevron_right,
        size: 18,
        color: isDone ? track.brutalistSurface : ink,
      ),
    );
  }
}

class _EventDateLine extends StatelessWidget {
  const _EventDateLine({required this.record});
  final RecordModel record;

  String _formatDate(String ymd) {
    try {
      final d = DateTime.parse(ymd);
      return d.year == DateTime.now().year
          ? DateFormat('d MMM', 'tr_TR').format(d)
          : DateFormat('d MMM yyyy', 'tr_TR').format(d);
    } catch (_) {
      return ymd;
    }
  }

  @override
  Widget build(BuildContext context) {
    final track = context.track;
    final ink = track.brutalistInk;
    final startDateStr = record.scheduledDate;
    final endDateStr = record.endDate;
    final startTime = record.scheduledTime ?? '';
    final endTime = record.endTime ?? '';

    String line = '';
    if (startDateStr != null && startDateStr.isNotEmpty) {
      if (endDateStr != null &&
          endDateStr.isNotEmpty &&
          endDateStr != startDateStr) {
        line =
            '${_formatDate(startDateStr)} ${startTime.isNotEmpty ? startTime : ''} – ${_formatDate(endDateStr)} ${endTime.isNotEmpty ? endTime : ''}';
      } else {
        line = endTime.isNotEmpty ? '$startTime – $endTime' : startTime;
      }
    } else {
      line = (startTime.isNotEmpty && endTime.isNotEmpty)
          ? '$startTime – $endTime'
          : (startTime.isNotEmpty ? startTime : endTime);
    }

    if (line.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.access_time, size: 14, color: ink),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            line,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: ink,
                  fontWeight: FontWeight.w600,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// Sprint 3: Ana Sayfa & Takvim — EventCard (US-303, US-306)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/record_model.dart';
import '../../../providers/completion_provider.dart';
import '../../../providers/record_provider.dart';
import '../../../modals/edit_record_sheet.dart';
import '../../../core/widgets/brutalist_container.dart';

/// Saatli etkinlik kartı — kronolojik sırayla üst bölümde render edilir.
///
/// Tasarım: pill-shape kart, solda saat etiketi, sağda tamamlama toggle.
class EventCard extends StatelessWidget {
  const EventCard({
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
                  'Bu takvim kaydını silmek istediğine emin misin?',
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
}

// ─────────────────────────────────────────────────────────────────────────────

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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Time Label (48px width)
          SizedBox(
            width: 48,
            child: _TimeLabel(
              startTime: record.scheduledTime ?? '',
              endTime: record.endTime,
            ),
          ),

          // Timeline node centered perfectly at left: 56
          // (48 + 16/2 = 56)
          SizedBox(
            width: 16,
            child: Center(
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: isDone
                      ? AppColors.brutalistBlack
                      : AppColors.brutalistWhite,
                  border: Border.all(color: AppColors.brutalistBlack, width: 3),
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

// ─────────────────────────────────────────────────────────────────────────────

class _TimeLabel extends StatelessWidget {
  const _TimeLabel({required this.startTime, this.endTime});

  final String startTime;
  final String? endTime;

  @override
  Widget build(BuildContext context) {
    // Only show the start time on the left column (HH:mm)
    final display = startTime;
    return Text(
      display,
      textAlign: TextAlign.right,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: AppColors.brutalistBlack,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
        height: 1.2,
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
      opacity: isDone ? 0.6 : 1.0,
      child: GestureDetector(
        onLongPress: onLongPress,
        behavior: HitTestBehavior.opaque,
        child: BrutalistContainer(
          backgroundColor: isDone
              ? AppColors.tertiaryFixed
              : AppColors.brutalistWhite,
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
              // Icon removed for calendar event list items (design requirement)
              const SizedBox(width: AppSpacing.smMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      record.title.toUpperCase(),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.brutalistBlack,
                        fontWeight: FontWeight.w900,
                        decoration: isDone ? TextDecoration.lineThrough : null,
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
                          color: AppColors.brutalistBlack,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Date / time line under the title (optional)
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
        color: isDone ? AppColors.brutalistBlack : AppColors.brutalistWhite,
        border: Border.all(color: AppColors.brutalistBlack, width: 2.5),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Icon(
        isDone ? Icons.check : Icons.chevron_right,
        size: 18,
        color: isDone ? AppColors.brutalistWhite : AppColors.brutalistBlack,
      ),
    );
  }
}

// Helper widget to format and display start/end date-time under the event title.
class _EventDateLine extends StatelessWidget {
  const _EventDateLine({required this.record});

  final RecordModel record;

  String _formatDate(String ymd) {
    try {
      final d = DateTime.parse(ymd);
      final now = DateTime.now();
      // Omit year if same as current year
      if (d.year == now.year) {
        return DateFormat('d MMM', 'tr_TR').format(d);
      }
      return DateFormat('d MMM yyyy', 'tr_TR').format(d);
    } catch (_) {
      return ymd;
    }
  }

  @override
  Widget build(BuildContext context) {
    final startDateStr = record.scheduledDate;
    final endDateStr = record.endDate;
    final startTime = record.scheduledTime ?? '';
    final endTime = record.endTime ?? '';

    String line = '';
    if (startDateStr != null && startDateStr.isNotEmpty) {
      if (endDateStr != null &&
          endDateStr.isNotEmpty &&
          endDateStr != startDateStr) {
        // Different days -> show full dates with times
        final s = _formatDate(startDateStr);
        final e = _formatDate(endDateStr);
        line =
            '$s ${startTime.isNotEmpty ? startTime : ''} – $e ${endTime.isNotEmpty ? endTime : ''}';
      } else {
        // Same day or no end date -> show time range or single time
        if (endTime.isNotEmpty) {
          line = '$startTime – $endTime';
        } else {
          line = startTime;
        }
      }
    } else {
      // Fallback: show times if available
      if (startTime.isNotEmpty && endTime.isNotEmpty) {
        line = '$startTime – $endTime';
      } else {
        line = startTime.isNotEmpty ? startTime : endTime;
      }
    }

    if (line.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.access_time,
          size: 14,
          color: AppColors.brutalistBlack,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            line,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.brutalistBlack,
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

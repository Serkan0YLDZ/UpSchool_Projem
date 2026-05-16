import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/track_custom_colors.dart';
import '../../../core/utils/habit_icons.dart';
import '../../../core/widgets/brutalist_container.dart';
import '../../../data/models/record_model.dart';
import '../../../data/services/streak_service.dart';
import '../../../modals/edit_record_sheet.dart';
import '../../../modals/streak_stats_dialog.dart';
import '../../../providers/completion_provider.dart';
import '../../../providers/record_provider.dart';
import '../../../providers/streak_provider.dart';

class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.record,
    required this.selectedDate,
    required this.todayYmd,
  });

  final RecordModel record;
  final String selectedDate;
  final String todayYmd;

  @override
  Widget build(BuildContext context) {
    final completionProvider = context.watch<CompletionProvider>();
    final streakProvider = context.watch<StreakProvider>();
    final isDone = completionProvider.isDone(record.id);
    final currentProgress =
        completionProvider.completionFor(record.id)?.progress ?? 0;
    final streakView =
        streakProvider.viewFor(record, selectedDate, todayYmd);

    return _CardBody(
      record: record,
      isDone: isDone,
      progress: currentProgress,
      streakView: streakView,
      onProgressChanged: (val) async {
        final v = val.toInt();
        if (selectedDate != todayYmd) {
          if (isDone && v == 0) {
            await completionProvider.undoCompletion(record.id);
          } else if (context.mounted) {
            _showLockedSnack(context);
          }
          return;
        }
        await completionProvider.updateProgress(
          record.id,
          selectedDate,
          v,
          record.targetProgress,
          requireToday: true,
        );
      },
      onLongPress: () => _showContextMenu(context),
      onStreakTap: () => showStreakStatsDialog(
        context,
        longestStreak: streakView.longestStreak,
      ),
      onRecoverTap: streakView.showRecoverCta
          ? () => streakProvider.applyRecovery(record.id)
          : null,
    );
  }

  void _showLockedSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bu alışkanlığı yalnızca bugünün tarihinde tamamlayabilirsin.'),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    final canRestart =
        context.read<StreakProvider>().rowFor(record.id)?.seriesClosedAfter !=
            null;
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
                    _ContextAction(
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
                    if (canRestart) ...[
                      const SizedBox(height: 8),
                      _ContextAction(
                        label: 'SERİYİ YENİDEN BAŞLAT',
                        icon: Icons.refresh_rounded,
                        color: scheme.secondaryContainer,
                        textColor: ink,
                        borderColor: ink,
                        onTap: () async {
                          Navigator.pop(ctx);
                          await context.read<StreakProvider>().restartSeries(record.id);
                          if (context.mounted) {
                            await context.read<RecordProvider>().loadRecords();
                          }
                        },
                      ),
                    ],
                    const SizedBox(height: 8),
                    _ContextAction(
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
                'Bu alışkanlığı silmek istediğine emin misin?',
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
                    child: _DialogButton(
                      label: 'VAZGEÇ',
                      color: track.brutalistSurface,
                      textColor: ink,
                      borderColor: ink,
                      onTap: () => Navigator.of(ctx).pop(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _DialogButton(
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

class _ContextAction extends StatelessWidget {
  const _ContextAction({
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
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
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

class _CardBody extends StatelessWidget {
  const _CardBody({
    required this.record,
    required this.isDone,
    required this.progress,
    required this.streakView,
    required this.onProgressChanged,
    required this.onLongPress,
    required this.onStreakTap,
    this.onRecoverTap,
  });

  final RecordModel record;
  final bool isDone;
  final int progress;
  final StreakViewState streakView;
  final ValueChanged<double> onProgressChanged;
  final VoidCallback onLongPress;
  final VoidCallback onStreakTap;
  final VoidCallback? onRecoverTap;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final track = context.track;
    final ink = track.brutalistInk;
    final rotation = (record.id.length % 2 == 0) ? 1.0 : -1.0;
    final currentTarget = record.targetProgress > 0 ? record.targetProgress : 100;
    final progressPercent = (progress / currentTarget).clamp(0.0, 1.0);
    final tertiarySoft = scheme.tertiary.withValues(alpha: 0.3);


    return BrutalistContainer(
      rotatedOffset: rotation,
      onTap: () => onProgressChanged(isDone ? 0 : currentTarget.toDouble()),
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
                Builder(builder: (context) {
                  final iconData = HabitIcons.resolve(record.icon);
                  final iconBg = record.iconColor != null
                      ? Color(record.iconColor!)
                      : track.habitCardSoftBlue;
                  return Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBg,
                      border: Border.all(color: ink, width: 3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      iconData,
                      color: ink,
                      size: 24,
                    ),
                  );
                }),
                _StreakBadge(
                  count: streakView.displayStreak,
                  flameTier: streakView.flameTier,
                  onTap: onStreakTap,
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
                Text(
                  '$progress / $currentTarget ${record.targetUnit ?? ''}'.trim(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDone ? tertiarySoft : track.brutalistSurface,
                    border: Border.all(color: ink, width: 3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progressPercent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDone
                            ? const Color(0xFF4CAF50)
                            : scheme.primaryContainer,
                        border: Border(
                          right: BorderSide(color: ink, width: 3),
                        ),
                        borderRadius: BorderRadius.horizontal(
                          left: const Radius.circular(16),
                          right: progressPercent == 1.0
                              ? const Radius.circular(16)
                              : Radius.zero,
                        ),
                      ),
                    ),
                  ),
                ),
                if (onRecoverTap != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _StreakActionRow(
                    onRecoverTap: onRecoverTap,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({
    required this.count,
    required this.flameTier,
    required this.onTap,
  });
  final int count;
  final int flameTier;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final track = context.track;
    final ink = track.brutalistInk;
    final flameColor = switch (flameTier) {
      0 => track.streakMuted,
      2 => track.streakRecovery,
      _ => track.streakFire,
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: track.brutalistSurface,
            border: Border.all(color: ink, width: 3),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [BoxShadow(color: ink, offset: const Offset(3, 3))],
          ),
          child: Row(
            children: [
              Icon(Icons.local_fire_department, color: flameColor, size: 14),
              const SizedBox(width: 4),
              Text(
                '$count',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakActionRow extends StatelessWidget {
  const _StreakActionRow({this.onRecoverTap});
  final VoidCallback? onRecoverTap;

  @override
  Widget build(BuildContext context) {
    final track = context.track;

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        if (onRecoverTap != null)
          TextButton(
            onPressed: onRecoverTap,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'SERİYİ GERİ GETİR',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 10,
                color: track.streakRecovery,
              ),
            ),
          ),
      ],
    );
  }
}

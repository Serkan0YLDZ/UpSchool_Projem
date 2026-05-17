import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';


import 'package:track_calendar_tasks_habits/core/theme/app_spacing.dart';
import 'package:track_calendar_tasks_habits/core/theme/track_custom_colors.dart';
import 'package:track_calendar_tasks_habits/core/utils/habit_icons.dart';
import 'package:track_calendar_tasks_habits/core/widgets/brutalist_container.dart';
import 'package:track_calendar_tasks_habits/data/models/habit_model.dart';
import 'package:track_calendar_tasks_habits/data/models/habit_day_log_model.dart';
import 'package:track_calendar_tasks_habits/presentation/modals/streak_stats_dialog.dart';
import 'package:track_calendar_tasks_habits/presentation/providers/habit_day_log_provider.dart';
import 'package:track_calendar_tasks_habits/presentation/providers/habit_provider.dart';
import 'package:track_calendar_tasks_habits/presentation/providers/streak_provider.dart';
import 'package:track_calendar_tasks_habits/presentation/modals/edit_item_sheet.dart';

class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.habit,
    required this.selectedDate,
    required this.todayYmd,
  });

  final HabitModel habit;
  final String selectedDate;
  final String todayYmd;

  @override
  Widget build(BuildContext context) {
    final streakProvider = context.watch<StreakProvider>();
    
    final streakView = streakProvider.viewFor(habit, selectedDate, todayYmd);
    // isDone, streakProvider'ın logsCache'inden türetilir
    final isDone = streakView.isCompletedToday;

    return _CardBody(
      habit: habit,
      isDone: isDone,
      streakView: streakView,
      onToggle: () async {
        await HapticFeedback.lightImpact();
        if (selectedDate != todayYmd) {
          if (isDone) {
            // Geçmiş tamamlamayı geri al
            await streakProvider.logDay(habit, selectedDate, DayLogStatus.pending);
            if (context.mounted) {
              await context.read<HabitDayLogProvider>().loadLogsForDate(selectedDate);
              await context.read<StreakProvider>().loadForHabits(
                context.read<HabitProvider>().habits, todayYmd);
            }
          } else if (context.mounted) {
            _showLockedSnack(context);
          }
          return;
        }
        await streakProvider.logDay(habit, selectedDate, isDone ? DayLogStatus.pending : DayLogStatus.met);
        if (context.mounted) {
          // Hem streak hem de log provider'ı güncelle (UI tutarlılığı)
          await context.read<HabitDayLogProvider>().loadLogsForDate(selectedDate);
          await context.read<StreakProvider>().loadForHabits(
            context.read<HabitProvider>().habits, 
            todayYmd
          );
        }
      },
      onLongPress: () => _showContextMenu(context),
      onStreakTap: () => showStreakStatsDialog(
        context,
        longestStreak: streakView.longestStreak,
      ),
      onRecoverTap: streakView.showRecoverCta
          ? () async {
              await streakProvider.applyRecovery(habit.id, selectedDate);
              if (context.mounted) {
                await context.read<StreakProvider>().loadForHabits(
                  context.read<HabitProvider>().habits, 
                  todayYmd
                );
              }
            }
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
    // Determine if series is closed
    final isClosed = context.read<StreakProvider>().viewFor(habit, selectedDate, todayYmd).isClosed;
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
                      onTap: () {
                        Navigator.pop(ctx);
                        showEditHabitSheet(context, habit);
                      },
                    ),
                    if (isClosed) ...[
                      const SizedBox(height: 8),
                      _ContextAction(
                        label: 'SERİYİ YENİDEN BAŞLAT',
                        icon: Icons.refresh_rounded,
                        color: scheme.secondaryContainer,
                        textColor: ink,
                        borderColor: ink,
                        onTap: () async {
                          Navigator.pop(ctx);
                          await context.read<StreakProvider>().restartSeries(habit.id, selectedDate);
                          if (context.mounted) {
                            await context.read<HabitProvider>().loadHabits();
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
                        await context.read<HabitProvider>().deleteHabit(habit.id);
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
    required this.habit,
    required this.isDone,
    required this.streakView,
    required this.onToggle,
    required this.onLongPress,
    required this.onStreakTap,
    this.onRecoverTap,
  });

  final HabitModel habit;
  final bool isDone;
  final StreakViewState streakView;
  final VoidCallback onToggle;
  final VoidCallback onLongPress;
  final VoidCallback onStreakTap;
  final VoidCallback? onRecoverTap;

  @override
  Widget build(BuildContext context) {
    final track = context.track;
    final ink = track.brutalistInk;
    final rotation = (habit.id.length % 2 == 0) ? 1.0 : -1.0;

    return BrutalistContainer(
      rotatedOffset: rotation,
      onTap: onToggle,
      backgroundColor: isDone ? track.tertiaryFixed : track.brutalistSurface,
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
                  final iconData = HabitIcons.resolve(habit.iconKey);
                  final iconBg = habit.iconColorArgb != null
                      ? Color(habit.iconColorArgb!)
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
                  habit.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                // Hedef ve birim
                if (habit.targetProgress > 0) ...[
                  const SizedBox(height: 6),
                  Text(
                    isDone
                        ? '✓ ${habit.targetProgress}${habit.targetUnit != null ? ' ${habit.targetUnit}' : ''}'
                        : '${habit.targetProgress}${habit.targetUnit != null ? ' ${habit.targetUnit}' : ''}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isDone ? track.streakFire : ink.withValues(alpha: 0.65),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: isDone ? 1.0 : 0.0,
                      minHeight: 6,
                      backgroundColor: ink.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDone ? track.streakFire : ink.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ],
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

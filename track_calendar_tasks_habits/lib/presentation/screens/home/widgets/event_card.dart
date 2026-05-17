import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:track_calendar_tasks_habits/core/theme/app_spacing.dart';
import 'package:track_calendar_tasks_habits/core/theme/track_custom_colors.dart';
import 'package:track_calendar_tasks_habits/core/widgets/brutalist_container.dart';
import 'package:track_calendar_tasks_habits/data/models/calendar_event_model.dart';
import 'package:track_calendar_tasks_habits/presentation/providers/calendar_event_provider.dart';
import 'package:track_calendar_tasks_habits/presentation/modals/edit_item_sheet.dart';

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event, required this.selectedDate});

  final CalendarEventModel event;
  final String selectedDate;

  @override
  Widget build(BuildContext context) {
    return _EventCardBody(
      event: event,
      onLongPress: () => _showContextMenu(context),
    );
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
                      onTap: () {
                        Navigator.pop(ctx);
                        showEditEventSheet(context, event);
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
                'Bu takvim etkinliğini silmek istediğine emin misin?',
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
                        await context.read<CalendarEventProvider>().deleteEvent(event.id);
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
    required this.event,
    required this.onLongPress,
  });
  final CalendarEventModel event;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final track = context.track;
    final ink = track.brutalistInk;
    
    // Parse start time to HH:mm if startsAt is valid
    String timeStr = '';
    try {
      final dt = DateTime.parse(event.startsAt).toLocal();
      timeStr = DateFormat('HH:mm').format(dt);
    } catch (_) {}

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            child: Text(
              event.isAllDay ? 'Tüm\nGün' : timeStr,
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
                  color: track.brutalistSurface,
                  border: Border.all(color: ink, width: 3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _PillCard(
              event: event,
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
    required this.event,
    required this.onLongPress,
  });
  final CalendarEventModel event;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final track = context.track;
    final ink = track.brutalistInk;
    final isPast = event.isPast;

    return GestureDetector(
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        opacity: isPast ? 0.55 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: BrutalistContainer(
          backgroundColor: isPast ? track.tertiaryFixed : track.brutalistSurface,
          borderWidth: 3.0,
          shadowOffset: isPast ? 1.0 : 4.0,
          borderRadius: 8.0,
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
                      event.title.toUpperCase(),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: ink,
                            fontWeight: FontWeight.w900,
                            decoration: isPast ? TextDecoration.lineThrough : null,
                            decorationThickness: 2.5,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (event.description != null && event.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        event.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: ink,
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    _EventDateLine(event: event),
                  ],
                ),
              ),
              if (isPast)
                Icon(Icons.check_circle_rounded, color: track.streakFire, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventDateLine extends StatelessWidget {
  const _EventDateLine({required this.event});
  final CalendarEventModel event;

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso).toLocal();
      return d.year == DateTime.now().year
          ? DateFormat('d MMM', 'tr_TR').format(d)
          : DateFormat('d MMM yyyy', 'tr_TR').format(d);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final track = context.track;
    final ink = track.brutalistInk;
    
    final startDateStr = _formatDate(event.startsAt);
    final endDateStr = event.endsAt != null ? _formatDate(event.endsAt!) : '';

    String line = startDateStr;
    if (endDateStr.isNotEmpty && endDateStr != startDateStr) {
      line += ' – $endDateStr';
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

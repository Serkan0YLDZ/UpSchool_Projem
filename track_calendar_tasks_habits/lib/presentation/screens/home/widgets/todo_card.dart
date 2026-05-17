import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:track_calendar_tasks_habits/core/theme/app_spacing.dart';
import 'package:track_calendar_tasks_habits/core/theme/track_custom_colors.dart';
import 'package:track_calendar_tasks_habits/core/widgets/brutalist_container.dart';
import 'package:track_calendar_tasks_habits/data/models/todo_model.dart';
import 'package:track_calendar_tasks_habits/presentation/providers/todo_provider.dart';
import 'package:track_calendar_tasks_habits/presentation/modals/edit_item_sheet.dart';

class TodoCard extends StatelessWidget {
  const TodoCard({super.key, required this.todo, required this.selectedDate});

  final TodoModel todo;
  final String selectedDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: _TodoCardBody(
        todo: todo,
        isDone: todo.isCompleted,
        onToggle: () => _handleToggle(context, todo.isCompleted),
        onLongPress: () => _showContextMenu(context),
      ),
    );
  }

  Future<void> _handleToggle(BuildContext context, bool isDone) async {
    final provider = context.read<TodoProvider>();
    await HapticFeedback.lightImpact();
    // Toggle the current completion state
    await provider.markCompleted(todo.id, !isDone);
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
                    _ContextBtn(
                      label: 'DÜZENLE',
                      icon: Icons.edit,
                      color: track.neoStackFace,
                      textColor: track.neoStackOnFace,
                      borderColor: ink,
                      onTap: () {
                        Navigator.pop(ctx);
                        showEditTodoSheet(context, todo);
                      },
                    ),
                    const SizedBox(height: 16),
                    _ContextBtn(
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
                'Bu yapılacak görevi silmek istediğine emin misin?',
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
                    child: _DialogBtn(
                      label: 'VAZGEÇ',
                      color: track.brutalistSurface,
                      textColor: ink,
                      borderColor: ink,
                      onTap: () => Navigator.of(ctx).pop(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _DialogBtn(
                      label: 'SİL',
                      color: scheme.error,
                      textColor: track.brutalistSurface,
                      borderColor: ink,
                      onTap: () async {
                        Navigator.of(ctx).pop();
                        await context.read<TodoProvider>().deleteTodo(todo.id);
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

class _ContextBtn extends StatelessWidget {
  const _ContextBtn({
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

class _DialogBtn extends StatelessWidget {
  const _DialogBtn({
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

class _TodoCardBody extends StatelessWidget {
  const _TodoCardBody({
    required this.todo,
    required this.isDone,
    required this.onToggle,
    required this.onLongPress,
  });
  final TodoModel todo;
  final bool isDone;
  final VoidCallback onToggle;
  final VoidCallback onLongPress;

  Color _priorityColor(BuildContext context) {
    final track = context.track;
    return switch (todo.priority) {
      TodoPriority.high => track.todoPriorityHigh,
      TodoPriority.medium => track.todoPriorityMedium,
      TodoPriority.low => track.todoPriorityLow,
    };
  }

  Color _priorityLabelColor(BuildContext context) {
    final track = context.track;
    final ink = track.brutalistInk;
    return switch (todo.priority) {
      TodoPriority.high => track.brutalistSurface,
      TodoPriority.medium => ink,
      TodoPriority.low => ink,
    };
  }

  String _priorityLabel() => switch (todo.priority) {
    TodoPriority.high => 'YÜKSEK',
    TodoPriority.medium => 'ORTA',
    TodoPriority.low => 'DÜŞÜK',
  };

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final track = context.track;
    final ink = track.brutalistInk;
    final isEven = todo.id.length % 2 == 0;
    final rotation = isEven ? 1.0 : -1.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        BrutalistContainer(
          rotatedOffset: -rotation,
          onTap: onToggle,
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(16),
          child: GestureDetector(
            onLongPress: onLongPress,
            behavior: HitTestBehavior.opaque,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDone ? ink : track.brutalistSurface,
                    border: Border.all(color: ink, width: 4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isDone
                      ? Icon(
                          Icons.check,
                          color: track.brutalistSurface,
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
                        todo.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDone ? scheme.outline : ink,
                          decoration:
                              isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (todo.dueDate != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: track.brutalistSurface,
                            border: Border.all(color: ink, width: 2),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(color: ink, offset: const Offset(2, 2)),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.access_time, size: 14, color: ink),
                              const SizedBox(width: 4),
                              Text(
                                () {
                                  try {
                                    final d = DateTime.parse(todo.dueDate!).toLocal();
                                    return DateFormat('d MMM, HH:mm', 'tr_TR').format(d);
                                  } catch (_) {
                                    return todo.dueDate!;
                                  }
                                }(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: ink,
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
        Positioned(
          top: 0,
          left: 16,
          child: Transform.rotate(
            angle: rotation * 2 * 3.1415 / 180,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _priorityColor(context),
                border: Border.all(color: ink, width: 3),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: ink, offset: const Offset(3, 3)),
                ],
              ),
              child: Text(
                _priorityLabel(),
                style: TextStyle(
                  color: _priorityLabelColor(context),
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

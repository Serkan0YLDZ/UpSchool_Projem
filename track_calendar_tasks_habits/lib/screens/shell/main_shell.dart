import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/track_custom_colors.dart';
import '../../core/utils/calendar_date.dart';
import '../../data/models/record_model.dart';
import '../../modals/add_record_modal.dart';
import '../../modals/focus_mode_picker_sheet.dart';
import '../../modals/habit_details_sheet.dart';
import '../../modals/naming_modal.dart';
import '../../modals/task_timing_sheet.dart';
import '../../modals/todo_details_sheet.dart';
import '../../providers/record_provider.dart';
import '../focus/focus_section.dart';

/// Ana navigasyon kabuğu — 3 tab + merkezi FAB ekle butonu.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final state = GoRouterState.of(context);
    final navPath = state.uri.path;
    final selectedIndex = _locationToIndex(navPath);
    final focusClusterIcon = _focusClusterIcon(navPath);

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          child,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _CustomBottomNavBar(
              selectedIndex: selectedIndex,
              focusClusterIcon: focusClusterIcon,
              onDestinationSelected: (index) => _onNavTap(context, index),
              onCalendarTap: () {
                final path = GoRouterState.of(context).uri.path;
                if (path.startsWith(AppRoutes.focusParent)) return;
                context.go(AppRoutes.focusCalendar);
              },
              onCalendarLongPress: () => _openFocusModePicker(context),
            ),
          ),
        ],
      ),
    );
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
      case 1:
        _openAddFlow(context);
      case 2:
        context.go(AppRoutes.profile);
    }
  }

  Future<void> _openFocusModePicker(BuildContext context) async {
    final section = await showFocusModePickerSheet(context);
    if (!context.mounted || section == null) return;
    final target = switch (section) {
      FocusSection.calendar => AppRoutes.focusCalendar,
      FocusSection.habits => AppRoutes.focusHabits,
      FocusSection.todos => AppRoutes.focusTodos,
    };
    context.go(target);
  }

  /// Adım 1 → tip seç · Adım 2 → isim gir · Adım 3 → tipine göre detay
  Future<void> _openAddFlow(BuildContext context) async {
    int currentStep = 1;
    RecordType? selectedType;
    String? title;
    int? target;
    String? targetUnit;

    while (currentStep > 0 && currentStep <= 3 && context.mounted) {
      if (currentStep == 1) {
        selectedType = null;
        title = null;
        target = null;
        targetUnit = null;
        if (!context.mounted) return;
        await showAddRecordModal(
          context,
          onTypeSelected: (type) {
            selectedType = type;
            if (context.mounted) Navigator.of(context).pop();
          },
        );
        if (selectedType == null) return;
        currentStep = 2;
      } else if (currentStep == 2) {
        if (!context.mounted) return;
        final result = await showNamingModal(
          context,
          type: selectedType!,
          initialTitle: title,
          initialTarget: target,
          initialTargetUnit: targetUnit,
        );
        if (result == null) {
          return;
        } else if (result.goBack) {
          currentStep = 1;
        } else {
          title = result.title;
          target = result.target;
          targetUnit = result.targetUnit;
          currentStep = 3;
        }
      } else if (currentStep == 3) {
        if (!context.mounted) return;
        final success = await _openDetailSheet(
          context,
          selectedType!,
          title!,
          target,
          targetUnit,
        );
        if (success == false) {
          currentStep = 2;
        } else {
          return;
        }
      }
    }
  }

  Future<bool?> _openDetailSheet(
    BuildContext context,
    RecordType type,
    String title,
    int? target,
    String? targetUnit,
  ) async {
    final provider = context.read<RecordProvider>();

    switch (type) {
      case RecordType.habit:
        final details = await showHabitDetailsSheet(context);
        if (details == null || !context.mounted) return null;
        if (details.goBack) return false;
        await provider.createRecord(
          RecordModel(
            id: const Uuid().v4(),
            type: RecordType.habit,
            title: title,
            repeatDays: details.repeatDays,
            intervalDays: details.intervalDays,
            targetProgress: target ?? 100,
            targetUnit: targetUnit,
            createdAt: DateTime.now(),
          ),
        );

      case RecordType.event:
        final timing = await showTaskTimingSheet(context);
        if (timing == null || !context.mounted) return null;
        if (timing.goBack) return false;
        await provider.createRecord(
          RecordModel(
            id: const Uuid().v4(),
            type: RecordType.event,
            title: title,
            scheduledTime: timing.startTime,
            scheduledDate: CalendarDate.ymd(timing.startDate),
            endDate: timing.endDate != null
                ? CalendarDate.ymd(timing.endDate!)
                : null,
            endTime: timing.endDate != null
                ? DateFormat('HH:mm').format(timing.endDate!)
                : null,
            createdAt: DateTime.now(),
          ),
        );

      case RecordType.todo:
        final todoDetails = await showTodoDetailsSheet(context);
        if (todoDetails == null || !context.mounted) return null;
        if (todoDetails.goBack) return false;
        await provider.createRecord(
          RecordModel(
            id: const Uuid().v4(),
            type: RecordType.todo,
            title: title,
            priority: todoDetails.priority,
            dueDate: todoDetails.dueDate,
            createdAt: DateTime.now(),
          ),
        );
    }

    if (context.mounted) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"$title" eklendi 🎉'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
    return true;
  }

  int _locationToIndex(String navPath) {
    if (navPath.startsWith(AppRoutes.focusParent)) return 3;
    if (navPath.startsWith(AppRoutes.profile)) return 2;
    return 0;
  }
}

IconData _focusClusterIcon(String navPath) {
  if (navPath.startsWith(AppRoutes.focusHabits)) return Icons.repeat_rounded;
  if (navPath.startsWith(AppRoutes.focusTodos)) return Icons.checklist_rounded;
  return Icons.calendar_today_rounded;
}

class _CustomBottomNavBar extends StatelessWidget {
  const _CustomBottomNavBar({
    required this.selectedIndex,
    required this.focusClusterIcon,
    required this.onDestinationSelected,
    required this.onCalendarTap,
    required this.onCalendarLongPress,
  });

  final int selectedIndex;
  final IconData focusClusterIcon;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onCalendarTap;
  final VoidCallback onCalendarLongPress;

  @override
  Widget build(BuildContext context) {
    final track = context.track;
    final edge = track.neoStackShadow;

    return Transform.rotate(
      angle: 0.0174533,
      child: Container(
        height: AppSpacing.mainShellBottomNavHeight,
        margin: EdgeInsets.zero,
        width: MediaQuery.of(context).size.width + 8,
        decoration: BoxDecoration(
          color: track.neoChromePlate,
          border: Border(top: BorderSide(color: edge, width: 4.0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              isSelected: selectedIndex == 0,
              onTap: () => onDestinationSelected(0),
            ),
            _NavItem(
              icon: Icons.palette_rounded,
              isSelected: selectedIndex == 1,
              onTap: () {},
            ),
            Transform.translate(
              offset: const Offset(0, -24),
              child: Transform.rotate(
                angle: -0.0349066,
                child: GestureDetector(
                  onTap: () => onDestinationSelected(1),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: track.neoStackFace,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: edge, width: 3.0),
                      boxShadow: [
                        BoxShadow(
                          color: edge,
                          offset: const Offset(5, 5),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: track.neoStackOnFace,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
            _NavItem(
              icon: focusClusterIcon,
              isSelected: selectedIndex == 3,
              onTap: onCalendarTap,
              onLongPress: onCalendarLongPress,
            ),
            _NavItem(
              icon: Icons.person_rounded,
              isSelected: selectedIndex == 2,
              onTap: () => onDestinationSelected(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.onLongPress,
  });
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final track = context.track;
    final iconColor = isSelected
        ? track.neoStackFace
        : track.neoStackShadow.withValues(alpha: 0.42);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: Transform.rotate(
        angle: -0.0174533,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(
            icon,
            size: 24,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}

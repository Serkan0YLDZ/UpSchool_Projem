import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:my_new_habit/core/utils/agent_arch_debug_log.dart';
import 'package:my_new_habit/core/utils/calendar_date.dart';
import 'package:my_new_habit/core/router/app_router.dart';
import 'package:my_new_habit/core/theme/app_colors.dart';
import 'package:my_new_habit/core/theme/app_spacing.dart';
import 'package:my_new_habit/data/models/record_model.dart';
import 'package:my_new_habit/modals/add_record_modal.dart';
import 'package:my_new_habit/modals/habit_details_sheet.dart';
import 'package:my_new_habit/modals/naming_modal.dart';
import 'package:my_new_habit/modals/task_timing_sheet.dart';
import 'package:my_new_habit/modals/focus_mode_picker_sheet.dart';
import 'package:my_new_habit/screens/focus/focus_section.dart';
import 'package:my_new_habit/modals/todo_details_sheet.dart';
import 'package:my_new_habit/providers/record_provider.dart';

/// Ana navigasyon kabuğu.
///
/// 3 tab: 🏠 Ana Sayfa · ➕ Ekle · 👤 Profil
/// "Ekle" sekmesi doğrudan bir sayfa değil; bottom sheet akışı açar.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // #region agent log
    try {
      context.read<RecordProvider>();
      agentArchDebugLog(
        hypothesisId: 'H5',
        location: 'main_shell.dart:MainShell.build',
        message: 'shell_provider_scope_ok',
        data: {'hasRecordProvider': true},
      );
    } catch (e) {
      agentArchDebugLog(
        hypothesisId: 'H5',
        location: 'main_shell.dart:MainShell.build',
        message: 'shell_provider_scope_fail',
        data: {'error': e.toString()},
      );
    }
    // #endregion
    final state = GoRouterState.of(context);
    final navPath = state.uri.path;
    final selectedIndex = _locationToIndex(navPath);
    final focusClusterIcon = _focusClusterIcon(navPath);

    return Scaffold(
      extendBody: true, // Body'nin navigation bar arkasına uzaması için
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
                if (path.startsWith(AppRoutes.focusParent)) {
                  return;
                }
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

  /// Sprint 5 ekleme akışı:
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
        if (selectedType == null) {
          return;
        } else {
          currentStep = 2;
        }
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
        final success = await _openDetailSheet(context, selectedType!, title!, target, targetUnit);
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
        if (details == null || !context.mounted) return null; // dismissed
        if (details.goBack) return false; // go back

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
        break;

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
        break;

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
        break;
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
  if (navPath.startsWith(AppRoutes.focusHabits)) {
    return Icons.repeat_rounded;
  }
  if (navPath.startsWith(AppRoutes.focusTodos)) {
    return Icons.checklist_rounded;
  }
  return Icons.calendar_today_rounded;
}

// ─────────────────────────────────────────────────────────────────────────────

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
    return Transform.rotate(
      angle: 0.0174533, // ~1 degree rotation
      child: Container(
        height: AppSpacing.mainShellBottomNavHeight,
        margin: EdgeInsets.zero,
        width: MediaQuery.of(context).size.width + 8,
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          border: Border(
            top: BorderSide(color: AppColors.brutalistBlack, width: 4.0),
          ),
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
              icon: Icons.palette_rounded, // or any other unselected icon
              isSelected: selectedIndex == 1,
              onTap: () {}, // Add your action here if needed or change logic
            ),
            // Central FAB
            Transform.translate(
              offset: const Offset(0, -24),
              child: Transform.rotate(
                angle: -0.0349066, // ~ -2 degrees
                child: GestureDetector(
                  onTap: () => onDestinationSelected(
                    1,
                  ), // Using index 1 as ADD action from previous logic
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.brutalistBlack,
                        width: 4.0,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.brutalistBlack,
                          offset: Offset(6, 6),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: AppColors.brutalistWhite,
                      size: 32,
                      weight: 700,
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
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: Transform.rotate(
        angle: -0.0174533, // Rotate back slightly
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(
            icon,
            size: 24,
            color: isSelected
                ? AppColors.primaryContainer
                : AppColors.onSurface,
          ),
        ),
      ),
    );
  }
} // End of file

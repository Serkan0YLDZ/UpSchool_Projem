import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:track_calendar_tasks_habits/core/router/app_router.dart';
import 'package:track_calendar_tasks_habits/core/theme/app_colors.dart';
import 'package:track_calendar_tasks_habits/core/theme/app_spacing.dart';
import 'package:track_calendar_tasks_habits/core/theme/app_typography.dart';
import 'package:track_calendar_tasks_habits/core/theme/track_custom_colors.dart';

import 'package:track_calendar_tasks_habits/data/models/calendar_event_model.dart';
import 'package:track_calendar_tasks_habits/data/models/habit_model.dart';
import 'package:track_calendar_tasks_habits/data/models/todo_model.dart';
import 'package:track_calendar_tasks_habits/presentation/modals/add_record_modal.dart';
import 'package:track_calendar_tasks_habits/presentation/modals/focus_mode_picker_sheet.dart';
import 'package:track_calendar_tasks_habits/presentation/modals/habit_details_sheet.dart';
import 'package:track_calendar_tasks_habits/presentation/modals/habit_icon_sheet.dart';
import 'package:track_calendar_tasks_habits/presentation/modals/naming_modal.dart';
import 'package:track_calendar_tasks_habits/presentation/modals/task_timing_sheet.dart';
import 'package:track_calendar_tasks_habits/presentation/modals/todo_details_sheet.dart';
import 'package:track_calendar_tasks_habits/core/enums/item_type.dart';
import 'package:track_calendar_tasks_habits/presentation/providers/calendar_event_provider.dart';
import 'package:track_calendar_tasks_habits/presentation/providers/habit_provider.dart';
import 'package:track_calendar_tasks_habits/presentation/providers/todo_provider.dart';
import 'package:track_calendar_tasks_habits/presentation/screens/focus/focus_section.dart';

/// Ana navigasyon kabuğu — 3 tab + merkezi FAB ekle butonu.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  /// Son ziyaret edilen odak rotası (bellek). İlk açılışta Takvim varsayılan.
  static String _lastFocusRoute = AppRoutes.focusCalendar;

  @override
  Widget build(BuildContext context) {
    final state = GoRouterState.of(context);
    final navPath = state.uri.path;
    final selectedIndex = _locationToIndex(navPath);

    // Odak bölümündeyken son rotayı güncelle (bellek).
    if (navPath.startsWith(AppRoutes.focusParent)) {
      _lastFocusRoute = navPath;
    }

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
              currentNavPath: navPath,
              onDestinationSelected: (index) => _onNavTap(context, index),
              onFocusTap: () {
                // Odak dışındaysa son kaldığı bölüme git.
                if (!navPath.startsWith(AppRoutes.focusParent)) {
                  context.go(_lastFocusRoute);
                }
              },
              onFocusDoubleTap: () =>
                  context.go(_nextFocusRoute(navPath)),
              onFocusLongPress: () => _openFocusModePicker(context),
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
    ItemType? selectedType;
    String? title;
    int? target;
    String? targetUnit;
    List<String> habitRepeatDays = [];
    int? habitIntervalDays;
    String? iconKey;
    int? iconColor;

    while (currentStep > 0 && currentStep <= 4 && context.mounted) {
      if (currentStep == 1) {
        selectedType = null;
        title = null;
        target = null;
        targetUnit = null;
        habitRepeatDays = [];
        habitIntervalDays = null;
        iconKey = null;
        iconColor = null;
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
        if (selectedType == ItemType.habit) {
          // Alışkanlık için 4 adımlı akış
          final details = await showHabitDetailsSheet(
            context,
            initialRepeatDays: habitRepeatDays,
            initialIntervalDays: habitIntervalDays,
          );
          if (details == null || !context.mounted) return;
          if (details.goBack) {
            currentStep = 2;
          } else {
            habitRepeatDays = details.repeatDays;
            habitIntervalDays = details.intervalDays;
            currentStep = 4;
          }
        } else {
          // Event / Todo için eski 3. adım
          final success = await _openDetailSheet(context, selectedType!, title!, target, targetUnit);
          if (success == false) {
            currentStep = 2;
          } else {
            return;
          }
        }
      } else if (currentStep == 4) {
        // 4. adım: İkon & Renk seçimi (yalnızca habit)
        if (!context.mounted) return;
        final iconResult = await showHabitIconSheet(
          context,
          initialIconKey: iconKey,
          initialIconColor: iconColor,
        );
        if (iconResult == null) return;
        if (iconResult.goBack) {
          currentStep = 3;
        } else {
          iconKey = iconResult.iconKey;
          iconColor = iconResult.iconColor;
          // Kayıt oluştur
          if (!context.mounted) return;
          final provider = context.read<HabitProvider>();
          final isIntervalBased = habitIntervalDays != null && habitIntervalDays > 0;
          await provider.addHabit(
            HabitModel(
              id: const Uuid().v4(),
              title: title!,
              scheduleKind: isIntervalBased ? ScheduleKind.interval : ScheduleKind.weekly,
              intervalDays: isIntervalBased ? habitIntervalDays : null,
              weeklyDaysMask: isIntervalBased ? null : _daysToMask(habitRepeatDays),
              anchorDate: DateTime.now().toIso8601String().split('T').first,
              targetProgress: target ?? 100,
              iconKey: iconKey,
              iconColorArgb: iconColor,
              createdAt: DateTime.now().toIso8601String(),
              updatedAt: DateTime.now().toIso8601String(),
            ),
          );
          if (context.mounted) {
            final track = context.track;
            HapticFeedback.mediumImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Text('"$title" eklendi!',
                    style: AppTypography.labelLg.copyWith(color: Colors.white))),
                ]),
                backgroundColor: track.brutalistInk,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  side: const BorderSide(color: Colors.white, width: 2),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
          return;
        }
      }
    }
  }

  Future<bool?> _openDetailSheet(
    BuildContext context,
    ItemType type,
    String title,
    int? target,
    String? targetUnit,
  ) async {
    switch (type) {
      case ItemType.habit:
        // habit artık bu fonksiyona gelmiyor, 4 adımlı ayrı blokta işleniyor
        return false;

      case ItemType.event:
        final timing = await showTaskTimingSheet(context);
        if (timing == null || !context.mounted) return null;
        if (timing.goBack) return false;
        
        final provider = context.read<CalendarEventProvider>();
        
        // timing.startDate (DateTime) -> iso8601 string yapılıyor
        // Başlangıç tarihi (starts_at) birleştiriliyor: date + time
        final startParts = timing.startTime.split(':');
        final startsAt = DateTime(
          timing.startDate.year, timing.startDate.month, timing.startDate.day,
          int.parse(startParts[0]), int.parse(startParts[1]),
        );
        
        DateTime? endsAt;
        if (timing.endDate != null) {
          // Eğer endsAt için bir zaman seçiliyorsa (UI'da şu an time yoksa) default olarak +1 saat yapabiliriz. 
          endsAt = DateTime(
            timing.endDate!.year, timing.endDate!.month, timing.endDate!.day,
            int.parse(startParts[0]) + 1, int.parse(startParts[1]),
          );
        }

        await provider.addEvent(
          CalendarEventModel(
            id: const Uuid().v4(),
            title: title,
            startsAt: startsAt.toIso8601String(),
            endsAt: endsAt?.toIso8601String(),
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
          ),
        );

      case ItemType.todo:
        final todoDetails = await showTodoDetailsSheet(context);
        if (todoDetails == null || !context.mounted) return null;
        if (todoDetails.goBack) return false;
        
        final provider = context.read<TodoProvider>();
        await provider.addTodo(
          TodoModel(
            id: const Uuid().v4(),
            title: title,
            priority: todoDetails.priority,
            dueDate: todoDetails.dueDate?.toIso8601String(),
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
          ),
        );
    }

    if (context.mounted) {
      final track = context.track;
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  '"$title" eklendi!',
                  style: AppTypography.labelLg.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: track.brutalistInk,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            side: const BorderSide(color: Colors.white, width: 2),
          ),
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

  /// Sıradaki odak rotasını döndürür (çift dokunuş döngüsü).
  static String _nextFocusRoute(String currentPath) {
    if (currentPath.startsWith(AppRoutes.focusCalendar)) {
      return AppRoutes.focusHabits;
    }
    if (currentPath.startsWith(AppRoutes.focusHabits)) {
      return AppRoutes.focusTodos;
    }
    if (currentPath.startsWith(AppRoutes.focusTodos)) {
      return AppRoutes.focusCalendar;
    }
    return AppRoutes.focusCalendar; // odak dışındayken → takvimden başla
  }

  int _daysToMask(List<String> days) {
    if (days.isEmpty) return 0;
    int mask = 0;
    const map = {
      'mon': 1, 'tue': 2, 'wed': 4, 'thu': 8, 'fri': 16, 'sat': 32, 'sun': 64
    };
    for (final d in days) {
      mask |= map[d.toLowerCase()] ?? 0;
    }
    return mask;
  }
}

class _CustomBottomNavBar extends StatelessWidget {
  const _CustomBottomNavBar({
    required this.selectedIndex,
    required this.currentNavPath,
    required this.onDestinationSelected,
    required this.onFocusTap,
    required this.onFocusDoubleTap,
    required this.onFocusLongPress,
  });

  final int selectedIndex;
  final String currentNavPath;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onFocusTap;
  final VoidCallback onFocusDoubleTap;
  final VoidCallback onFocusLongPress;

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
            _TriangleCornerNav(
              currentPath: currentNavPath,
              onTap: onFocusTap,
              onDoubleTap: onFocusDoubleTap,
              onLongPress: onFocusLongPress,
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
  });
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final track = context.track;
    final iconColor = isSelected
        ? track.neoStackFace
        : track.neoStackShadow.withValues(alpha: 0.42);

    return GestureDetector(
      onTap: onTap,
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

/// Üç mod ikonunu üçgenin köşeleri gibi dizer.
/// Üçgen çizilmez — sadece köşe konumlaması kullanılır.
/// - Tek dokunuş : değişiklik yok.
/// - Çift dokunuş: sıradaki moda geçiş (Takvim→Alışkanlık→Yapılacaklar→…).
/// - Uzun basış  : mod seçici (picker) açılır.
class _TriangleCornerNav extends StatelessWidget {
  const _TriangleCornerNav({
    required this.currentPath,
    required this.onTap,
    required this.onDoubleTap,
    required this.onLongPress,
  });

  final String currentPath;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final VoidCallback onLongPress;

  String _semanticLabel(bool cal, bool hab, bool tod) {
    if (cal) return 'Takvim görünümü (seçili)';
    if (hab) return 'Alışkanlık görünümü (seçili)';
    if (tod) return 'Yapılacaklar görünümü (seçili)';
    return 'Mod seçici: Takvim, Alışkanlık, Yapılacaklar';
  }

  @override
  Widget build(BuildContext context) {
    final isCalendar = currentPath.startsWith(AppRoutes.focusCalendar);
    final isHabits = currentPath.startsWith(AppRoutes.focusHabits);
    final isTodos = currentPath.startsWith(AppRoutes.focusTodos);

    return Semantics(
      label: _semanticLabel(isCalendar, isHabits, isTodos),
      button: true,
      child: GestureDetector(
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        onLongPress: onLongPress,
        behavior: HitTestBehavior.opaque,
        child: Transform.rotate(
          angle: -0.0174533,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Üst köşe — Takvim
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _CornerIcon(
                        icon: Icons.calendar_today_rounded,
                        color: AppColors.homeSectionCalendarBlue,
                        isActive: isCalendar,
                      ),
                    ),
                  ),
                  // Sol alt köşe — Alışkanlık
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: _CornerIcon(
                      icon: Icons.repeat_rounded,
                      color: AppColors.homeSectionHabitsCoral,
                      isActive: isHabits,
                    ),
                  ),
                  // Sağ alt köşe — Yapılacaklar
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: _CornerIcon(
                      icon: Icons.checklist_rounded,
                      color: AppColors.homeSectionTodosOrange,
                      isActive: isTodos,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tek bir köşe ikonu — aktif ise büyük + renkli, pasif ise küçük + soluk.
class _CornerIcon extends StatelessWidget {
  const _CornerIcon({
    required this.icon,
    required this.color,
    required this.isActive,
  });

  final IconData icon;
  final Color color;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final track = context.track;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isActive ? 1.0 : 0.38,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: Icon(
          icon,
          size: isActive ? 20 : 14,
          color: isActive ? color : track.neoStackShadow,
        ),
      ),
    );
  }
}

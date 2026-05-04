import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:my_new_habit/core/router/app_router.dart';
import 'package:my_new_habit/core/theme/app_colors.dart';
import 'package:my_new_habit/core/theme/app_spacing.dart';
import 'package:my_new_habit/data/models/record_model.dart';
import 'package:my_new_habit/modals/add_record_modal.dart';
import 'package:my_new_habit/modals/habit_details_sheet.dart';
import 'package:my_new_habit/modals/naming_modal.dart';
import 'package:my_new_habit/modals/task_timing_sheet.dart';
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
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _locationToIndex(location);

    return Scaffold(
      extendBody: true, // Body'nin navigation bar arkasına uzaması için
      body: child,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _CustomBottomNavBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => _onNavTap(context, index),
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

  /// Sprint 2 ekleme akışı:
  /// Adım 1 → tip seç · Adım 2 → isim gir · Adım 3 → tipine göre detay
  Future<void> _openAddFlow(BuildContext context) async {
    RecordType? selectedType;

    await showAddRecordModal(
      context,
      onTypeSelected: (type) {
        selectedType = type;
        Navigator.of(context).pop();
      },
    );

    if (selectedType == null || !context.mounted) return;

    String? title;

    title = await showNamingModal(context, type: selectedType!);
    if (title == null || !context.mounted) return;

    await _openDetailSheet(context, selectedType!, title);
  }

  Future<void> _openDetailSheet(
    BuildContext context,
    RecordType type,
    String title,
  ) async {
    final provider = context.read<RecordProvider>();

    switch (type) {
      case RecordType.habit:
        final details = await showHabitDetailsSheet(context);
        if (details == null || !context.mounted) return;
        await provider.createRecord(
          RecordModel(
            id: const Uuid().v4(),
            type: RecordType.habit,
            title: title,
            repeatDays: details.repeatDays,
            intervalDays: details.intervalDays,
            targetProgress: 100,
            createdAt: DateTime.now(),
          ),
        );

      case RecordType.event:
        final timing = await showTaskTimingSheet(context);
        if (timing == null || !context.mounted) return;
        await provider.createRecord(
          RecordModel(
            id: const Uuid().v4(),
            type: RecordType.event,
            title: title,
            scheduledTime: timing.startTime,
            scheduledDate: DateFormat('yyyy-MM-dd').format(timing.startDate),
            endDate: timing.endDate != null
                ? DateFormat('yyyy-MM-dd').format(timing.endDate!)
                : null,
            endTime: timing.endDate != null
                ? DateFormat('HH:mm').format(timing.endDate!)
                : null,
            createdAt: DateTime.now(),
          ),
        );

      case RecordType.todo:
        // TODO: Sprint 5'te Todo form sheet eklenecek. Şimdilik düz createdAt ile ekliyoruz.
        final todoDetails = await showTodoDetailsSheet(context);
        if (todoDetails == null || !context.mounted) return;

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
  }

  int _locationToIndex(String location) {
    if (location.startsWith(AppRoutes.profile)) return 2;
    return 0;
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CustomBottomNavBar extends StatelessWidget {
  const _CustomBottomNavBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    // Tasarımdaki w-3/5 (genişliğin %60'ı) max-w-xs (320px) özelliğini sağlıyoruz
    final screenWidth = MediaQuery.of(context).size.width;
    final width = (screenWidth * 0.6).clamp(0.0, 320.0);

    return Container(
      width: width,
      height: AppSpacing.xxl,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        boxShadow: [
          BoxShadow(
            // %15 opaklık: tasarımdaki pill shadow'un ana renkten türetilmesi
            color: AppColors.primaryContainer.withAlpha(38),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            isSelected: selectedIndex == 0,
            onTap: () => onDestinationSelected(0),
          ),
          _NavItem(
            icon: Icons.add_rounded,
            isSelected: selectedIndex == 1,
            iconSize: 28, // HTML'de "text-[28px]" kullanılmıştı
            onTap: () => onDestinationSelected(1),
          ),
          _NavItem(
            icon: Icons.person_rounded,
            isSelected: selectedIndex == 2,
            onTap: () => onDestinationSelected(2),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.iconSize = 24,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
          size: iconSize,
        ),
      ),
    );
  }
}

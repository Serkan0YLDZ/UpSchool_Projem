import 'package:flutter/material.dart';

import 'package:track_calendar_tasks_habits/core/enums/item_type.dart';
import 'package:track_calendar_tasks_habits/core/theme/app_colors.dart';

/// Takvim (etkinlik) / alışkanlık / yapılacaklar için ana sayfa ile aynı şerit renkleri.
Color recordTypeSectionAccent(ItemType type) {
  return switch (type) {
    ItemType.event => AppColors.homeSectionCalendarBlue,
    ItemType.habit => AppColors.homeSectionHabitsCoral,
    ItemType.todo => AppColors.homeSectionTodosOrange,
  };
}

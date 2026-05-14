import 'package:flutter/material.dart';

import '../../data/models/record_model.dart';
import 'app_colors.dart';

/// Takvim (etkinlik) / alışkanlık / yapılacaklar için ana sayfa ile aynı şerit renkleri.
Color recordTypeSectionAccent(RecordType type) {
  return switch (type) {
    RecordType.event => AppColors.homeSectionCalendarBlue,
    RecordType.habit => AppColors.homeSectionHabitsCoral,
    RecordType.todo => AppColors.homeSectionTodosOrange,
  };
}

import 'package:my_new_habit/data/models/record_model.dart';
import 'package:my_new_habit/providers/record_provider.dart';
import 'package:my_new_habit/providers/streak_provider.dart';

/// Ana sayfadaki takvim günü için listelenen alışkanlıklar (seri gizleme kurallarıyla).
List<RecordModel> visibleHabitsForSelectedDate(
  RecordProvider recordProvider,
  StreakProvider streakProvider,
) {
  return recordProvider.habits.where((h) {
    return !streakProvider.isHabitHiddenOnSelectedDate(
      h.id,
      recordProvider.selectedDate,
    );
  }).toList();
}

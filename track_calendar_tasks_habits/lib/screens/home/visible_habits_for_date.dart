import '../../data/models/record_model.dart';
import '../../providers/record_provider.dart';
import '../../providers/streak_provider.dart';

/// Seçili takvim günü için seri gizleme kurallarına göre filtrelenmiş alışkanlıklar.
List<RecordModel> visibleHabitsForSelectedDate(
  RecordProvider recordProvider,
  StreakProvider streakProvider,
) {
  return recordProvider.habits.where((h) {
    return !streakProvider.isHabitHiddenOnSelectedDate(h.id, recordProvider.selectedDate);
  }).toList();
}

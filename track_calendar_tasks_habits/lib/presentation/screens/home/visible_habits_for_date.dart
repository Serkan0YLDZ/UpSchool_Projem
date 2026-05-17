import 'package:track_calendar_tasks_habits/data/models/habit_model.dart';
import 'package:track_calendar_tasks_habits/presentation/providers/streak_provider.dart';
import 'package:track_calendar_tasks_habits/core/utils/calendar_date.dart';

/// Seçili takvim günü için görünür olması gereken alışkanlıkları filtreler.
List<HabitModel> visibleHabitsForSelectedDate(
  List<HabitModel> allHabits,
  StreakProvider streakProvider,
  String selectedDate,
) {
  final todayYmd = CalendarDate.todayYmd();
  
  return allHabits.where((h) {
    final view = streakProvider.viewFor(h, selectedDate, todayYmd);
    
    // Eğer alışkanlık serisi kapanmışsa sadece geçmişte tamamlandığı günlerde göster.
    if (view.isClosed) {
      return view.isCompletedToday;
    }
    
    // Planlanmış günse, recovery günüyse veya o gün yapılmışsa göster
    return view.isScheduledToday || view.isRecovery || view.isCompletedToday || view.isMissedToday || view.isSkippedToday;
  }).toList();
}

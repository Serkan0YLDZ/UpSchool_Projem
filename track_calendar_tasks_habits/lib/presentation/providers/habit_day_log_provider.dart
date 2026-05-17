import 'package:flutter/foundation.dart';
import 'package:track_calendar_tasks_habits/data/models/habit_day_log_model.dart';
import 'package:track_calendar_tasks_habits/data/repositories/habit_day_log_repository.dart';

class HabitDayLogProvider extends ChangeNotifier {
  final HabitDayLogRepository repository;

  HabitDayLogProvider({required this.repository});

  List<HabitDayLogModel> _logsForDate = [];
  List<HabitDayLogModel> get logsForDate => _logsForDate;

  Future<void> loadLogsForDate(String date) async {
    _logsForDate = await repository.getByDate(date);
    notifyListeners();
  }

  Future<void> upsertLog(HabitDayLogModel log) async {
    await repository.upsert(log);
    // Sadece mevcut tarihin loglarını güncelleriz
    await loadLogsForDate(log.calendarDate);
  }

  Future<HabitDayLogModel?> getLogForDate(String habitId, String date) async {
    return await repository.getByHabitAndDate(habitId, date);
  }
}

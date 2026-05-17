import 'package:flutter/foundation.dart';
import 'package:track_calendar_tasks_habits/data/models/habit_model.dart';
import 'package:track_calendar_tasks_habits/data/repositories/habit_repository.dart';

class HabitProvider extends ChangeNotifier {
  final HabitRepository repository;
  
  HabitProvider({required this.repository});
  
  List<HabitModel> _habits = [];
  List<HabitModel> get habits => _habits;
  
  Future<void> loadHabits() async {
    _habits = await repository.getActive();
    notifyListeners();
  }
  
  Future<void> addHabit(HabitModel habit) async {
    await repository.insert(habit);
    await loadHabits();
  }
  
  Future<void> updateHabit(HabitModel habit) async {
    await repository.update(habit);
    await loadHabits();
  }
  
  Future<void> deleteHabit(String id) async {
    await repository.softDelete(id);
    await loadHabits();
  }
}

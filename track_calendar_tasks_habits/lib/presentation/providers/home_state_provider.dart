import 'package:flutter/foundation.dart';
import 'package:track_calendar_tasks_habits/core/utils/calendar_date.dart';

enum FilterType {
  mostImportant,
  earliest,
  thisWeek,
  thisMonth,
  todoDone,
  todoTodo,
}

class HomeStateProvider extends ChangeNotifier {
  final Set<FilterType> _activeFilters = {};
  String _selectedDate = CalendarDate.todayYmd();

  String get selectedDate => _selectedDate;
  Set<FilterType> get activeFilters => _activeFilters;

  void selectDate(String date) {
    _selectedDate = date;
    notifyListeners();
  }

  void toggleFilter(FilterType filter) {
    if (_activeFilters.contains(filter)) {
      _activeFilters.remove(filter);
    } else {
      if (filter == FilterType.mostImportant || filter == FilterType.earliest) {
        _activeFilters.remove(FilterType.mostImportant);
        _activeFilters.remove(FilterType.earliest);
      } else if (filter == FilterType.thisWeek || filter == FilterType.thisMonth) {
        _activeFilters.remove(FilterType.thisWeek);
        _activeFilters.remove(FilterType.thisMonth);
      } else if (filter == FilterType.todoDone || filter == FilterType.todoTodo) {
        _activeFilters.remove(FilterType.todoDone);
        _activeFilters.remove(FilterType.todoTodo);
      }
      _activeFilters.add(filter);
    }
    notifyListeners();
  }

  void clearFilters() {
    _activeFilters.clear();
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';
import 'package:track_calendar_tasks_habits/data/models/calendar_event_model.dart';
import 'package:track_calendar_tasks_habits/data/repositories/calendar_event_repository.dart';

class CalendarEventProvider extends ChangeNotifier {
  final CalendarEventRepository repository;
  
  CalendarEventProvider({required this.repository});
  
  List<CalendarEventModel> _events = [];
  List<CalendarEventModel> get events => _events;
  
  Future<void> loadEvents(String date) async {
    _events = await repository.getByDate(date);
    notifyListeners();
  }

  Future<void> loadActiveEvents() async {
    _events = await repository.getActive();
    notifyListeners();
  }
  
  Future<void> addEvent(CalendarEventModel event) async {
    await repository.insert(event);
    _events.add(event);
    notifyListeners();
  }
  
  Future<void> updateEvent(CalendarEventModel event) async {
    await repository.update(event);
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _events[index] = event;
      notifyListeners();
    }
  }
  
  Future<void> deleteEvent(String id) async {
    await repository.softDelete(id);
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/utils/calendar_date.dart';
import '../data/models/record_model.dart';
import '../data/repositories/record_repository.dart';

enum FilterType {
  mostImportant,
  earliest,
  thisWeek,
  thisMonth,
  todoDone,
  todoTodo,
}

class RecordProvider extends ChangeNotifier {
  RecordProvider(this._repository);

  final RecordRepository _repository;

  List<RecordModel> _records = [];
  bool _isLoading = false;
  String? _errorMessage;
  final Set<FilterType> _activeFilters = {};
  String _selectedDate = CalendarDate.todayYmd();

  List<RecordModel> get records => List.unmodifiable(_records);
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  String get selectedDate => _selectedDate;
  Set<FilterType> get activeFilters => _activeFilters;

  List<RecordModel> get scheduledTasks =>
      _records
          .where((r) => r.type == RecordType.event && r.scheduledTime != null)
          .toList()
        ..sort((a, b) => (a.scheduledTime ?? '').compareTo(b.scheduledTime ?? ''));

  List<RecordModel> get habits =>
      _applyHabitFilter(_records.where((r) => r.type == RecordType.habit).toList());

  List<RecordModel> get todos =>
      _applyTodoFilter(_records.where((r) => r.type == RecordType.todo).toList());

  Future<void> loadRecords() async {
    _setLoading(true);
    try {
      _records = await _repository.getByDate(_selectedDate);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Kayıtlar yüklenemedi.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> selectDate(String date) async {
    _selectedDate = date;
    await loadRecords();
  }

  void toggleFilter(FilterType filter) {
    _errorMessage = null;
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

  Future<void> createRecord(RecordModel record) async {
    _setLoading(true);
    try {
      final withId = record.copyWith(id: const Uuid().v4());
      await _repository.create(withId);
      await loadRecords();
    } catch (e) {
      _errorMessage = 'Kayıt oluşturulamadı: $e';
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> updateRecord(RecordModel record) async {
    _setLoading(true);
    try {
      await _repository.update(record);
      await loadRecords();
    } catch (e) {
      _errorMessage = 'Kayıt güncellenemedi.';
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> deleteRecord(String id) async {
    _setLoading(true);
    try {
      await _repository.delete(id);
      await loadRecords();
    } catch (e) {
      _errorMessage = 'Kayıt silinemedi.';
      _setLoading(false);
      notifyListeners();
    }
  }

  List<RecordModel> _applyHabitFilter(List<RecordModel> source) {
    const order = [Priority.high, Priority.medium, Priority.low];
    if (_activeFilters.contains(FilterType.earliest)) {
      source.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else {
      source.sort((a, b) {
        return order.indexOf(a.priority ?? Priority.low)
            .compareTo(order.indexOf(b.priority ?? Priority.low));
      });
    }

    if (_activeFilters.contains(FilterType.thisWeek)) {
      final now = DateTime.now();
      final startOfWeek = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(
        const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
      );
      return source
          .where((r) =>
              !r.createdAt.isBefore(startOfWeek) && !r.createdAt.isAfter(endOfWeek))
          .toList();
    } else if (_activeFilters.contains(FilterType.thisMonth)) {
      final now = DateTime.now();
      return source
          .where((r) => r.createdAt.year == now.year && r.createdAt.month == now.month)
          .toList();
    }

    return source;
  }

  List<RecordModel> _applyTodoFilter(List<RecordModel> source) {
    const order = [Priority.high, Priority.medium, Priority.low];
    if (_activeFilters.contains(FilterType.earliest)) {
      source.sort((a, b) =>
          (a.dueDate ?? DateTime(9999)).compareTo(b.dueDate ?? DateTime(9999)));
    } else {
      source.sort((a, b) {
        return order.indexOf(a.priority ?? Priority.low)
            .compareTo(order.indexOf(b.priority ?? Priority.low));
      });
    }

    if (_activeFilters.contains(FilterType.thisWeek)) {
      final now = DateTime.now();
      final startOfWeek = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(
        const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
      );
      source = source.where((r) {
        if (r.dueDate == null) return true;
        return !r.dueDate!.isBefore(startOfWeek) && !r.dueDate!.isAfter(endOfWeek);
      }).toList();
    } else if (_activeFilters.contains(FilterType.thisMonth)) {
      final now = DateTime.now();
      source = source.where((r) {
        if (r.dueDate == null) return true;
        return r.dueDate!.year == now.year && r.dueDate!.month == now.month;
      }).toList();
    }

    return source;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

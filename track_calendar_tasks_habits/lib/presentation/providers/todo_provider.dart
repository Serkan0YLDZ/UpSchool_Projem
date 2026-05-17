import 'package:flutter/foundation.dart';
import 'package:track_calendar_tasks_habits/data/models/todo_model.dart';
import 'package:track_calendar_tasks_habits/data/repositories/todo_repository.dart';

enum TodoFilterType {
  todoDone,
  todoTodo,
  mostImportant,
  earliest,
  thisWeek,
  thisMonth,
}

class TodoProvider extends ChangeNotifier {
  final TodoRepository repository;
  
  TodoProvider({required this.repository});
  
  List<TodoModel> _todos = [];
  
  List<TodoModel> get todos {
    var filtered = List<TodoModel>.from(_todos);

    final hasDone = _activeFilters.contains(TodoFilterType.todoDone);
    final hasTodo = _activeFilters.contains(TodoFilterType.todoTodo);
    
    if (hasDone && !hasTodo) {
      filtered = filtered.where((t) => t.isCompleted).toList();
    } else if (hasTodo && !hasDone) {
      filtered = filtered.where((t) => !t.isCompleted).toList();
    }

    final hasThisWeek = _activeFilters.contains(TodoFilterType.thisWeek);
    final hasThisMonth = _activeFilters.contains(TodoFilterType.thisMonth);
    
    if (hasThisWeek || hasThisMonth) {
      final now = DateTime.now();
      filtered = filtered.where((t) {
        if (t.dueDate == null) return false;
        final d = DateTime.tryParse(t.dueDate!);
        if (d == null) return false;
        
        if (hasThisWeek) {
          return d.isAfter(now.subtract(const Duration(days: 1))) && 
                 d.isBefore(now.add(const Duration(days: 7)));
        } else if (hasThisMonth) {
          return d.year == now.year && d.month == now.month;
        }
        return true;
      }).toList();
    }

    final hasMostImportant = _activeFilters.contains(TodoFilterType.mostImportant);
    final hasEarliest = _activeFilters.contains(TodoFilterType.earliest);

    if (hasMostImportant) {
      filtered.sort((a, b) => a.priority.index.compareTo(b.priority.index));
    } else if (hasEarliest) {
      filtered.sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
    }

    return filtered;
  }

  final Set<TodoFilterType> _activeFilters = {};
  Set<TodoFilterType> get activeFilters => _activeFilters;

  void toggleFilter(TodoFilterType type) {
    // Grup tanımları — her gruptan en fazla 1 seçilebilir (radio-group)
    const statusGroup = {TodoFilterType.todoDone, TodoFilterType.todoTodo};
    const sortGroup = {TodoFilterType.mostImportant, TodoFilterType.earliest};
    const timeGroup = {TodoFilterType.thisWeek, TodoFilterType.thisMonth};

    Set<TodoFilterType> group = {};
    if (statusGroup.contains(type)) group = statusGroup;
    if (sortGroup.contains(type)) group = sortGroup;
    if (timeGroup.contains(type)) group = timeGroup;

    if (_activeFilters.contains(type)) {
      // Zaten seçiliyse kaldır (toggle off)
      _activeFilters.remove(type);
    } else {
      // Aynı gruptaki önceki seçimi temizle, yenisini ekle
      _activeFilters.removeAll(group);
      _activeFilters.add(type);
    }
    notifyListeners();
  }

  Future<void> loadTodos() async {
    _todos = await repository.getActive();
    notifyListeners();
  }
  
  Future<void> addTodo(TodoModel todo) async {
    await repository.insert(todo);
    await loadTodos();
  }
  
  Future<void> updateTodo(TodoModel todo) async {
    await repository.update(todo);
    await loadTodos();
  }

  Future<void> markCompleted(String id, bool completed) async {
    await repository.markCompleted(id, completed);
    await loadTodos();
  }
  
  Future<void> deleteTodo(String id) async {
    await repository.softDelete(id);
    await loadTodos();
  }
}

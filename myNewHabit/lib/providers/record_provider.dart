// Sprint 3: Ana Sayfa & Takvim — RecordProvider filtreleme eklendi

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../data/models/record_model.dart';
import '../data/repositories/record_repository.dart';

/// Ana sayfadaki liste filtreleme seçenekleri (US-308 + US-503/504).
enum FilterType {
  // Sıralama (Kendi içinde exculusive)
  mostImportant,
  earliest, // Todo için: En Yakın Bitiş Tarihi
  // Zaman Aralığı (Kendi içinde exclusive)
  thisWeek,
  thisMonth,
  // Durum (Kendi içinde exclusive)
  todoDone,
  todoTodo,
}

/// Kayıt listesi state'ini yönetir ve UI'ya sunar.
///
/// DIP: `RecordRepository` abstraction'a bağımlıdır, impl'e değil.
class RecordProvider extends ChangeNotifier {
  final RecordRepository _repository;

  RecordProvider(this._repository);

  List<RecordModel> _records = [];
  bool _isLoading = false;
  String? _errorMessage;
  final Set<FilterType> _activeFilters = {};

  /// Seçili tarih ('yyyy-MM-dd') — default: bugün.
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  // ── Read-only accessors (Encapsulation) ─────────────────────────────────
  List<RecordModel> get records => List.unmodifiable(_records);
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  String get selectedDate => _selectedDate;
  Set<FilterType> get activeFilters => _activeFilters;

  /// Takvim Etkinlikleri (Event) — saat etiketine göre sıralar; filtreden etkilenmez.
  List<RecordModel> get scheduledTasks =>
      _records
          .where((r) => r.type == RecordType.event && r.scheduledTime != null)
          .toList()
        ..sort(
          (a, b) => (a.scheduledTime ?? '').compareTo(b.scheduledTime ?? ''),
        );

  /// Rutin alışkanlıklar — aktif filtreye göre sıralanır.
  List<RecordModel> get habits => _applyHabitFilter(
    _records.where((r) => r.type == RecordType.habit).toList(),
  );

  /// Yapılacaklar Listesi (Todo) — aktif filtreye göre sıralanır.
  List<RecordModel> get todos => _applyTodoFilter(
    _records.where((r) => r.type == RecordType.todo).toList(),
  );

  // ── Actions ──────────────────────────────────────────────────────────────

  /// Seçili tarihe göre kayıtları yükler.
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

  /// Takvimde farklı bir gün seçildiğinde çağrılır.
  Future<void> selectDate(String date) async {
    _selectedDate = date;
    await loadRecords();
  }

  /// Filtreyi değiştirir; anlık `notifyListeners` ile UI güncellenir.
  void toggleFilter(FilterType filter) {
    _errorMessage = null;

    if (_activeFilters.contains(filter)) {
      _activeFilters.remove(filter);
    } else {
      // Exclusivity logic
      if (filter == FilterType.mostImportant || filter == FilterType.earliest) {
        _activeFilters.remove(FilterType.mostImportant);
        _activeFilters.remove(FilterType.earliest);
      } else if (filter == FilterType.thisWeek ||
          filter == FilterType.thisMonth) {
        _activeFilters.remove(FilterType.thisWeek);
        _activeFilters.remove(FilterType.thisMonth);
      } else if (filter == FilterType.todoDone ||
          filter == FilterType.todoTodo) {
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

  /// Yeni kayıt oluşturur; ID üretimini provider üstlenir.
  Future<void> createRecord(RecordModel record) async {
    _setLoading(true);
    try {
      final withId = record.copyWith(id: const Uuid().v4());
      await _repository.create(withId);
      await loadRecords();
    } catch (e) {
      _errorMessage = 'Kayıt oluşturulamadı: $e'; // Tam hatayı göster
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Mevcut kaydı günceller.
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

  /// Kaydı siler; cascade DB'de tamamlama ve seri kayıtlarını da temizler.
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

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Aktif filtreye göre habit listesini sıralar/filtreler.
  List<RecordModel> _applyHabitFilter(List<RecordModel> source) {
    if (_activeFilters.contains(FilterType.mostImportant)) {
      const order = [Priority.high, Priority.medium, Priority.low];
      source.sort((a, b) {
        final ai = order.indexOf(a.priority ?? Priority.low);
        final bi = order.indexOf(b.priority ?? Priority.low);
        return ai.compareTo(bi);
      });
    } else if (_activeFilters.contains(FilterType.earliest)) {
      source.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else {
      const defOrder = [Priority.high, Priority.medium, Priority.low];
      source.sort((a, b) {
        final ai = defOrder.indexOf(a.priority ?? Priority.low);
        final bi = defOrder.indexOf(b.priority ?? Priority.low);
        return ai.compareTo(bi);
      });
    }

    if (_activeFilters.contains(FilterType.thisWeek)) {
      final now = DateTime.now();
      final startOfWeek = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(
        const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
      );
      return source.where((r) {
        return !r.createdAt.isBefore(startOfWeek) &&
            !r.createdAt.isAfter(endOfWeek);
      }).toList();
    } else if (_activeFilters.contains(FilterType.thisMonth)) {
      final now = DateTime.now();
      return source.where((r) {
        return r.createdAt.year == now.year && r.createdAt.month == now.month;
      }).toList();
    }

    return source;
  }

  /// Aktif filtreye göre todo listesini sıralar/filtreler.
  List<RecordModel> _applyTodoFilter(List<RecordModel> source) {
    if (_activeFilters.contains(FilterType.mostImportant)) {
      const order = [Priority.high, Priority.medium, Priority.low];
      source.sort((a, b) {
        final ai = order.indexOf(a.priority ?? Priority.low);
        final bi = order.indexOf(b.priority ?? Priority.low);
        return ai.compareTo(bi);
      });
    } else if (_activeFilters.contains(FilterType.earliest)) {
      source.sort(
        (a, b) => (a.dueDate ?? DateTime(9999)).compareTo(
          b.dueDate ?? DateTime(9999),
        ),
      );
    } else {
      const defOrder = [Priority.high, Priority.medium, Priority.low];
      source.sort((a, b) {
        final ai = defOrder.indexOf(a.priority ?? Priority.low);
        final bi = defOrder.indexOf(b.priority ?? Priority.low);
        return ai.compareTo(bi);
      });
    }

    if (_activeFilters.contains(FilterType.thisWeek)) {
      final now = DateTime.now();
      final startOfWeek = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(
        const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
      );
      source = source.where((r) {
        if (r.dueDate == null) return true; // Tarihsizler 'Tümü' sayılır
        return !r.dueDate!.isBefore(startOfWeek) &&
            !r.dueDate!.isAfter(endOfWeek);
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

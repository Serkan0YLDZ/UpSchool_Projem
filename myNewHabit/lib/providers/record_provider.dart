// Sprint 3: Ana Sayfa & Takvim — RecordProvider filtreleme eklendi

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../data/models/record_model.dart';
import '../data/repositories/record_repository.dart';

/// Ana sayfadaki liste filtreleme seçenekleri (US-308).
enum FilterType {
  all,
  mostImportant,
  earliest,
  thisWeek,
  thisMonth,
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
  FilterType _activeFilter = FilterType.all;

  /// Seçili tarih ('yyyy-MM-dd') — default: bugün.
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  // ── Read-only accessors (Encapsulation) ─────────────────────────────────
  List<RecordModel> get records => List.unmodifiable(_records);
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  String get selectedDate => _selectedDate;
  FilterType get activeFilter => _activeFilter;

  /// Saatli görevler — saat etiketine göre sıralar; filtreden etkilenmez
  /// çünkü zamanlama önceliği sabittir.
  List<RecordModel> get scheduledTasks => _records
      .where((r) => r.type == RecordType.task && r.scheduledTime != null)
      .toList()
    ..sort((a, b) => (a.scheduledTime ?? '').compareTo(b.scheduledTime ?? ''));

  /// Rutin alışkanlıklar — aktif filtreye göre sıralanır.
  List<RecordModel> get habits => _applyHabitFilter(
        _records.where((r) => r.type == RecordType.habit).toList(),
      );

  /// Bırakılan alışkanlıklar — filtre uygulanmaz, her zaman aktiftir.
  List<RecordModel> get quitRecords =>
      _records.where((r) => r.type == RecordType.quit).toList();

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
  void applyFilter(FilterType filter) {
    _errorMessage = null; // Filtre değiştiğinde hata durumunu sıfırla
    if (_activeFilter == filter) {
      // Aynı filtreye tekrar basılırsa sıfırla (toggle davranışı).
      _activeFilter = FilterType.all;
    } else {
      _activeFilter = filter;
    }
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
    switch (_activeFilter) {
      case FilterType.mostImportant:
        const order = [Priority.high, Priority.medium, Priority.low];
        return source
          ..sort((a, b) {
            final ai = order.indexOf(a.priority ?? Priority.low);
            final bi = order.indexOf(b.priority ?? Priority.low);
            return ai.compareTo(bi);
          });

      case FilterType.earliest:
        // Oluşturulma tarihine göre en eskiden yeniye sıralar.
        return source..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      case FilterType.thisWeek:
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return source.where((r) {
          if (r.endDate == null) return true;
          return !r.endDate!.isBefore(startOfWeek) &&
              !r.endDate!.isAfter(endOfWeek);
        }).toList()
          ..sort((a, b) => (a.endDate ?? DateTime(9999))
              .compareTo(b.endDate ?? DateTime(9999)));

      case FilterType.thisMonth:
        final now = DateTime.now();
        return source.where((r) {
          if (r.endDate == null) return true;
          return r.endDate!.year == now.year && r.endDate!.month == now.month;
        }).toList()
          ..sort((a, b) => (a.endDate ?? DateTime(9999))
              .compareTo(b.endDate ?? DateTime(9999)));

      case FilterType.all:
      default:
        // Varsayılan: öneme göre sırala (high > medium > low).
        const defOrder = [Priority.high, Priority.medium, Priority.low];
        return source
          ..sort((a, b) {
            final ai = defOrder.indexOf(a.priority ?? Priority.low);
            final bi = defOrder.indexOf(b.priority ?? Priority.low);
            return ai.compareTo(bi);
          });
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

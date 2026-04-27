// Sprint 2: State Yönetimi — RecordProvider

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../data/models/record_model.dart';
import '../data/repositories/record_repository.dart';

/// Kayıt listesi state'ini yönetir ve UI'ya sunar.
///
/// DIP: `RecordRepository` abstraction'a bağımlıdır, impl'e değil.
class RecordProvider extends ChangeNotifier {
  final RecordRepository _repository;

  RecordProvider(this._repository);

  List<RecordModel> _records = [];
  bool _isLoading = false;
  String? _errorMessage;

  /// Seçili tarih ('yyyy-MM-dd') — default: bugün.
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  // ── Read-only accessors (Encapsulation) ─────────────────────────────────
  List<RecordModel> get records => List.unmodifiable(_records);
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  String get selectedDate => _selectedDate;

  /// Saatli görevler — önce saate göre sıralar.
  List<RecordModel> get scheduledTasks => _records
      .where((r) => r.type == RecordType.task && r.scheduledTime != null)
      .toList()
    ..sort((a, b) => (a.scheduledTime ?? '').compareTo(b.scheduledTime ?? ''));

  /// Rutin alışkanlıklar — öneme göre (high > medium > low) sıralar.
  List<RecordModel> get habits {
    final h = _records.where((r) => r.type == RecordType.habit).toList();
    const order = [Priority.high, Priority.medium, Priority.low];
    h.sort((a, b) {
      final ai = order.indexOf(a.priority ?? Priority.low);
      final bi = order.indexOf(b.priority ?? Priority.low);
      return ai.compareTo(bi);
    });
    return h;
  }

  /// Bırakılan alışkanlıklar.
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

  /// Yeni kayıt oluşturur; ID üretimini provider üstlenir.
  Future<void> createRecord(RecordModel record) async {
    _setLoading(true);
    try {
      final withId = record.copyWith(id: const Uuid().v4());
      await _repository.create(withId);
      await loadRecords();
    } catch (e) {
      _errorMessage = 'Kayıt oluşturulamadı.';
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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

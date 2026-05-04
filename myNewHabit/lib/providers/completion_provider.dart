// Sprint 2: State Yönetimi — CompletionProvider

import 'package:flutter/foundation.dart';

import 'package:uuid/uuid.dart';

import '../data/models/completion_model.dart';
import '../data/repositories/completion_repository.dart';

/// Günlük tamamlama state'ini yönetir.
///
/// RecordProvider ile birlikte çalışır:
/// RecordProvider → hangi kayıtlar var
/// CompletionProvider → o kayıtlar bugün tamamlandı mı?
class CompletionProvider extends ChangeNotifier {
  final CompletionRepository _repository;

  CompletionProvider(this._repository);

  /// Seçili güne ait completion'lar: recordId → CompletionModel
  final Map<String, CompletionModel> _completions = {};
  bool _isLoading = false;
  String? _errorMessage;

  // ── Read-only accessors ──────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;

  /// Bir kaydın seçili gündeki completion durumunu döner.
  CompletionModel? completionFor(String recordId) => _completions[recordId];

  /// Bir kaydın bugün tamamlanıp tamamlanmadığını döner.
  bool isDone(String recordId) =>
      _completions[recordId]?.status.isDone ?? false;

  // ── Actions ──────────────────────────────────────────────────────────────

  /// Belirli bir güne ait tüm completion'ları yükler.
  Future<void> loadForDate(String date) async {
    _setLoading(true);
    try {
      final list = await _repository.getByDate(date);
      _completions
        ..clear()
        ..addEntries(list.map((c) => MapEntry(c.recordId, c)));
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Tamamlama kayıtları yüklenemedi.';
    } finally {
      _setLoading(false);
    }
  }

  /// Alışkanlığı veya görevi tamamlandı olarak işaretler.
  Future<void> markDone(
    String recordId,
    String date, {
    int progress = 100,
  }) async {
    await _mark(recordId, date, CompletionStatus.done, progress: progress);
  }

  /// Alışkanlığı es geçer.
  Future<void> markSkipped(String recordId, String date) async {
    await _mark(recordId, date, CompletionStatus.skipped, progress: 0);
  }

  /// Alışkanlığı kısmi ilerletir. Hedef değere ulaşıp ulaşmadığı
  /// UI katmanından hesaplanıp `markDone` çağrılabilir veya doğrudan burada kullanılabilir.
  Future<void> markPartial(String recordId, String date, int progress) async {
    await _mark(recordId, date, CompletionStatus.partial, progress: progress);
  }

  /// İlerleme değerini günceller (targetProgress kontrolü).
  Future<void> updateProgress(
    String recordId,
    String date,
    int progress,
    int targetProgress,
  ) async {
    if (progress >= targetProgress) {
      await markDone(recordId, date, progress: progress);
    } else {
      await markPartial(recordId, date, progress);
    }
  }

  /// Tamamlamayı geri alır.
  Future<void> undoCompletion(String recordId) async {
    final existing = _completions[recordId];
    if (existing == null) return;
    _setLoading(true);
    try {
      await _repository.delete(existing.id);
      _completions.remove(recordId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'İşlem geri alınamadı.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _mark(
    String recordId,
    String date,
    CompletionStatus status, {
    int progress = 0,
  }) async {
    _setLoading(true);
    try {
      final id = const Uuid().v4();
      switch (status) {
        case CompletionStatus.done:
          await _repository.markDone(id, recordId, date, progress: progress);
        case CompletionStatus.skipped:
          await _repository.markSkipped(id, recordId, date);
        case CompletionStatus.partial:
          await _repository.markPartial(id, recordId, date, progress);
      }
      // Local cache'i güncelle, DB'ye tekrar sorgu atmadan.
      _completions[recordId] = CompletionModel(
        id: id,
        recordId: recordId,
        date: date,
        status: status,
        progress: progress,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'İşlem kaydedilemedi.';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

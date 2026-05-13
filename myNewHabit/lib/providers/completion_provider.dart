// Sprint 2: State Yönetimi — CompletionProvider

import 'package:flutter/foundation.dart';

import '../core/utils/calendar_date.dart';
import '../data/models/completion_model.dart';
import '../data/repositories/completion_repository.dart';
import '../data/utils/completion_row_id.dart';

/// Günlük tamamlama state'ini yönetir.
///
/// RecordProvider ile birlikte çalışır:
/// RecordProvider → hangi kayıtlar var
/// CompletionProvider → o kayıtlar bugün tamamlandı mı?
class CompletionProvider extends ChangeNotifier {
  CompletionProvider(this._repository, {this.onMutated});

  final CompletionRepository _repository;
  final Future<void> Function(String recordId)? onMutated;

  static String _calendarTodayYmd() => CalendarDate.todayYmd();

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
    } catch (e, stackTrace) {
      debugPrint('CompletionProvider.loadForDate failed: $e\n$stackTrace');
      _errorMessage = 'Tamamlama kayıtları yüklenemedi.';
    } finally {
      _setLoading(false);
    }
  }

  /// Alışkanlığı veya görevi tamamlandı olarak işaretler.
  ///
  /// [requireToday]: true ise [date] takvim olarak bugün olmalı (alışkanlık kartı).
  Future<void> markDone(
    String recordId,
    String date, {
    int progress = 100,
    bool requireToday = false,
  }) async {
    await _mark(
      recordId,
      date,
      CompletionStatus.done,
      progress: progress,
      requireToday: requireToday,
    );
  }

  /// Alışkanlığı es geçer.
  Future<void> markSkipped(
    String recordId,
    String date, {
    bool requireToday = false,
  }) async {
    await _mark(
      recordId,
      date,
      CompletionStatus.skipped,
      progress: 0,
      requireToday: requireToday,
    );
  }

  /// Alışkanlığı kısmi ilerletir. Hedef değere ulaşıp ulaşmadığı
  /// UI katmanından hesaplanıp `markDone` çağrılabilir veya doğrudan burada kullanılabilir.
  Future<void> markPartial(
    String recordId,
    String date,
    int progress, {
    bool requireToday = false,
  }) async {
    await _mark(
      recordId,
      date,
      CompletionStatus.partial,
      progress: progress,
      requireToday: requireToday,
    );
  }

  /// İlerleme değerini günceller (targetProgress kontrolü).
  Future<void> updateProgress(
    String recordId,
    String date,
    int progress,
    int targetProgress, {
    bool requireToday = false,
  }) async {
    if (progress >= targetProgress) {
      await markDone(recordId, date, progress: progress, requireToday: requireToday);
    } else {
      await markPartial(recordId, date, progress, requireToday: requireToday);
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
      await onMutated?.call(recordId);
    } catch (e, stackTrace) {
      debugPrint('CompletionProvider.undoCompletion failed: $e\n$stackTrace');
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
    bool requireToday = false,
  }) async {
    if (requireToday && date != _calendarTodayYmd()) {
      return;
    }

    _setLoading(true);
    try {
      final id = CompletionRowId.forRecordAndDate(recordId, date);
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
      await onMutated?.call(recordId);
    } catch (e, stackTrace) {
      debugPrint('CompletionProvider._mark failed: $e\n$stackTrace');
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

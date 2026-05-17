import 'package:flutter/foundation.dart';

import '../../core/utils/calendar_date.dart';
import '../../data/models/completion_model.dart';
import '../../data/repositories/completion_repository.dart';
import '../../data/utils/completion_row_id.dart';

class CompletionProvider extends ChangeNotifier {
  CompletionProvider(this._repository, {this.onMutated});

  final CompletionRepository _repository;
  final Future<void> Function(String recordId)? onMutated;

  static String _todayYmd() => CalendarDate.todayYmd();

  final Map<String, CompletionModel> _completions = {};
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;

  CompletionModel? completionFor(String recordId) => _completions[recordId];

  bool isDone(String recordId) => _completions[recordId]?.status.isDone ?? false;

  Future<void> loadForDate(String date) async {
    _setLoading(true);
    try {
      final list = await _repository.getByDate(date);
      _completions
        ..clear()
        ..addEntries(list.map((c) => MapEntry(c.recordId, c)));
      _errorMessage = null;
    } catch (e, st) {
      debugPrint('CompletionProvider.loadForDate failed: $e\n$st');
      _errorMessage = 'Tamamlama kayıtları yüklenemedi.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> markDone(
    String recordId,
    String date, {
    int progress = 100,
    bool requireToday = false,
  }) async {
    await _mark(recordId, date, CompletionStatus.done,
        progress: progress, requireToday: requireToday);
  }

  Future<void> markSkipped(
    String recordId,
    String date, {
    bool requireToday = false,
  }) async {
    await _mark(recordId, date, CompletionStatus.skipped,
        progress: 0, requireToday: requireToday);
  }

  Future<void> markPartial(
    String recordId,
    String date,
    int progress, {
    bool requireToday = false,
  }) async {
    await _mark(recordId, date, CompletionStatus.partial,
        progress: progress, requireToday: requireToday);
  }

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

  Future<void> undoCompletion(String recordId) async {
    final existing = _completions[recordId];
    if (existing == null) return;
    _setLoading(true);
    try {
      await _repository.delete(existing.id);
      _completions.remove(recordId);
      _errorMessage = null;
      await onMutated?.call(recordId);
    } catch (e, st) {
      debugPrint('CompletionProvider.undoCompletion failed: $e\n$st');
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
    if (requireToday && date != _todayYmd()) return;

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
      _completions[recordId] = CompletionModel(
        id: id,
        recordId: recordId,
        date: date,
        status: status,
        progress: progress,
      );
      _errorMessage = null;
      await onMutated?.call(recordId);
    } catch (e, st) {
      debugPrint('CompletionProvider._mark failed: $e\n$st');
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

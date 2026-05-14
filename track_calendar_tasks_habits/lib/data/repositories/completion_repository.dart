import '../models/completion_model.dart';

/// Günlük tamamlama işlemleri için sözleşme.
abstract class CompletionRepository {
  Future<List<CompletionModel>> getByDate(String date);
  Future<List<CompletionModel>> getByRecordId(String recordId);
  Future<CompletionModel?> getForRecordAndDate(String recordId, String date);
  Future<void> markDone(String id, String recordId, String date, {int progress = 100});
  Future<void> markSkipped(String id, String recordId, String date);
  Future<void> markPartial(String id, String recordId, String date, int progress);
  Future<void> delete(String id);
}

/// In-memory mock implementasyon.
class MockCompletionRepository implements CompletionRepository {
  final List<CompletionModel> _completions = [];

  @override
  Future<List<CompletionModel>> getByDate(String date) async =>
      _completions.where((c) => c.date == date).toList();

  @override
  Future<List<CompletionModel>> getByRecordId(String recordId) async =>
      _completions.where((c) => c.recordId == recordId).toList();

  @override
  Future<CompletionModel?> getForRecordAndDate(
    String recordId,
    String date,
  ) async {
    try {
      return _completions.firstWhere(
        (c) => c.recordId == recordId && c.date == date,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> markDone(
    String id,
    String recordId,
    String date, {
    int progress = 100,
  }) async =>
      _upsert(id, recordId, date, CompletionStatus.done, progress: progress);

  @override
  Future<void> markSkipped(String id, String recordId, String date) async =>
      _upsert(id, recordId, date, CompletionStatus.skipped);

  @override
  Future<void> markPartial(
    String id,
    String recordId,
    String date,
    int progress,
  ) async =>
      _upsert(id, recordId, date, CompletionStatus.partial, progress: progress);

  @override
  Future<void> delete(String id) async {
    _completions.removeWhere((c) => c.id == id);
  }

  void _upsert(
    String id,
    String recordId,
    String date,
    CompletionStatus status, {
    int progress = 0,
  }) {
    _completions.removeWhere((c) => c.id == id);
    _completions.add(CompletionModel(
      id: id,
      recordId: recordId,
      date: date,
      status: status,
      progress: progress,
      updatedAtMs: DateTime.now().millisecondsSinceEpoch,
    ));
  }
}

// Sprint 3: Test stub — CompletionRepository manuel implementasyonu
//
// Neden stub? Provider testlerinde sqflite DB açılmak zorunda değil.
// Manuel stub ile bağımlılık izole edilir; testler hızlı ve bağımsız çalışır.

import 'package:my_new_habit/data/models/completion_model.dart';
import 'package:my_new_habit/data/repositories/completion_repository.dart';

/// CompletionRepository'nin test için basit in-memory implementasyonu.
class StubCompletionRepository implements CompletionRepository {
  /// Tarih → liste şeklinde in-memory store.
  final Map<String, List<CompletionModel>> _store = {};
  bool shouldThrow = false;

  @override
  Future<List<CompletionModel>> getByDate(String date) async {
    if (shouldThrow) throw Exception('stub error');
    return List.from(_store[date] ?? []);
  }

  @override
  Future<List<CompletionModel>> getByRecordId(String recordId) async {
    return _store.values
        .expand((list) => list)
        .where((c) => c.recordId == recordId)
        .toList();
  }

  @override
  Future<CompletionModel?> getForRecordAndDate(
    String recordId,
    String date,
  ) async {
    final list = _store[date] ?? [];
    try {
      return list.firstWhere((c) => c.recordId == recordId);
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
  }) async {
    _upsert(
      CompletionModel(
        id: id,
        recordId: recordId,
        date: date,
        status: CompletionStatus.done,
        progress: progress,
      ),
    );
  }

  @override
  Future<void> markPartial(
    String id,
    String recordId,
    String date,
    int progress,
  ) async {
    _upsert(
      CompletionModel(
        id: id,
        recordId: recordId,
        date: date,
        status: CompletionStatus.partial,
        progress: progress,
      ),
    );
  }

  @override
  Future<void> markSkipped(String id, String recordId, String date) async {
    _upsert(
      CompletionModel(
        id: id,
        recordId: recordId,
        date: date,
        status: CompletionStatus.skipped,
      ),
    );
  }

  @override
  Future<void> delete(String id) async {
    for (final list in _store.values) {
      list.removeWhere((c) => c.id == id);
    }
  }

  void _upsert(CompletionModel model) {
    final list = _store.putIfAbsent(model.date, () => []);
    list.removeWhere((c) => c.recordId == model.recordId);
    list.add(model);
  }
}

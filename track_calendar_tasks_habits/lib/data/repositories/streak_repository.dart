import 'package:track_calendar_tasks_habits/data/models/streak_model.dart';

/// Seri verisi için sözleşme.
abstract class StreakRepository {
  Future<StreakModel?> getByRecordId(String recordId);
  Future<Map<String, StreakModel>> getByRecordIds(List<String> recordIds);
  Future<void> upsert(StreakModel model);
  Future<void> clearSeriesClosure(String recordId);
  Future<void> setRecoveryApplied(String recordId);
  Future<StreakModel> getOrCreate(String recordId);
}

/// In-memory mock implementasyon — önceden tanımlanmış streak verileriyle başlar.
class MockStreakRepository implements StreakRepository {
  final Map<String, StreakModel> _rows = _initialStreaks();

  @override
  Future<StreakModel?> getByRecordId(String recordId) async =>
      _rows[recordId];

  @override
  Future<Map<String, StreakModel>> getByRecordIds(
    List<String> recordIds,
  ) async =>
      {for (final id in recordIds) if (_rows[id] != null) id: _rows[id]!};

  @override
  Future<void> upsert(StreakModel model) async {
    _rows[model.recordId] = model;
  }

  @override
  Future<void> clearSeriesClosure(String recordId) async {
    final existing = _rows[recordId];
    if (existing == null) return;
    _rows[recordId] = existing.copyWith(seriesClosedAfter: null);
  }

  @override
  Future<void> setRecoveryApplied(String recordId) async {
    final existing = _rows[recordId];
    if (existing == null) return;
    _rows[recordId] = existing.copyWith(recoveryApplied: 1);
  }

  @override
  Future<StreakModel> getOrCreate(String recordId) async {
    return _rows.putIfAbsent(
      recordId,
      () => StreakModel(recordId: recordId),
    );
  }
}

// Başlangıç mock streak verileri
Map<String, StreakModel> _initialStreaks() {
  return {
    'habit-1': const StreakModel(
      recordId: 'habit-1',
      currentStreak: 7,
      longestStreak: 14,
    ),
    'habit-2': const StreakModel(
      recordId: 'habit-2',
      currentStreak: 3,
      longestStreak: 10,
    ),
    'habit-3': const StreakModel(
      recordId: 'habit-3',
      currentStreak: 12,
      longestStreak: 12,
    ),
    'habit-4': const StreakModel(
      recordId: 'habit-4',
      currentStreak: 2,
      longestStreak: 6,
    ),
  };
}

// Sprint 6: StreakRepository test stubu

import 'package:my_new_habit/data/models/streak_model.dart';
import 'package:my_new_habit/data/repositories/streak_repository.dart';

class StubStreakRepository implements StreakRepository {
  final Map<String, StreakModel> _rows = {};

  @override
  Future<void> clearSeriesClosure(String recordId) async {
    final x = _rows[recordId];
    if (x == null) return;
    _rows[recordId] = StreakModel(
      recordId: recordId,
      currentStreak: x.currentStreak,
      longestStreak: x.longestStreak,
      lastDoneDate: x.lastDoneDate,
      skipUsedThisWeek: x.skipUsedThisWeek,
      skipConsumedWeekKey: x.skipConsumedWeekKey,
      openMissDate: x.openMissDate,
      recoveryScheduledDate: x.recoveryScheduledDate,
      recoveryApplied: x.recoveryApplied,
      streakFrozenBeforeMiss: x.streakFrozenBeforeMiss,
      seriesClosedAfter: null,
    );
  }

  @override
  Future<StreakModel?> getByRecordId(String recordId) async => _rows[recordId];

  @override
  Future<Map<String, StreakModel>> getByRecordIds(List<String> recordIds) async {
    final out = <String, StreakModel>{};
    for (final id in recordIds) {
      final x = _rows[id];
      if (x != null) out[id] = x;
    }
    return out;
  }

  @override
  Future<List<StreakModel>> getAll() async {
    return _rows.values.toList();
  }

  @override
  Future<void> applyRemoteStreak(StreakModel model) async {
    _rows[model.recordId] = model;
  }

  @override
  Future<StreakModel> getOrCreate(String recordId) async {
    return _rows.putIfAbsent(recordId, () => StreakModel(recordId: recordId));
  }

  @override
  Future<void> setRecoveryApplied(String recordId) async {
    final x = _rows[recordId] ?? StreakModel(recordId: recordId);
    _rows[recordId] = StreakModel(
      recordId: recordId,
      currentStreak: x.currentStreak,
      longestStreak: x.longestStreak,
      lastDoneDate: x.lastDoneDate,
      skipUsedThisWeek: x.skipUsedThisWeek,
      skipConsumedWeekKey: x.skipConsumedWeekKey,
      openMissDate: x.openMissDate,
      recoveryScheduledDate: x.recoveryScheduledDate,
      recoveryApplied: 1,
      streakFrozenBeforeMiss: x.streakFrozenBeforeMiss,
      seriesClosedAfter: x.seriesClosedAfter,
    );
  }

  @override
  Future<void> upsert(StreakModel model) async {
    _rows[model.recordId] = model;
  }
}

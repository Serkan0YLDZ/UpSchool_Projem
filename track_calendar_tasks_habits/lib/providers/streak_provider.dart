import 'package:flutter/foundation.dart';

import '../core/utils/calendar_date.dart';
import '../data/models/completion_model.dart';
import '../data/models/record_model.dart';
import '../data/models/streak_model.dart';
import '../data/repositories/completion_repository.dart';
import '../data/repositories/record_repository.dart';
import '../data/repositories/streak_repository.dart';
import '../data/services/streak_service.dart';

class StreakProvider extends ChangeNotifier {
  StreakProvider({
    required CompletionRepository completionRepository,
    required StreakRepository streakRepository,
    required RecordRepository recordRepository,
  })  : _completionRepository = completionRepository,
        _streakRepository = streakRepository,
        _recordRepository = recordRepository;

  final CompletionRepository _completionRepository;
  final StreakRepository _streakRepository;
  final RecordRepository _recordRepository;

  final Map<String, List<CompletionModel>> _completionsByRecord = {};
  final Map<String, StreakModel> _rowsByRecord = {};

  StreakModel? rowFor(String recordId) => _rowsByRecord[recordId];

  bool isHabitHiddenOnSelectedDate(String habitId, String selectedYmd) {
    return StreakService.isHiddenOnDate(rowFor(habitId), selectedYmd);
  }

  StreakViewState viewFor(RecordModel habit, String selectedYmd, String todayYmd) {
    final row = _rowsByRecord[habit.id] ?? StreakModel(recordId: habit.id);
    final comps = _completionsByRecord[habit.id] ?? const [];
    return StreakService.computeView(
      habit: habit,
      completions: comps,
      row: row,
      selectedYmd: selectedYmd,
      todayYmd: todayYmd,
    );
  }

  Future<void> loadForHabits(List<RecordModel> habits, String todayYmd) async {
    for (final h in habits) {
      if (!h.type.isHabit) continue;
      await _reconcileInternal(h, todayYmd);
    }
    notifyListeners();
  }

  Future<void> reconcileForRecord(String recordId) async {
    final habit = await _recordRepository.getById(recordId);
    if (habit == null || !habit.type.isHabit) return;
    final todayYmd = CalendarDate.todayYmd();
    await _reconcileInternal(habit, todayYmd);
    notifyListeners();
  }

  Future<void> applyRecovery(String recordId) async {
    await _streakRepository.setRecoveryApplied(recordId);
    await reconcileForRecord(recordId);
  }

  Future<void> restartSeries(String recordId) async {
    await _streakRepository.clearSeriesClosure(recordId);
    await reconcileForRecord(recordId);
  }

  Future<void> reconcileAllLoadedHabits(List<RecordModel> habits) async {
    final todayYmd = CalendarDate.todayYmd();
    await loadForHabits(habits, todayYmd);
  }

  Future<void> _reconcileInternal(RecordModel habit, String todayYmd) async {
    final comps = await _completionRepository.getByRecordId(habit.id);
    _completionsByRecord[habit.id] = comps;
    var row = await _streakRepository.getByRecordId(habit.id);
    row ??= StreakModel(recordId: habit.id);
    final next = StreakService.reconcile(
      habit: habit,
      completions: comps,
      todayYmd: todayYmd,
      row: row,
    );
    await _streakRepository.upsert(next);
    _rowsByRecord[habit.id] = next;
  }
}

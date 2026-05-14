class StreakModel {
  final String recordId;
  final int currentStreak;
  final int longestStreak;
  final String? lastDoneDate;
  final int skipUsedThisWeek;
  final String? skipConsumedWeekKey;
  final String? openMissDate;
  final String? recoveryScheduledDate;
  final int recoveryApplied;
  final int? streakFrozenBeforeMiss;
  final String? seriesClosedAfter;
  final int updatedAtMs;

  const StreakModel({
    required this.recordId,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastDoneDate,
    this.skipUsedThisWeek = 0,
    this.skipConsumedWeekKey,
    this.openMissDate,
    this.recoveryScheduledDate,
    this.recoveryApplied = 0,
    this.streakFrozenBeforeMiss,
    this.seriesClosedAfter,
    this.updatedAtMs = 0,
  });

  StreakModel copyWith({
    int? currentStreak,
    int? longestStreak,
    String? lastDoneDate,
    int? skipUsedThisWeek,
    String? skipConsumedWeekKey,
    String? openMissDate,
    String? recoveryScheduledDate,
    int? recoveryApplied,
    int? streakFrozenBeforeMiss,
    String? seriesClosedAfter,
    int? updatedAtMs,
  }) {
    return StreakModel(
      recordId: recordId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastDoneDate: lastDoneDate ?? this.lastDoneDate,
      skipUsedThisWeek: skipUsedThisWeek ?? this.skipUsedThisWeek,
      skipConsumedWeekKey: skipConsumedWeekKey ?? this.skipConsumedWeekKey,
      openMissDate: openMissDate ?? this.openMissDate,
      recoveryScheduledDate:
          recoveryScheduledDate ?? this.recoveryScheduledDate,
      recoveryApplied: recoveryApplied ?? this.recoveryApplied,
      streakFrozenBeforeMiss:
          streakFrozenBeforeMiss ?? this.streakFrozenBeforeMiss,
      seriesClosedAfter: seriesClosedAfter ?? this.seriesClosedAfter,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    );
  }
}

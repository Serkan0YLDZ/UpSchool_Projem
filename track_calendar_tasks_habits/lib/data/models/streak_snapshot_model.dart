/// Seri durumu.
enum SeriesState {
  active,   // Seri devam ediyor
  broken,   // Kaçırma var, recovery bekleniyor
  closed;   // Seri kapandı, ileri günlerde kart gizlenir

  String get value => name;

  static SeriesState fromValue(String value) => SeriesState.values.firstWhere(
        (e) => e.name == value,
        orElse: () => SeriesState.active,
      );
}

/// Alışkanlık serisi anlık görüntüsü (snapshot / cache).
///
/// Her alışkanlık için tek satır (habit_id PRIMARY KEY).
/// [openMissDate] + [recoveryScheduledDate] + [streakFrozenBeforeMiss]:
///   Kaçırılan günün recovery süreci için üçlü.
/// [skipUsedThisWeek] + [skipConsumedWeekKey]:
///   ISO haftalık es geç hakkı takibi.
class StreakSnapshotModel {
  const StreakSnapshotModel({
    required this.habitId,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.seriesState = SeriesState.active,
    this.seriesClosedAfter,
    this.lastDoneDate,
    this.skipUsedThisWeek = 0,
    this.skipConsumedWeekKey,
    this.openMissDate,
    this.recoveryScheduledDate,
    this.recoveryApplied = 0,
    this.streakFrozenBeforeMiss,
    required this.updatedAt,
  });

  final String habitId;
  final int currentStreak;
  final int longestStreak;
  final SeriesState seriesState;
  final String? seriesClosedAfter;       // date — bu tarihten sonra kart gizlenir
  final String? lastDoneDate;            // date — son 'met' günü
  final int skipUsedThisWeek;            // 0 veya 1
  final String? skipConsumedWeekKey;     // ISO haftanın Pazartesi tarihi
  final String? openMissDate;            // Kaçırılan günün tarihi
  final String? recoveryScheduledDate;   // Recovery için beklenen gün
  final int recoveryApplied;             // 0 veya 1
  final int? streakFrozenBeforeMiss;     // Kaçırma anındaki streak değeri
  final String updatedAt;

  factory StreakSnapshotModel.fromMap(Map<String, dynamic> map) {
    return StreakSnapshotModel(
      habitId: map['habit_id'] as String,
      currentStreak: map['current_streak'] as int? ?? 0,
      longestStreak: map['longest_streak'] as int? ?? 0,
      seriesState: SeriesState.fromValue(
          map['series_state'] as String? ?? 'active'),
      seriesClosedAfter: map['series_closed_after'] as String?,
      lastDoneDate: map['last_done_date'] as String?,
      skipUsedThisWeek: map['skip_used_this_week'] as int? ?? 0,
      skipConsumedWeekKey: map['skip_consumed_week_key'] as String?,
      openMissDate: map['open_miss_date'] as String?,
      recoveryScheduledDate: map['recovery_scheduled_date'] as String?,
      recoveryApplied: map['recovery_applied'] as int? ?? 0,
      streakFrozenBeforeMiss: map['streak_frozen_before_miss'] as int?,
      updatedAt: map['updated_at'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
        'habit_id': habitId,
        'current_streak': currentStreak,
        'longest_streak': longestStreak,
        'series_state': seriesState.value,
        'series_closed_after': seriesClosedAfter,
        'last_done_date': lastDoneDate,
        'skip_used_this_week': skipUsedThisWeek,
        'skip_consumed_week_key': skipConsumedWeekKey,
        'open_miss_date': openMissDate,
        'recovery_scheduled_date': recoveryScheduledDate,
        'recovery_applied': recoveryApplied,
        'streak_frozen_before_miss': streakFrozenBeforeMiss,
        'updated_at': updatedAt,
      };

  StreakSnapshotModel copyWith({
    int? currentStreak,
    int? longestStreak,
    SeriesState? seriesState,
    String? seriesClosedAfter,
    bool clearSeriesClosedAfter = false,
    String? lastDoneDate,
    bool clearLastDoneDate = false,
    int? skipUsedThisWeek,
    String? skipConsumedWeekKey,
    bool clearSkipConsumedWeekKey = false,
    String? openMissDate,
    bool clearOpenMissDate = false,
    String? recoveryScheduledDate,
    bool clearRecoveryScheduledDate = false,
    int? recoveryApplied,
    int? streakFrozenBeforeMiss,
    bool clearStreakFrozenBeforeMiss = false,
    String? updatedAt,
  }) {
    return StreakSnapshotModel(
      habitId: habitId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      seriesState: seriesState ?? this.seriesState,
      seriesClosedAfter: clearSeriesClosedAfter
          ? null
          : (seriesClosedAfter ?? this.seriesClosedAfter),
      lastDoneDate:
          clearLastDoneDate ? null : (lastDoneDate ?? this.lastDoneDate),
      skipUsedThisWeek: skipUsedThisWeek ?? this.skipUsedThisWeek,
      skipConsumedWeekKey: clearSkipConsumedWeekKey
          ? null
          : (skipConsumedWeekKey ?? this.skipConsumedWeekKey),
      openMissDate:
          clearOpenMissDate ? null : (openMissDate ?? this.openMissDate),
      recoveryScheduledDate: clearRecoveryScheduledDate
          ? null
          : (recoveryScheduledDate ?? this.recoveryScheduledDate),
      recoveryApplied: recoveryApplied ?? this.recoveryApplied,
      streakFrozenBeforeMiss: clearStreakFrozenBeforeMiss
          ? null
          : (streakFrozenBeforeMiss ?? this.streakFrozenBeforeMiss),
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

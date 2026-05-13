// Sprint 6: Veri Katmanı — StreakModel (seri + Es Geç + kurtarma + sert kapanış)

/// Bir kaydın seri (streak) bilgisini tutar.
///
/// `streaks` tablosuna karşılık gelir.
class StreakModel {
  final String recordId;
  final int currentStreak;
  final int longestStreak;

  /// Son tamamlama tarihi ('yyyy-MM-dd')
  final String? lastDoneDate;

  /// Bu ISO haftasında (Pazartesi anahtarı) Es Geç kullanıldı mı (0/1)
  final int skipUsedThisWeek;

  /// Es Geç tüketildiğinde o haftanın Pazartesi `yyyy-MM-dd` anahtarı
  final String? skipConsumedWeekKey;

  /// Kaçırılan planlı gün (hedef yok, skip yok), kurtarma bekleniyor
  final String? openMissDate;

  /// Kurtarma yapılabilecek sonraki planlı gün
  final String? recoveryScheduledDate;

  /// Kullanıcı "Seriyi geri getir"e bastı mı (0/1)
  final int recoveryApplied;

  /// Kaçırma anındaki seri (kurtarma günü gösterimi için)
  final int? streakFrozenBeforeMiss;

  /// Bu tarihten **sonraki** seçili günlerde alışkanlık listelenmez (`yyyy-MM-dd`)
  final String? seriesClosedAfter;

  /// LWW senkron için yerel değişiklik zaman damgası (ms).
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

  factory StreakModel.fromMap(Map<String, dynamic> map) {
    return StreakModel(
      recordId: map['record_id'] as String,
      currentStreak: (map['current_streak'] as int?) ?? 0,
      longestStreak: (map['longest_streak'] as int?) ?? 0,
      lastDoneDate: map['last_done_date'] as String?,
      skipUsedThisWeek: (map['skip_used_this_week'] as int?) ?? 0,
      skipConsumedWeekKey: map['skip_consumed_week_key'] as String?,
      openMissDate: map['open_miss_date'] as String?,
      recoveryScheduledDate: map['recovery_scheduled_date'] as String?,
      recoveryApplied: (map['recovery_applied'] as int?) ?? 0,
      streakFrozenBeforeMiss: map['streak_frozen_before_miss'] as int?,
      seriesClosedAfter: map['series_closed_after'] as String?,
      updatedAtMs: map['updated_at_ms'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'record_id': recordId,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_done_date': lastDoneDate,
      'skip_used_this_week': skipUsedThisWeek,
      'skip_consumed_week_key': skipConsumedWeekKey,
      'open_miss_date': openMissDate,
      'recovery_scheduled_date': recoveryScheduledDate,
      'recovery_applied': recoveryApplied,
      'streak_frozen_before_miss': streakFrozenBeforeMiss,
      'series_closed_after': seriesClosedAfter,
      'updated_at_ms': updatedAtMs,
    };
  }

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
      recoveryScheduledDate: recoveryScheduledDate ?? this.recoveryScheduledDate,
      recoveryApplied: recoveryApplied ?? this.recoveryApplied,
      streakFrozenBeforeMiss: streakFrozenBeforeMiss ?? this.streakFrozenBeforeMiss,
      seriesClosedAfter: seriesClosedAfter ?? this.seriesClosedAfter,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    );
  }
}

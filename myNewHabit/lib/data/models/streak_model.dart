// Sprint 2: Veri Katmanı — StreakModel

/// Bir kaydın seri (streak) bilgisini tutar.
///
/// `streaks` tablosuna karşılık gelir.
class StreakModel {
  final String recordId;
  final int currentStreak;
  final int longestStreak;

  /// Son tamamlama tarihi ('yyyy-MM-dd')
  final String? lastDoneDate;

  // Skip hakkı bu hafta kullanıldı mı?
  // ISO haftası bazında — her Pazartesi sıfırlanır.
  final int skipUsedThisWeek;

  const StreakModel({
    required this.recordId,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastDoneDate,
    this.skipUsedThisWeek = 0,
  });

  factory StreakModel.fromMap(Map<String, dynamic> map) {
    return StreakModel(
      recordId: map['record_id'] as String,
      currentStreak: (map['current_streak'] as int?) ?? 0,
      longestStreak: (map['longest_streak'] as int?) ?? 0,
      lastDoneDate: map['last_done_date'] as String?,
      skipUsedThisWeek: (map['skip_used_this_week'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'record_id': recordId,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_done_date': lastDoneDate,
      'skip_used_this_week': skipUsedThisWeek,
    };
  }

  StreakModel copyWith({
    int? currentStreak,
    int? longestStreak,
    String? lastDoneDate,
    int? skipUsedThisWeek,
  }) {
    return StreakModel(
      recordId: recordId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastDoneDate: lastDoneDate ?? this.lastDoneDate,
      skipUsedThisWeek: skipUsedThisWeek ?? this.skipUsedThisWeek,
    );
  }
}

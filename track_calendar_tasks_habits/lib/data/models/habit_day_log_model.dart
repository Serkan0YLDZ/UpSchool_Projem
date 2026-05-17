/// Alışkanlık günlük log durumu (PRD §FR-04, §FR-05).
enum DayLogStatus {
  pending,       // Henüz işlem yapılmadı
  met,           // Tamamlandı (streak sayılır)
  missed,        // Kaçırıldı
  skipped,       // Es geçildi (free_weekly)
  seriesLapsed;  // Seri bitti

  String get value {
    if (this == DayLogStatus.seriesLapsed) return 'series_lapsed';
    return name;
  }

  static DayLogStatus fromValue(String value) {
    if (value == 'series_lapsed') return DayLogStatus.seriesLapsed;
    return DayLogStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DayLogStatus.pending,
    );
  }
}

/// Bir alışkanlığın belirli bir gündeki log kaydı.
///
/// [habitId] + [calendarDate] çifti UNIQUE'tir (tablo kısıtı).
/// [skipSource]: v0.1'de 'free_weekly'; v0.2'de 'ad' da gelebilir.
class HabitDayLogModel {
  const HabitDayLogModel({
    required this.id,
    required this.habitId,
    required this.calendarDate,
    this.status = DayLogStatus.pending,
    this.skipSource,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.localRevision = 0,
  });

  final String id;
  final String habitId;
  final String calendarDate;  // 'YYYY-MM-DD'
  final DayLogStatus status;
  final String? skipSource;   // 'free_weekly' | 'ad' (v0.2)
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final int localRevision;

  bool get isActive => deletedAt == null;
  bool get isMet => status == DayLogStatus.met;
  bool get isSkipped => status == DayLogStatus.skipped;

  factory HabitDayLogModel.fromMap(Map<String, dynamic> map) {
    return HabitDayLogModel(
      id: map['id'] as String,
      habitId: map['habit_id'] as String,
      calendarDate: map['calendar_date'] as String,
      status: DayLogStatus.fromValue(map['status'] as String? ?? 'pending'),
      skipSource: map['skip_source'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
      deletedAt: map['deleted_at'] as String?,
      localRevision: map['local_revision'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'habit_id': habitId,
        'calendar_date': calendarDate,
        'status': status.value,
        'skip_source': skipSource,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'deleted_at': deletedAt,
        'local_revision': localRevision,
      };

  HabitDayLogModel copyWith({
    String? id,
    String? habitId,
    String? calendarDate,
    DayLogStatus? status,
    String? skipSource,
    bool clearSkipSource = false,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
    bool clearDeletedAt = false,
    int? localRevision,
  }) {
    return HabitDayLogModel(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      calendarDate: calendarDate ?? this.calendarDate,
      status: status ?? this.status,
      skipSource: clearSkipSource ? null : (skipSource ?? this.skipSource),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      localRevision: localRevision ?? this.localRevision,
    );
  }
}

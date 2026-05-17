/// Tekrar türü: haftalık (belirli günler) veya interval (N günde bir).
enum ScheduleKind {
  weekly,
  interval;

  String get value => name;

  static ScheduleKind fromValue(String value) => ScheduleKind.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ScheduleKind.weekly,
      );
}

/// Alışkanlık veri modeli.
///
/// [weeklyDaysMask]: 7-bit integer, Pazartesi=bit0 … Pazar=bit6.
///   Örnek: Pzt+Çar+Cum = 0b0010101 = 21.
/// [anchorDate]: İlk planlı gün (ISO8601 date).
/// Açıklama alanı yoktur — alışkanlık formunda description girişi bulunmaz.
class HabitModel {
  const HabitModel({
    required this.id,
    required this.title,
    required this.scheduleKind,
    this.intervalDays,
    this.weeklyDaysMask,
    required this.anchorDate,
    this.targetProgress = 100,
    this.targetUnit,
    this.iconKey,
    this.iconColorArgb,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.localRevision = 0,
  });

  final String id;
  final String title;
  final ScheduleKind scheduleKind;
  final int? intervalDays;      // scheduleKind == interval iken zorunlu
  final int? weeklyDaysMask;    // scheduleKind == weekly iken zorunlu
  final String anchorDate;      // ISO8601 date
  final int targetProgress;     // 0–100
  final String? targetUnit;     // opsiyonel birim (ör. 'km', 'sayfa')
  final String? iconKey;
  final int? iconColorArgb;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final int localRevision;

  bool get isActive => deletedAt == null;

  factory HabitModel.fromMap(Map<String, dynamic> map) {
    return HabitModel(
      id: map['id'] as String,
      title: map['title'] as String,
      scheduleKind: ScheduleKind.fromValue(map['schedule_kind'] as String),
      intervalDays: map['interval_days'] as int?,
      weeklyDaysMask: map['weekly_days_mask'] as int?,
      anchorDate: map['anchor_date'] as String,
      targetProgress: map['target_progress'] as int? ?? 100,
      targetUnit: map['target_unit'] as String?,
      iconKey: map['icon_key'] as String?,
      iconColorArgb: map['icon_color_argb'] as int?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
      deletedAt: map['deleted_at'] as String?,
      localRevision: map['local_revision'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'schedule_kind': scheduleKind.value,
        'interval_days': intervalDays,
        'weekly_days_mask': weeklyDaysMask,
        'anchor_date': anchorDate,
        'target_progress': targetProgress,
        'target_unit': targetUnit,
        'icon_key': iconKey,
        'icon_color_argb': iconColorArgb,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'deleted_at': deletedAt,
        'local_revision': localRevision,
      };

  HabitModel copyWith({
    String? id,
    String? title,
    ScheduleKind? scheduleKind,
    int? intervalDays,
    int? weeklyDaysMask,
    String? anchorDate,
    int? targetProgress,
    String? targetUnit,
    bool clearTargetUnit = false,
    String? iconKey,
    bool clearIconKey = false,
    int? iconColorArgb,
    bool clearIconColorArgb = false,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
    bool clearDeletedAt = false,
    int? localRevision,
  }) {
    return HabitModel(
      id: id ?? this.id,
      title: title ?? this.title,
      scheduleKind: scheduleKind ?? this.scheduleKind,
      intervalDays: intervalDays ?? this.intervalDays,
      weeklyDaysMask: weeklyDaysMask ?? this.weeklyDaysMask,
      anchorDate: anchorDate ?? this.anchorDate,
      targetProgress: targetProgress ?? this.targetProgress,
      targetUnit: clearTargetUnit ? null : (targetUnit ?? this.targetUnit),
      iconKey: clearIconKey ? null : (iconKey ?? this.iconKey),
      iconColorArgb: clearIconColorArgb ? null : (iconColorArgb ?? this.iconColorArgb),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      localRevision: localRevision ?? this.localRevision,
    );
  }
}

/// Takvim etkinliği veri modeli.
///
/// [description] alanı UI'da da desteklenir (etkinlik formu).
/// [deletedAt] NULL ise kayıt aktif; dolu ise soft-deleted.
/// [localRevision] v0.2 senkron için monoton artan versiyon.
class CalendarEventModel {
  const CalendarEventModel({
    required this.id,
    required this.title,
    this.description,
    required this.startsAt,
    this.endsAt,
    this.isAllDay = false,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.localRevision = 0,
  });

  final String id;
  final String title;
  final String? description;
  final String startsAt;     // ISO8601 datetime
  final String? endsAt;      // ISO8601 datetime
  final bool isAllDay;
  final String createdAt;    // ISO8601
  final String updatedAt;    // ISO8601
  final String? deletedAt;   // NULL = aktif
  final int localRevision;

  bool get isActive => deletedAt == null;

  bool get isPast {
    final now = DateTime.now();
    if (endsAt != null && endsAt!.isNotEmpty) {
      try {
        return DateTime.parse(endsAt!).isBefore(now);
      } catch (_) {
        return false;
      }
    } else {
      try {
        return DateTime.parse(startsAt).isBefore(now);
      } catch (_) {
        return false;
      }
    }
  }

  factory CalendarEventModel.fromMap(Map<String, dynamic> map) {
    return CalendarEventModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      startsAt: map['starts_at'] as String,
      endsAt: map['ends_at'] as String?,
      isAllDay: (map['is_all_day'] as int) == 1,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
      deletedAt: map['deleted_at'] as String?,
      localRevision: map['local_revision'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'starts_at': startsAt,
        'ends_at': endsAt,
        'is_all_day': isAllDay ? 1 : 0,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'deleted_at': deletedAt,
        'local_revision': localRevision,
      };

  CalendarEventModel copyWith({
    String? id,
    String? title,
    String? description,
    bool clearDescription = false,
    String? startsAt,
    String? endsAt,
    bool clearEndsAt = false,
    bool? isAllDay,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
    bool clearDeletedAt = false,
    int? localRevision,
  }) {
    return CalendarEventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      startsAt: startsAt ?? this.startsAt,
      endsAt: clearEndsAt ? null : (endsAt ?? this.endsAt),
      isAllDay: isAllDay ?? this.isAllDay,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      localRevision: localRevision ?? this.localRevision,
    );
  }
}

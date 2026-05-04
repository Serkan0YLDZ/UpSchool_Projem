// Sprint 4: Veri Katmanı — RecordModel ve ilgili enum'lar

import 'dart:convert';

/// Uygulamadaki üç kayıt tipini temsil eder.
enum RecordType {
  event,
  habit,
  todo;

  /// DB'de saklanan string değerine dönüştürür.
  String get value => name; // 'event' | 'habit' | 'todo'

  static RecordType fromValue(String value) {
    return RecordType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RecordType.habit,
    );
  }
}

extension RecordTypeX on RecordType {
  bool get isEvent => this == RecordType.event;
  bool get isHabit => this == RecordType.habit;
  bool get isTodo => this == RecordType.todo;
}

/// Alışkanlık/Görev önem derecesi.
enum Priority {
  low,
  medium,
  high;

  String get value => name; // 'low' | 'medium' | 'high'

  static Priority fromValue(String value) {
    return Priority.values.firstWhere((e) => e.name == value);
  }
}

extension PriorityX on Priority {
  bool get isHigh => this == Priority.high;
  bool get isMedium => this == Priority.medium;
  bool get isLow => this == Priority.low;
}

/// Tek bir kayıt modeli (Takvime Ekle, Yeni Alışkanlık, Yapılacak).
///
/// Tüm tipler `records` tablosunda tutulur; `type` alanı ayrımı sağlar.
class RecordModel {
  final String id;
  final RecordType type;
  final String title;
  final String? description;
  final String? icon;
  final Priority? priority;

  /// Tekrar günleri. Örn: ['MON', 'TUE', 'FRI'] (sadece habit)
  final List<String> repeatDays;

  /// X günde bir tekrar ediyorsa (Örn: 3 günde bir). [repeatDays] ile birlikte kullanılamaz (sadece habit).
  final int? intervalDays;

  /// Tamamlanmış sayılan % eşiği (0-100) (sadece habit)
  final int targetProgress;

  /// 'yyyy-MM-dd' formatında zamanlanmış tarih (sadece event)
  final String? scheduledDate;

  /// 'HH:mm' formatında zamanlanmış saat (sadece event)
  final String? scheduledTime;

  /// 'yyyy-MM-dd' formatında bitiş tarihi (sadece event)
  final String? endDate;

  /// 'HH:mm' formatında bitiş saati (sadece event)
  final String? endTime;

  /// Opsiyonel bitiş tarihi (sadece todo)
  final DateTime? dueDate;

  final DateTime createdAt;
  final bool isActive;

  const RecordModel({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.icon,
    this.priority,
    this.repeatDays = const [],
    this.intervalDays,
    this.targetProgress = 100,
    this.scheduledDate,
    this.scheduledTime,
    this.endDate,
    this.endTime,
    this.dueDate,
    required this.createdAt,
    this.isActive = true,
  });

  /// sqflite Map'inden model oluşturur.
  factory RecordModel.fromMap(Map<String, dynamic> map) {
    return RecordModel(
      id: map['id'] as String,
      type: RecordType.fromValue(map['type'] as String),
      title: map['title'] as String,
      description: map['description'] as String?,
      icon: map['icon'] as String?,
      priority: map['priority'] != null
          ? Priority.fromValue(map['priority'] as String)
          : null,
      repeatDays: map['repeat_days'] != null
          ? List<String>.from(jsonDecode(map['repeat_days'] as String))
          : [],
      intervalDays: map['interval_days'] as int?,
      targetProgress: map['target_progress'] as int? ?? 100,
      scheduledDate: map['scheduled_date'] as String?,
      scheduledTime: map['scheduled_time'] as String?,
      endDate: map['end_date'] as String?,
      endTime: map['end_time'] as String?,
      dueDate: map['due_date'] != null
          ? DateTime.tryParse(map['due_date'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      // sqflite BOOLEAN'ı INTEGER olarak saklar (1/0)
      isActive: (map['is_active'] as int) == 1,
    );
  }

  /// sqflite'a yazılacak Map'e dönüştürür.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.value,
      'title': title,
      'description': description,
      'icon': icon,
      'priority': priority?.value,
      'repeat_days': repeatDays.isNotEmpty ? jsonEncode(repeatDays) : null,
      'interval_days': intervalDays,
      'target_progress': targetProgress,
      'scheduled_date': scheduledDate,
      'scheduled_time': scheduledTime,
      'end_date': endDate,
      'end_time': endTime,
      'due_date': dueDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  RecordModel copyWith({
    String? id,
    RecordType? type,
    String? title,
    String? description,
    String? icon,
    Priority? priority,
    List<String>? repeatDays,
    int? intervalDays,
    int? targetProgress,
    String? scheduledDate,
    String? scheduledTime,
    String? endDate,
    String? endTime,
    DateTime? dueDate,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return RecordModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      priority: priority ?? this.priority,
      repeatDays: repeatDays ?? this.repeatDays,
      intervalDays: intervalDays ?? this.intervalDays,
      targetProgress: targetProgress ?? this.targetProgress,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      endDate: endDate ?? this.endDate,
      endTime: endTime ?? this.endTime,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

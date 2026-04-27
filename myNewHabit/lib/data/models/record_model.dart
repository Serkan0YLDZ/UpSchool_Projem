// Sprint 2: Veri Katmanı — RecordModel ve ilgili enum'lar

import 'dart:convert';

/// Uygulamadaki üç kayıt tipini temsil eder.
enum RecordType {
  habit,
  task,
  quit;

  /// DB'de saklanan string değerine dönüştürür.
  String get value => name; // 'habit' | 'task' | 'quit'

  static RecordType fromValue(String value) {
    return RecordType.values.firstWhere((e) => e.name == value);
  }
}

extension RecordTypeX on RecordType {
  bool get isHabit => this == RecordType.habit;
  bool get isTask => this == RecordType.task;
  bool get isQuit => this == RecordType.quit;
}

/// Alışkanlık önem derecesi.
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

/// Tek bir kayıt (alışkanlık, görev ya da bırakılacak alışkanlık) modeli.
///
/// Tüm tipler `records` tablosunda tutulur; `type` alanı ayrımı sağlar.
class RecordModel {
  final String id;
  final RecordType type;
  final String title;
  final String? icon;
  final Priority? priority;

  /// Tekrar günleri. Örn: ['MON', 'TUE', 'FRI']
  final List<String> repeatDays;

  /// X günde bir tekrar ediyorsa (Örn: 3 günde bir). [repeatDays] ile birlikte kullanılamaz.
  final int? intervalDays;

  /// 'HH:mm' formatında zamanlanmış saat (görevler için)
  final String? scheduledTime;

  /// Opsiyonel bitiş tarihi (görevler için)
  final DateTime? endDate;

  final DateTime createdAt;
  final bool isActive;

  const RecordModel({
    required this.id,
    required this.type,
    required this.title,
    this.icon,
    this.priority,
    this.repeatDays = const [],
    this.intervalDays,
    this.scheduledTime,
    this.endDate,
    required this.createdAt,
    this.isActive = true,
  });

  /// sqflite Map'inden model oluşturur.
  factory RecordModel.fromMap(Map<String, dynamic> map) {
    return RecordModel(
      id: map['id'] as String,
      type: RecordType.fromValue(map['type'] as String),
      title: map['title'] as String,
      icon: map['icon'] as String?,
      priority: map['priority'] != null
          ? Priority.fromValue(map['priority'] as String)
          : null,
      repeatDays: map['repeat_days'] != null
          ? List<String>.from(jsonDecode(map['repeat_days'] as String))
          : [],
      intervalDays: map['interval_days'] as int?,
      scheduledTime: map['scheduled_time'] as String?,
      endDate: map['end_date'] != null
          ? DateTime.parse(map['end_date'] as String)
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
      'icon': icon,
      'priority': priority?.value,
      'repeat_days': repeatDays.isNotEmpty ? jsonEncode(repeatDays) : null,
      'interval_days': intervalDays,
      'scheduled_time': scheduledTime,
      'end_date': endDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  RecordModel copyWith({
    String? id,
    RecordType? type,
    String? title,
    String? icon,
    Priority? priority,
    List<String>? repeatDays,
    int? intervalDays,
    String? scheduledTime,
    DateTime? endDate,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return RecordModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      priority: priority ?? this.priority,
      repeatDays: repeatDays ?? this.repeatDays,
      intervalDays: intervalDays ?? this.intervalDays,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

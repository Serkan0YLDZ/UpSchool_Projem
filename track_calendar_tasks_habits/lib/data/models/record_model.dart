import 'dart:convert';

enum RecordType {
  event,
  habit,
  todo;

  String get value => name;

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

enum Priority {
  low,
  medium,
  high;

  String get value => name;

  static Priority fromValue(String value) {
    return Priority.values.firstWhere((e) => e.name == value);
  }
}

extension PriorityX on Priority {
  bool get isHigh => this == Priority.high;
  bool get isMedium => this == Priority.medium;
  bool get isLow => this == Priority.low;
}

class RecordModel {
  final String id;
  final RecordType type;
  final String title;
  final String? description;
  final String? icon;
  final int? iconColor;
  final Priority? priority;
  final List<String> repeatDays;
  final int? intervalDays;
  final int targetProgress;
  final String? targetUnit;
  final String? scheduledDate;
  final String? scheduledTime;
  final String? endDate;
  final String? endTime;
  final DateTime? dueDate;
  final DateTime createdAt;
  final bool isActive;
  final int updatedAtMs;

  const RecordModel({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.icon,
    this.iconColor,
    this.priority,
    this.repeatDays = const [],
    this.intervalDays,
    this.targetProgress = 100,
    this.targetUnit,
    this.scheduledDate,
    this.scheduledTime,
    this.endDate,
    this.endTime,
    this.dueDate,
    required this.createdAt,
    this.isActive = true,
    this.updatedAtMs = 0,
  });

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
      targetUnit: map['target_unit'] as String?,
      scheduledDate: map['scheduled_date'] as String?,
      scheduledTime: map['scheduled_time'] as String?,
      endDate: map['end_date'] as String?,
      endTime: map['end_time'] as String?,
      dueDate: map['due_date'] != null
          ? DateTime.tryParse(map['due_date'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      isActive: (map['is_active'] as int) == 1,
      updatedAtMs: map['updated_at_ms'] as int? ?? 0,
    );
  }

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
      'target_unit': targetUnit,
      'scheduled_date': scheduledDate,
      'scheduled_time': scheduledTime,
      'end_date': endDate,
      'end_time': endTime,
      'due_date': dueDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'updated_at_ms': updatedAtMs,
    };
  }

  RecordModel copyWith({
    String? id,
    RecordType? type,
    String? title,
    String? description,
    String? icon,
    int? iconColor,
    bool clearIconColor = false,
    Priority? priority,
    List<String>? repeatDays,
    int? intervalDays,
    int? targetProgress,
    String? targetUnit,
    String? scheduledDate,
    String? scheduledTime,
    String? endDate,
    String? endTime,
    DateTime? dueDate,
    DateTime? createdAt,
    bool? isActive,
    int? updatedAtMs,
  }) {
    return RecordModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      iconColor: clearIconColor ? null : (iconColor ?? this.iconColor),
      priority: priority ?? this.priority,
      repeatDays: repeatDays ?? this.repeatDays,
      intervalDays: intervalDays ?? this.intervalDays,
      targetProgress: targetProgress ?? this.targetProgress,
      targetUnit: targetUnit ?? this.targetUnit,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      endDate: endDate ?? this.endDate,
      endTime: endTime ?? this.endTime,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    );
  }
}

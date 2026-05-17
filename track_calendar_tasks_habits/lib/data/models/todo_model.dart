/// Görev önceliği.
enum TodoPriority {
  high,
  medium,
  low;

  String get value => name;

  static TodoPriority fromValue(String value) =>
      TodoPriority.values.firstWhere(
        (e) => e.name == value,
        orElse: () => TodoPriority.medium,
      );
}

/// Yapılacak görev veri modeli.
///
/// [description] alanı UI'da da desteklenir (todo formu).
/// [isCompleted] true olduğunda [completedAt] dolu olmalıdır.
class TodoModel {
  const TodoModel({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = TodoPriority.medium,
    this.isCompleted = false,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.localRevision = 0,
  });

  final String id;
  final String title;
  final String? description;
  final String? dueDate;        // ISO8601 date
  final TodoPriority priority;
  final bool isCompleted;
  final String? completedAt;    // ISO8601 datetime
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final int localRevision;

  bool get isActive => deletedAt == null;

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      dueDate: map['due_date'] as String?,
      priority: TodoPriority.fromValue(map['priority'] as String? ?? 'medium'),
      isCompleted: (map['is_completed'] as int) == 1,
      completedAt: map['completed_at'] as String?,
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
        'due_date': dueDate,
        'priority': priority.value,
        'is_completed': isCompleted ? 1 : 0,
        'completed_at': completedAt,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'deleted_at': deletedAt,
        'local_revision': localRevision,
      };

  TodoModel copyWith({
    String? id,
    String? title,
    String? description,
    bool clearDescription = false,
    String? dueDate,
    bool clearDueDate = false,
    TodoPriority? priority,
    bool? isCompleted,
    String? completedAt,
    bool clearCompletedAt = false,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
    bool clearDeletedAt = false,
    int? localRevision,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      localRevision: localRevision ?? this.localRevision,
    );
  }
}

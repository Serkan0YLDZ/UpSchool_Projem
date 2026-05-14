enum CompletionStatus {
  done,
  skipped,
  partial;

  String get value => name;

  static CompletionStatus fromValue(String value) {
    return CompletionStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CompletionStatus.done,
    );
  }
}

extension CompletionStatusX on CompletionStatus {
  bool get isDone => this == CompletionStatus.done;
  bool get isSkipped => this == CompletionStatus.skipped;
  bool get isPartial => this == CompletionStatus.partial;
}

class CompletionModel {
  final String id;
  final String recordId;
  final String date;
  final CompletionStatus status;
  final int progress;
  final String? note;
  final int updatedAtMs;

  const CompletionModel({
    required this.id,
    required this.recordId,
    required this.date,
    required this.status,
    this.progress = 0,
    this.note,
    this.updatedAtMs = 0,
  });

  CompletionModel copyWith({
    String? id,
    String? recordId,
    String? date,
    CompletionStatus? status,
    int? progress,
    String? note,
    int? updatedAtMs,
  }) {
    return CompletionModel(
      id: id ?? this.id,
      recordId: recordId ?? this.recordId,
      date: date ?? this.date,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      note: note ?? this.note,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    );
  }
}

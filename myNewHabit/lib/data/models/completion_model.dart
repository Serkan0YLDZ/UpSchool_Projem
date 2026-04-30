// Sprint 4: Veri Katmanı — CompletionModel

/// Günlük tamamlama kaydının durumu.
enum CompletionStatus {
  done,
  skipped,
  partial; // Yeni eklendi (0-100 arası ilerlemeler için)

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

/// Bir kaydın belirli bir güne ait tamamlama verisi.
///
/// `completions` tablosuna karşılık gelir.
class CompletionModel {
  final String id;
  final String recordId;

  /// 'yyyy-MM-dd' formatında tarih
  final String date;

  final CompletionStatus status;

  /// Alışkanlıklar için 0-100 arası ilerleme yüzdesi (Sprint 4)
  final int progress;

  /// Opsiyonel kullanıcı notu (Sprint 4)
  final String? note;

  const CompletionModel({
    required this.id,
    required this.recordId,
    required this.date,
    required this.status,
    this.progress = 0,
    this.note,
  });

  factory CompletionModel.fromMap(Map<String, dynamic> map) {
    return CompletionModel(
      id: map['id'] as String,
      recordId: map['record_id'] as String,
      date: map['date'] as String,
      status: CompletionStatus.fromValue(map['status'] as String),
      progress: map['progress'] as int? ?? 0,
      note: map['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'record_id': recordId,
      'date': date,
      'status': status.value,
      'progress': progress,
      'note': note,
    };
  }
  
  CompletionModel copyWith({
    String? id,
    String? recordId,
    String? date,
    CompletionStatus? status,
    int? progress,
    String? note,
  }) {
    return CompletionModel(
      id: id ?? this.id,
      recordId: recordId ?? this.recordId,
      date: date ?? this.date,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      note: note ?? this.note,
    );
  }
}

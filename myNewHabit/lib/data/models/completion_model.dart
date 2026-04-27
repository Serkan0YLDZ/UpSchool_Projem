// Sprint 2: Veri Katmanı — CompletionModel

/// Günlük tamamlama kaydının durumu.
enum CompletionStatus {
  done,
  skipped,
  relapsed;

  String get value => name;

  static CompletionStatus fromValue(String value) {
    return CompletionStatus.values.firstWhere((e) => e.name == value);
  }
}

extension CompletionStatusX on CompletionStatus {
  bool get isDone => this == CompletionStatus.done;
  bool get isSkipped => this == CompletionStatus.skipped;
  bool get isRelapsed => this == CompletionStatus.relapsed;
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

  const CompletionModel({
    required this.id,
    required this.recordId,
    required this.date,
    required this.status,
  });

  factory CompletionModel.fromMap(Map<String, dynamic> map) {
    return CompletionModel(
      id: map['id'] as String,
      recordId: map['record_id'] as String,
      date: map['date'] as String,
      status: CompletionStatus.fromValue(map['status'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'record_id': recordId,
      'date': date,
      'status': status.value,
    };
  }
}

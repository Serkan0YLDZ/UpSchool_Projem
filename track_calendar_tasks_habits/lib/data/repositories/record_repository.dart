import '../models/record_model.dart';

/// Kayıt CRUD işlemleri için sözleşme.
abstract class RecordRepository {
  Future<List<RecordModel>> getAll();
  Future<List<RecordModel>> getByDate(String date);
  Future<void> create(RecordModel record);
  Future<void> update(RecordModel record);
  Future<void> delete(String id);
  Future<RecordModel?> getById(String id);
}

/// In-memory mock implementasyon — gerçek bir veritabanına ihtiyaç duymaz.
class MockRecordRepository implements RecordRepository {
  final List<RecordModel> _records = _initialMockData();

  @override
  Future<List<RecordModel>> getAll() async => List.unmodifiable(_records);

  @override
  Future<List<RecordModel>> getByDate(String date) async {
    final dayAbbr = _dayAbbreviation(date);
    return _records.where((r) {
      if (!r.isActive) return false;
      if (r.type == RecordType.todo) return true;
      if (r.type == RecordType.habit) {
        if (r.intervalDays != null) {
          final target = DateTime.parse(date);
          final start = DateTime(r.createdAt.year, r.createdAt.month, r.createdAt.day);
          final diff = target.difference(start).inDays;
          if (diff < 0) return false;
          return diff % r.intervalDays! == 0;
        }
        return r.repeatDays.isEmpty || r.repeatDays.contains(dayAbbr);
      }
      if (r.type == RecordType.event) {
        if (r.scheduledDate == null) return false;
        final targetDate = DateTime.parse(date);
        final startDate = DateTime.parse(r.scheduledDate!);
        final end = r.endDate != null ? DateTime.parse(r.endDate!) : startDate;
        return !targetDate.isBefore(startDate) && !targetDate.isAfter(end);
      }
      return false;
    }).toList();
  }

  @override
  Future<void> create(RecordModel record) async {
    _records.add(record);
    // Yeni alışkanlıklar için streak satırı MockStreakRepository tarafından yönetilir.
  }

  @override
  Future<void> update(RecordModel record) async {
    final idx = _records.indexWhere((r) => r.id == record.id);
    if (idx != -1) _records[idx] = record;
  }

  @override
  Future<void> delete(String id) async {
    _records.removeWhere((r) => r.id == id);
  }

  @override
  Future<RecordModel?> getById(String id) async {
    try {
      return _records.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  static String _dayAbbreviation(String date) {
    const abbrs = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return abbrs[DateTime.parse(date).weekday - 1];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Başlangıç mock verileri

List<RecordModel> _initialMockData() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

  return [
    // ── Alışkanlıklar ──────────────────────────────────────────────────────
    RecordModel(
      id: 'habit-1',
      type: RecordType.habit,
      title: 'Sabah Koşusu',
      repeatDays: const ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'],
      targetProgress: 100,
      priority: Priority.high,
      createdAt: today.subtract(const Duration(days: 14)),
    ),
    RecordModel(
      id: 'habit-2',
      type: RecordType.habit,
      title: 'Su İç (2L)',
      targetUnit: 'lt',
      targetProgress: 100,
      repeatDays: const ['MON', 'TUE', 'WED', 'THU', 'FRI'],
      priority: Priority.medium,
      createdAt: today.subtract(const Duration(days: 10)),
    ),
    RecordModel(
      id: 'habit-3',
      type: RecordType.habit,
      title: 'Kitap Oku',
      repeatDays: const ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'],
      targetProgress: 100,
      priority: Priority.low,
      createdAt: today.subtract(const Duration(days: 20)),
    ),
    RecordModel(
      id: 'habit-4',
      type: RecordType.habit,
      title: 'Meditasyon',
      repeatDays: const ['MON', 'WED', 'FRI', 'SUN'],
      targetProgress: 100,
      priority: Priority.medium,
      createdAt: today.subtract(const Duration(days: 7)),
    ),

    // ── Yapılacaklar ────────────────────────────────────────────────────────
    RecordModel(
      id: 'todo-1',
      type: RecordType.todo,
      title: 'Proje Raporu Hazırla',
      priority: Priority.high,
      dueDate: today,
      createdAt: today.subtract(const Duration(days: 2)),
    ),
    RecordModel(
      id: 'todo-2',
      type: RecordType.todo,
      title: 'Market Alışverişi',
      priority: Priority.medium,
      dueDate: today.add(const Duration(days: 1)),
      createdAt: today.subtract(const Duration(days: 1)),
    ),
    RecordModel(
      id: 'todo-3',
      type: RecordType.todo,
      title: 'Diş Hekimi Randevusu',
      priority: Priority.low,
      dueDate: today.add(const Duration(days: 3)),
      createdAt: today,
    ),

    // ── Takvim Etkinlikleri ─────────────────────────────────────────────────
    RecordModel(
      id: 'event-1',
      type: RecordType.event,
      title: 'Takım Toplantısı',
      scheduledDate: todayStr,
      scheduledTime: '10:00',
      createdAt: today.subtract(const Duration(days: 3)),
    ),
    RecordModel(
      id: 'event-2',
      type: RecordType.event,
      title: 'Spor Salonu',
      scheduledDate: todayStr,
      scheduledTime: '18:30',
      createdAt: today.subtract(const Duration(days: 1)),
    ),
  ];
}

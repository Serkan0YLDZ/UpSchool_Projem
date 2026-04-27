// Sprint 2: Veri Katmanı — RecordRepository (abstract + sqflite impl)

import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/record_model.dart';

/// Kayıt CRUD işlemleri için sözleşme (OCP: impl swap edilebilir).
abstract class RecordRepository {
  /// Tüm aktif kayıtları getirir.
  Future<List<RecordModel>> getAll();

  /// Belirli bir tarihe ait kayıtları getirir.
  ///
  /// Alışkanlıklar: `repeat_days` içinde o günün kısaltması varsa dahil edilir.
  /// Görevler: `end_date` null veya >= [date] ise dahil edilir.
  /// Kötü alışkanlıklar: her zaman dahil edilir.
  Future<List<RecordModel>> getByDate(String date);

  /// Yeni kayıt oluşturur. [record.id] çağıran tarafça üretilmeli.
  Future<void> create(RecordModel record);

  /// Mevcut kaydı günceller.
  Future<void> update(RecordModel record);

  /// Kaydı siler. Cascade ile ilgili completion ve streak kayıtları da silinir.
  Future<void> delete(String id);

  /// Tek bir kaydı ID ile getirir; bulunamazsa null döner.
  Future<RecordModel?> getById(String id);
}

/// sqflite tabanlı [RecordRepository] implementasyonu.
class SqfliteRecordRepository implements RecordRepository {
  final DatabaseHelper _dbHelper;

  SqfliteRecordRepository(this._dbHelper);

  @override
  Future<List<RecordModel>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'records',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'created_at ASC',
    );
    return maps.map(RecordModel.fromMap).toList();
  }

  @override
  Future<List<RecordModel>> getByDate(String date) async {
    final all = await getAll();
    final dayAbbr = _dayAbbreviation(date);

    return all.where((r) {
      if (r.type == RecordType.quit) return true;
      if (r.type == RecordType.habit) {
        // X günde bir mantığı:
        if (r.intervalDays != null) {
          final target = DateTime.parse(date);
          final start = DateTime(
            r.createdAt.year,
            r.createdAt.month,
            r.createdAt.day,
          );
          final diff = target.difference(start).inDays;
          // Eğer gün geçmişteyse veya interval'a tam bölünmüyorsa gösterme
          if (diff < 0) return false;
          return diff % r.intervalDays! == 0;
        }

        // Gün seçimi yoksa her gün göster
        return r.repeatDays.isEmpty || r.repeatDays.contains(dayAbbr);
      }
      // task: bitiş tarihi yoksa veya henüz geçmediyse göster
      if (r.endDate == null) return true;
      return !r.endDate!.isBefore(DateTime.parse(date));
    }).toList();
  }

  @override
  Future<void> create(RecordModel record) async {
    final db = await _dbHelper.database;
    await db.insert(
      'records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> update(RecordModel record) async {
    final db = await _dbHelper.database;
    await db.update(
      'records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    // FK CASCADE açık olduğu için completions ve streaks otomatik silinir.
    await db.delete('records', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<RecordModel?> getById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'records',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return RecordModel.fromMap(maps.first);
  }

  /// 'yyyy-MM-dd' tarihinden haftanın kısaltmasını üretir.
  /// Örn: Pazartesi → 'MON', Salı → 'TUE' …
  String _dayAbbreviation(String date) {
    const abbrs = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final weekday = DateTime.parse(date).weekday; // 1=Mon … 7=Sun
    return abbrs[weekday - 1];
  }
}



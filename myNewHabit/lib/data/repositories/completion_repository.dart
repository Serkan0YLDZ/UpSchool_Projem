// Sprint 2: Veri Katmanı — CompletionRepository (abstract + sqflite impl)

import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/completion_model.dart';

/// Günlük tamamlama işlemleri için sözleşme.
abstract class CompletionRepository {
  /// Belirli bir tarihe ait tüm completion kayıtlarını getirir.
  Future<List<CompletionModel>> getByDate(String date);

  /// Belirli bir kayda ait tüm completion'ları getirir (streak hesabı için).
  Future<List<CompletionModel>> getByRecordId(String recordId);

  /// Belirli bir kayıt + tarih kombinasyonu için completion getirir.
  Future<CompletionModel?> getForRecordAndDate(String recordId, String date);

  /// Alışkanlığı tamamlandı olarak işaretler.
  Future<void> markDone(
    String id,
    String recordId,
    String date, {
    int progress = 100,
  });

  /// Alışkanlığı es geçildi olarak işaretler.
  Future<void> markSkipped(String id, String recordId, String date);

  /// Alışkanlığı kısmi olarak ilerletir.
  Future<void> markPartial(
    String id,
    String recordId,
    String date,
    int progress,
  );

  /// Bir completion kaydını siler (tamamlamayı geri al).
  Future<void> delete(String id);
}

/// sqflite tabanlı [CompletionRepository] implementasyonu.
class SqfliteCompletionRepository implements CompletionRepository {
  final DatabaseHelper _dbHelper;

  SqfliteCompletionRepository(this._dbHelper);

  @override
  Future<List<CompletionModel>> getByDate(String date) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'completions',
      where: 'date = ?',
      whereArgs: [date],
    );
    return maps.map(CompletionModel.fromMap).toList();
  }

  @override
  Future<List<CompletionModel>> getByRecordId(String recordId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'completions',
      where: 'record_id = ?',
      whereArgs: [recordId],
      orderBy: 'date ASC',
    );
    return maps.map(CompletionModel.fromMap).toList();
  }

  @override
  Future<CompletionModel?> getForRecordAndDate(
    String recordId,
    String date,
  ) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'completions',
      where: 'record_id = ? AND date = ?',
      whereArgs: [recordId, date],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return CompletionModel.fromMap(maps.first);
  }

  @override
  Future<void> markDone(
    String id,
    String recordId,
    String date, {
    int progress = 100,
  }) async {
    await _upsert(
      id,
      recordId,
      date,
      CompletionStatus.done,
      progress: progress,
    );
  }

  @override
  Future<void> markSkipped(String id, String recordId, String date) async {
    await _upsert(id, recordId, date, CompletionStatus.skipped, progress: 0);
  }

  @override
  Future<void> markPartial(
    String id,
    String recordId,
    String date,
    int progress,
  ) async {
    await _upsert(
      id,
      recordId,
      date,
      CompletionStatus.partial,
      progress: progress,
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('completions', where: 'id = ?', whereArgs: [id]);
  }

  /// Aynı gün için tekrar kayıt oluşturmak yerine günceller (REPLACE).
  Future<void> _upsert(
    String id,
    String recordId,
    String date,
    CompletionStatus status, {
    int progress = 0,
  }) async {
    final db = await _dbHelper.database;
    final model = CompletionModel(
      id: id,
      recordId: recordId,
      date: date,
      status: status,
      progress: progress,
    );
    await db.insert(
      'completions',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

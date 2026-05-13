// Sprint 6: Seri verisi — StreakRepository

import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/streak_model.dart';

abstract class StreakRepository {
  Future<StreakModel?> getByRecordId(String recordId);

  Future<Map<String, StreakModel>> getByRecordIds(List<String> recordIds);

  /// Tüm streak satırları (bulut senkron).
  Future<List<StreakModel>> getAll();

  /// Bulut senkronu: REPLACE; `markSyncDirty` tetiklenmez.
  Future<void> applyRemoteStreak(StreakModel model);

  Future<void> upsert(StreakModel model);

  /// Sert kapanışı kaldırır (yeniden seri başlat).
  Future<void> clearSeriesClosure(String recordId);

  /// Kurtarma günü için kullanıcı aksiyonu (seriyi geri getir).
  Future<void> setRecoveryApplied(String recordId);

  /// İlk yüklemede satır yoksa oluşturur.
  Future<StreakModel> getOrCreate(String recordId);
}

class SqfliteStreakRepository implements StreakRepository {
  SqfliteStreakRepository(this._dbHelper);

  final DatabaseHelper _dbHelper;

  @override
  Future<StreakModel?> getByRecordId(String recordId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'streaks',
      where: 'record_id = ?',
      whereArgs: [recordId],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return StreakModel.fromMap(maps.first);
  }

  @override
  Future<Map<String, StreakModel>> getByRecordIds(List<String> recordIds) async {
    if (recordIds.isEmpty) return {};
    final db = await _dbHelper.database;
    final placeholders = List.filled(recordIds.length, '?').join(',');
    final maps = await db.query(
      'streaks',
      where: 'record_id IN ($placeholders)',
      whereArgs: recordIds,
    );
    return {for (final m in maps) m['record_id'] as String: StreakModel.fromMap(m)};
  }

  @override
  Future<List<StreakModel>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query('streaks');
    return maps.map(StreakModel.fromMap).toList();
  }

  @override
  Future<void> applyRemoteStreak(StreakModel model) async {
    final db = await _dbHelper.database;
    await db.insert(
      'streaks',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> upsert(StreakModel model) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final row = model.copyWith(updatedAtMs: now).toMap();
    await db.insert(
      'streaks',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _dbHelper.markSyncDirty();
  }

  @override
  Future<void> clearSeriesClosure(String recordId) async {
    final db = await _dbHelper.database;
    await db.update(
      'streaks',
      {'series_closed_after': null},
      where: 'record_id = ?',
      whereArgs: [recordId],
    );
    await _dbHelper.markSyncDirty();
  }

  @override
  Future<void> setRecoveryApplied(String recordId) async {
    final db = await _dbHelper.database;
    await db.update(
      'streaks',
      {'recovery_applied': 1},
      where: 'record_id = ?',
      whereArgs: [recordId],
    );
    await _dbHelper.markSyncDirty();
  }

  @override
  Future<StreakModel> getOrCreate(String recordId) async {
    final existing = await getByRecordId(recordId);
    if (existing != null) return existing;
    final fresh = StreakModel(recordId: recordId);
    await upsert(fresh);
    return fresh;
  }
}

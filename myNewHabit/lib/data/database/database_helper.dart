// Sprint 2: Veri Katmanı — sqflite singleton ve migration sistemi

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/sync_meta_row.dart';

/// sqflite veritabanı bağlantısını yöneten singleton.
///
/// Her migration versiyonu bir `_migrate_vN` metoduyla ayrılır;
/// bu sayede ilerideki sprint'lerde yeni tablo/sütun eklemek güvendedir.
class DatabaseHelper {
  static const String _dbName = 'my_new_habit.db';
  static const int _dbVersion = 8;

  final String? _inMemoryPath;

  /// Uygulama genelinde kullanılan tek instance.
  static final DatabaseHelper instance = DatabaseHelper._internal();

  /// Test ortamı için her seferinde bağımsız bir in-memory DB oluşturur.
  ///
  /// sqflite'da ':memory:' path'i her açışta yeni, boş bir veritabanı verir;
  /// bu sayede testler birbirini etkilemez.
  factory DatabaseHelper.forTesting() =>
      DatabaseHelper._internal(inMemoryPath: inMemoryDatabasePath);

  DatabaseHelper._internal({String? inMemoryPath})
    : _inMemoryPath = inMemoryPath;

  Database? _db;

  /// Açık veritabanı bağlantısını döner; gerekirse ilk kez açar.
  Future<Database> get database async {
    _db ??= await _openDatabase();
    return _db!;
  }

  Future<Database> _openDatabase() async {
    final String path;
    if (_inMemoryPath != null) {
      // Test ortamı: her DatabaseHelper.forTesting() çağrısı ayrı DB verir.
      path = _inMemoryPath;
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, _dbName);
    }

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      // FK desteği Flutter/sqflite'da varsayılan kapalıdır; etkinleştiriyoruz.
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _migrateV1(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    for (var v = oldVersion + 1; v <= newVersion; v++) {
      if (v == 2) {
        await _migrateV2(db);
      } else if (v == 3) {
        await _migrateV3(db);
      } else if (v == 4) {
        await _migrateV4(db);
      } else if (v == 5) {
        await _migrateV5(db);
      } else if (v == 6) {
        await _migrateV6(db);
      } else if (v == 7) {
        await _migrateV7(db);
      } else if (v == 8) {
        await _migrateV8(db);
      }
    }
  }

  Future<bool> _columnExists(Database db, String table, String column) async {
    final rows = await db.rawQuery('PRAGMA table_info($table)');
    for (final r in rows) {
      if (r['name'] == column) return true;
    }
    return false;
  }

  /// Versiyon 2: interval_days sütunu eklendi.
  ///
  /// Sprint 2'de modele eklenen bu alan eski kurulumda yoktu;
  /// ALTER TABLE ile mevcut DB'ye ekliyoruz.
  Future<void> _migrateV2(Database db) async {
    if (!await _columnExists(db, 'records', 'interval_days')) {
      await db.execute('ALTER TABLE records ADD COLUMN interval_days INTEGER');
    }
  }

  /// Versiyon 3: Sprint 4 PRD revizyonu.
  ///
  /// - records: target_progress, scheduled_date, end_time, due_date, description eklendi.
  /// - completions: progress, note eklendi.
  /// - type 'task' olanlar 'event' yapıldı.
  /// - type 'quit' olanlar silindi.
  Future<void> _migrateV3(Database db) async {
    // records tablosuna yeni sütunlar ekle
    final newRecordColumns = [
      'target_progress INTEGER DEFAULT 100',
      'scheduled_date TEXT',
      'end_time TEXT',
      'due_date TEXT',
      'description TEXT',
    ];

    for (final col in newRecordColumns) {
      final name = col.split(' ').first;
      if (!await _columnExists(db, 'records', name)) {
        await db.execute('ALTER TABLE records ADD COLUMN $col');
      }
    }

    // completions tablosuna yeni sütunlar ekle
    final newCompletionColumns = ['progress INTEGER DEFAULT 0', 'note TEXT'];

    for (final col in newCompletionColumns) {
      final name = col.split(' ').first;
      if (!await _columnExists(db, 'completions', name)) {
        await db.execute('ALTER TABLE completions ADD COLUMN $col');
      }
    }

    // Mevcut 'task' tiplerini 'event' yap (PRD'ye göre artık Takvime Ekle = event)
    await db.rawUpdate("UPDATE records SET type = 'event' WHERE type = 'task'");

    // Mevcut 'quit' tiplerini ve onlara bağlı completion/streak verilerini sil (ON DELETE CASCADE)
    await db.rawDelete("DELETE FROM records WHERE type = 'quit'");
  }

  /// Versiyon 4: Sprint 5 PRD revizyonu.
  ///
  /// - records: end_date eklendi (çok günlü etkinlikler için).
  Future<void> _migrateV4(Database db) async {
    if (!await _columnExists(db, 'records', 'end_date')) {
      await db.execute('ALTER TABLE records ADD COLUMN end_date TEXT');
    }
  }

  /// Versiyon 5: Sprint 5 PRD revizyonu.
  ///
  /// - records: target_unit eklendi (örn: 'lt', 'km').
  Future<void> _migrateV5(Database db) async {
    if (!await _columnExists(db, 'records', 'target_unit')) {
      await db.execute('ALTER TABLE records ADD COLUMN target_unit TEXT');
    }
  }

  /// Versiyon 6: Sprint 6 — seri kurtarma ve sert kapanış.
  Future<void> _migrateV6(Database db) async {
    final cols = [
      'skip_consumed_week_key TEXT',
      'open_miss_date TEXT',
      'recovery_scheduled_date TEXT',
      'recovery_applied INTEGER NOT NULL DEFAULT 0',
      'streak_frozen_before_miss INTEGER',
      'series_closed_after TEXT',
    ];
    for (final col in cols) {
      final name = col.split(' ').first;
      if (!await _columnExists(db, 'streaks', name)) {
        await db.execute('ALTER TABLE streaks ADD COLUMN $col');
      }
    }
  }

  /// Versiyon 8: bulut senkron meta + LWW için `updated_at_ms`.
  Future<void> _migrateV8(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_meta (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        pending_sync INTEGER NOT NULL DEFAULT 0,
        last_local_mutation_ms INTEGER,
        last_successful_cloud_sync_ms INTEGER
      )
    ''');
    await db.rawInsert(
      'INSERT OR IGNORE INTO sync_meta (id, pending_sync) VALUES (1, 0)',
    );

    if (!await _columnExists(db, 'records', 'updated_at_ms')) {
      await db.execute(
        'ALTER TABLE records ADD COLUMN updated_at_ms INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (!await _columnExists(db, 'completions', 'updated_at_ms')) {
      await db.execute(
        'ALTER TABLE completions ADD COLUMN updated_at_ms INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (!await _columnExists(db, 'streaks', 'updated_at_ms')) {
      await db.execute(
        'ALTER TABLE streaks ADD COLUMN updated_at_ms INTEGER NOT NULL DEFAULT 0',
      );
    }

    await db.rawUpdate('''
      UPDATE records
      SET updated_at_ms = CAST(strftime('%s', datetime(substr(created_at, 1, 19))) AS INTEGER) * 1000
      WHERE updated_at_ms = 0
    ''');
    await db.rawUpdate('''
      UPDATE completions
      SET updated_at_ms = CAST(strftime('%s', date || 'T12:00:00') AS INTEGER) * 1000
      WHERE updated_at_ms = 0
    ''');
  }

  /// Versiyon 7: completion başına (record_id, date) tek satır + tarih indeksi.
  Future<void> _migrateV7(Database db) async {
    await db.execute('''
      DELETE FROM completions
      WHERE rowid NOT IN (
        SELECT MAX(rowid) FROM completions GROUP BY record_id, date
      )
    ''');
    await db.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS ux_completions_record_date '
      'ON completions (record_id, date)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_completions_by_date ON completions (date)',
    );
  }

  /// Versiyon 1 şeması: records, completions, streaks tabloları.
  Future<void> _migrateV1(Database db) async {
    await db.execute('''
      CREATE TABLE records (
        id              TEXT PRIMARY KEY,
        type            TEXT NOT NULL,
        title           TEXT NOT NULL,
        description     TEXT,
        icon            TEXT,
        priority        TEXT,
        repeat_days     TEXT,
        interval_days   INTEGER,
        target_progress INTEGER DEFAULT 100,
        target_unit     TEXT,
        scheduled_date  TEXT,
        scheduled_time  TEXT,
        end_time        TEXT,
        end_date        TEXT,
        due_date        TEXT,
        created_at      TEXT NOT NULL,
        is_active       INTEGER NOT NULL DEFAULT 1,
        updated_at_ms   INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE completions (
        id         TEXT PRIMARY KEY,
        record_id  TEXT NOT NULL,
        date       TEXT NOT NULL,
        status     TEXT NOT NULL,
        progress   INTEGER DEFAULT 0,
        note       TEXT,
        updated_at_ms INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (record_id) REFERENCES records(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE streaks (
        record_id               TEXT PRIMARY KEY,
        current_streak          INTEGER NOT NULL DEFAULT 0,
        longest_streak          INTEGER NOT NULL DEFAULT 0,
        last_done_date          TEXT,
        skip_used_this_week     INTEGER NOT NULL DEFAULT 0,
        skip_consumed_week_key  TEXT,
        open_miss_date          TEXT,
        recovery_scheduled_date TEXT,
        recovery_applied        INTEGER NOT NULL DEFAULT 0,
        streak_frozen_before_miss INTEGER,
        series_closed_after     TEXT,
        updated_at_ms           INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (record_id) REFERENCES records(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_meta (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        pending_sync INTEGER NOT NULL DEFAULT 0,
        last_local_mutation_ms INTEGER,
        last_successful_cloud_sync_ms INTEGER
      )
    ''');
    await db.rawInsert(
      'INSERT OR IGNORE INTO sync_meta (id, pending_sync) VALUES (1, 0)',
    );

    // Tarih bazlı sorgular için index — getByDate performansını artırır.
    await db.execute(
      'CREATE INDEX idx_completions_date ON completions (record_id, date)',
    );
    await db.execute(
      'CREATE UNIQUE INDEX ux_completions_record_date '
      'ON completions (record_id, date)',
    );
    await db.execute(
      'CREATE INDEX idx_completions_by_date ON completions (date)',
    );
  }

  /// Bulutla hizalanması gerektiğini işaretler (yerel veri değişti veya giriş sonrası).
  Future<void> markSyncDirty() async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.rawUpdate(
      'UPDATE sync_meta SET pending_sync = 1, last_local_mutation_ms = ? '
      'WHERE id = 1',
      [now],
    );
  }

  /// Kayıt varsa senkron bekliyor olarak işaretler (misafir verisini hesaba taşıma).
  Future<void> markSyncDirtyIfHasRecords() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) AS c FROM records'),
    );
    if ((count ?? 0) > 0) {
      await markSyncDirty();
    }
  }

  /// Son başarılı tam senkron sonrası meta güncellemesi.
  Future<void> markSyncComplete() async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.rawUpdate(
      'UPDATE sync_meta SET pending_sync = 0, '
      'last_successful_cloud_sync_ms = ? WHERE id = 1',
      [now],
    );
  }

  Future<SyncMetaRow> readSyncMeta() async {
    final db = await database;
    final rows = await db.query('sync_meta', where: 'id = ?', whereArgs: [1]);
    if (rows.isEmpty) {
      return const SyncMetaRow(pendingSync: false);
    }
    final m = rows.first;
    return SyncMetaRow(
      pendingSync: (m['pending_sync'] as int? ?? 0) == 1,
      lastLocalMutationMs: m['last_local_mutation_ms'] as int?,
      lastSuccessfulCloudSyncMs: m['last_successful_cloud_sync_ms'] as int?,
    );
  }

  /// Bağlantıyı kapatır ve sıfırlar; test tearDown'larında kullanılır.
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}

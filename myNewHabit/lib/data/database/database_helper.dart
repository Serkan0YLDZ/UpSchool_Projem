// Sprint 2: Veri Katmanı — sqflite singleton ve migration sistemi

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// sqflite veritabanı bağlantısını yöneten singleton.
///
/// Her migration versiyonu bir `_migrate_vN` metoduyla ayrılır;
/// bu sayede ilerideki sprint'lerde yeni tablo/sütun eklemek güvendedir.
class DatabaseHelper {
  static const String _dbName = 'my_new_habit.db';
  static const int _dbVersion = 3;

  final String? _inMemoryPath;

  /// Uygulama genelinde kullanılan tek instance.
  static final DatabaseHelper instance = DatabaseHelper._internal();

  /// Test ortamı için her seferinde bağımsız bir in-memory DB oluşturur.
  ///
  /// sqflite'da ':memory:' path'i her açışta yeni, boş bir veritabanı verir;
  /// bu sayede testler birbirini etkilemez.
  factory DatabaseHelper.forTesting() => DatabaseHelper._internal(
        inMemoryPath: inMemoryDatabasePath,
      );

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
      }
    }
  }

  /// Versiyon 2: interval_days sütunu eklendi.
  ///
  /// Sprint 2'de modele eklenen bu alan eski kurulumda yoktu;
  /// ALTER TABLE ile mevcut DB'ye ekliyoruz.
  Future<void> _migrateV2(Database db) async {
    // Sütun zaten varsa hata vermemek için try/catch kullan.
    try {
      await db.execute(
        'ALTER TABLE records ADD COLUMN interval_days INTEGER',
      );
    } catch (_) {
      // Sütun zaten mevcutsa görmezden gel.
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
      try {
        await db.execute('ALTER TABLE records ADD COLUMN $col');
      } catch (_) {}
    }

    // completions tablosuna yeni sütunlar ekle
    final newCompletionColumns = [
      'progress INTEGER DEFAULT 0',
      'note TEXT',
    ];

    for (final col in newCompletionColumns) {
      try {
        await db.execute('ALTER TABLE completions ADD COLUMN $col');
      } catch (_) {}
    }

    // Mevcut 'task' tiplerini 'event' yap (PRD'ye göre artık Takvime Ekle = event)
    await db.rawUpdate("UPDATE records SET type = 'event' WHERE type = 'task'");

    // Mevcut 'quit' tiplerini ve onlara bağlı completion/streak verilerini sil (ON DELETE CASCADE)
    await db.rawDelete("DELETE FROM records WHERE type = 'quit'");
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
        scheduled_date  TEXT,
        scheduled_time  TEXT,
        end_time        TEXT,
        due_date        TEXT,
        created_at      TEXT NOT NULL,
        is_active       INTEGER NOT NULL DEFAULT 1
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
        FOREIGN KEY (record_id) REFERENCES records(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE streaks (
        record_id           TEXT PRIMARY KEY,
        current_streak      INTEGER NOT NULL DEFAULT 0,
        longest_streak      INTEGER NOT NULL DEFAULT 0,
        last_done_date      TEXT,
        skip_used_this_week INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (record_id) REFERENCES records(id) ON DELETE CASCADE
      )
    ''');

    // Tarih bazlı sorgular için index — getByDate performansını artırır.
    await db.execute(
      'CREATE INDEX idx_completions_date ON completions (record_id, date)',
    );
  }

  /// Bağlantıyı kapatır ve sıfırlar; test tearDown'larında kullanılır.
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}


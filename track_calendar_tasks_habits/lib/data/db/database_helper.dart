import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:track_calendar_tasks_habits/data/db/table_constants.dart';

/// SQLite veritabanı bağlantısını yöneten singleton sınıf.
///
/// Tek sorumluluğu: DB dosyasını aç, şemayı oluştur ve migration'ları yönet.
/// İş mantığı veya CRUD işlemi içermez.
class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const int _kDbVersion = 2;
  static const String _kDbName = 'track_habits.db';

  Database? _db;

  /// Açık olan (veya ilk çağrıda açılan) DB instance'ını döner.
  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final dbPath = join(await getDatabasesPath(), _kDbName);
    return openDatabase(
      dbPath,
      version: _kDbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();
    batch.execute(TableConstants.createCalendarEvents);
    batch.execute(TableConstants.createHabits);
    batch.execute(TableConstants.createTodos);
    batch.execute(TableConstants.createHabitDayLogs);
    batch.execute(TableConstants.createStreakSnapshots);
    await batch.commit(noResult: true);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE ${TableConstants.habits} ADD COLUMN target_unit TEXT',
      );
    }
  }

  /// Yalnızca test ortamında kullanılır — açık DB bağlantısını kapatır.
  Future<void> closeForTest() async {
    await _db?.close();
    _db = null;
  }
}

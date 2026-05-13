import 'package:flutter_test/flutter_test.dart';
import 'package:my_new_habit/data/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('markSyncDirty should set pending and mutation time', () async {
    final db = DatabaseHelper.forTesting();
    await db.database;
    addTearDown(() async => db.close());

    await db.markSyncDirty();
    final row = await db.readSyncMeta();

    expect(row.pendingSync, isTrue);
    expect(row.lastLocalMutationMs, isNotNull);
  });

  test('markSyncComplete should clear pending and set cloud time', () async {
    final db = DatabaseHelper.forTesting();
    await db.database;
    addTearDown(() async => db.close());

    await db.markSyncDirty();
    await db.markSyncComplete();
    final row = await db.readSyncMeta();

    expect(row.pendingSync, isFalse);
    expect(row.lastSuccessfulCloudSyncMs, isNotNull);
    expect(row.hasEverSynced, isTrue);
  });
}

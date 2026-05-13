import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_new_habit/data/database/database_helper.dart';
import 'package:my_new_habit/data/services/cloud_sync_executor.dart';
import 'package:my_new_habit/providers/sync_status_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _RecordingExecutor implements CloudSyncExecutor {
  final List<String> uids = [];
  Completer<void>? blocker;

  @override
  Future<void> fullSync(String uid) async {
    uids.add(uid);
    await blocker?.future;
  }
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('syncNow should no-op when uid resolver returns null', () async {
    final db = DatabaseHelper.forTesting();
    await db.database;
    addTearDown(() async => db.close());

    final exec = _RecordingExecutor();
    final p = SyncStatusProvider(
      dbHelper: db,
      cloudSync: exec,
      currentSignedInUid: () => null,
    );
    addTearDown(p.dispose);

    await p.syncNow();
    expect(exec.uids, isEmpty);
  });

  test('syncNow should call fullSync then mark sync complete', () async {
    final db = DatabaseHelper.forTesting();
    await db.database;
    addTearDown(() async => db.close());

    final exec = _RecordingExecutor();
    final p = SyncStatusProvider(
      dbHelper: db,
      cloudSync: exec,
      currentSignedInUid: () => 'uid-42',
    );
    addTearDown(p.dispose);

    await db.markSyncDirty();
    await p.refresh();
    expect(p.meta.pendingSync, isTrue);

    await p.syncNow();

    expect(exec.uids, ['uid-42']);
    final row = await db.readSyncMeta();
    expect(row.pendingSync, isFalse);
    expect(row.hasEverSynced, isTrue);
  });

  test('syncNow should not start second run while busy', () async {
    final db = DatabaseHelper.forTesting();
    await db.database;
    addTearDown(() async => db.close());

    final exec = _RecordingExecutor()..blocker = Completer<void>();
    final p = SyncStatusProvider(
      dbHelper: db,
      cloudSync: exec,
      currentSignedInUid: () => 'u1',
    );
    addTearDown(p.dispose);

    final first = p.syncNow();
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await p.syncNow();
    expect(exec.uids.length, 1);

    exec.blocker!.complete();
    await first;
  });
}

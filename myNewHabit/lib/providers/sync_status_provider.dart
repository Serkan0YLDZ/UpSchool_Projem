// Sprint V2: Yerel `sync_meta` + manuel bulut senkronu durumu.

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';

import '../core/utils/debug_session_log.dart';

import '../data/database/database_helper.dart';
import '../data/models/sync_meta_row.dart';
import '../data/services/cloud_sync_executor.dart';

/// Profil ekranındaki senkron göstergesi ve bulut tam senkronunu tetikler.
class SyncStatusProvider extends ChangeNotifier {
  SyncStatusProvider({
    required DatabaseHelper dbHelper,
    required CloudSyncExecutor cloudSync,
    String? Function()? currentSignedInUid,
  })  : _db = dbHelper,
        _cloudSync = cloudSync,
        _currentSignedInUid = currentSignedInUid ??
            (() => fb.FirebaseAuth.instance.currentUser?.uid);

  final DatabaseHelper _db;
  final CloudSyncExecutor _cloudSync;
  final String? Function() _currentSignedInUid;

  SyncMetaRow _meta = const SyncMetaRow(pendingSync: false);
  bool _busy = false;
  bool _disposed = false;

  SyncMetaRow get meta => _meta;
  bool get isBusy => _busy;

  /// Son senkron biliniyor ve bekleyen yerel değişiklik yok.
  bool get isFullySynced =>
      !_meta.pendingSync && _meta.hasEverSynced;

  Future<void> refresh() async {
    final row = await _db.readSyncMeta();
    if (_disposed) return;
    _meta = row;
    notifyListeners();
  }

  Future<void> syncNow() async {
    if (_busy || _disposed) return;
    final uid = _currentSignedInUid();
    if (uid == null) {
      // #region agent log
      debugSessionLog(
        hypothesisId: 'H3',
        location: 'sync_status_provider.dart:syncNow',
        message: 'no_uid_skip',
        data: const {},
      );
      // #endregion
      return;
    }
    _busy = true;
    notifyListeners();
    try {
      await _cloudSync.fullSync(uid);
      if (_disposed) return;
      await _db.markSyncComplete();
      await refresh();
    } catch (e) {
      // #region agent log
      debugSessionLog(
        hypothesisId: 'H3',
        location: 'sync_status_provider.dart:syncNow',
        message: 'sync_now_fail',
        data: {
          'type': e.runtimeType.toString(),
          'error': e.toString(),
        },
      );
      // #endregion
      rethrow;
    } finally {
      if (!_disposed) {
        _busy = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

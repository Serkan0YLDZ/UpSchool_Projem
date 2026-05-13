// Sprint V2: Firestore ile SQLite arasında LWW (updated_at_ms / cloudUpdatedAt) senkronu.

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/utils/debug_session_log.dart';
import '../models/completion_model.dart';
import '../models/record_model.dart';
import '../models/streak_model.dart';
import '../repositories/completion_repository.dart';
import '../repositories/record_repository.dart';
import '../repositories/streak_repository.dart';
import 'cloud_sync_executor.dart';

/// `users/{uid}` altındaki kayıt ve alt belgeleri yönetir.
class CloudSyncService implements CloudSyncExecutor {
  CloudSyncService({
    required RecordRepository recordRepository,
    required CompletionRepository completionRepository,
    required StreakRepository streakRepository,
  })  : _records = recordRepository,
        _completions = completionRepository,
        _streaks = streakRepository;

  static const _streakDocId = 'main';

  final RecordRepository _records;
  final CompletionRepository _completions;
  final StreakRepository _streaks;

  CollectionReference<Map<String, dynamic>> _recordsRoot(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).collection('records');
  }

  int _cloudMs(Map<String, dynamic>? data) {
    if (data == null) return 0;
    final t = data['cloudUpdatedAt'];
    if (t is Timestamp) {
      return t.millisecondsSinceEpoch;
    }
    return 0;
  }

  Map<String, dynamic> _recordPayload(RecordModel r) {
    final m = Map<String, dynamic>.from(r.toMap());
    m['cloudUpdatedAt'] = Timestamp.fromMillisecondsSinceEpoch(r.updatedAtMs);
    return m;
  }

  Map<String, dynamic> _completionPayload(CompletionModel c) {
    final m = Map<String, dynamic>.from(c.toMap());
    m['cloudUpdatedAt'] = Timestamp.fromMillisecondsSinceEpoch(c.updatedAtMs);
    return m;
  }

  Map<String, dynamic> _streakPayload(StreakModel s) {
    final m = Map<String, dynamic>.from(s.toMap());
    m['cloudUpdatedAt'] = Timestamp.fromMillisecondsSinceEpoch(s.updatedAtMs);
    return m;
  }

  RecordModel _recordFromRemote(Map<String, dynamic> d) {
    final m = Map<String, dynamic>.from(d);
    m.remove('cloudUpdatedAt');
    final ms = _cloudMs(d);
    if (ms > 0) {
      m['updated_at_ms'] = ms;
    }
    return RecordModel.fromMap(m);
  }

  CompletionModel _completionFromRemote(Map<String, dynamic> d) {
    final m = Map<String, dynamic>.from(d);
    m.remove('cloudUpdatedAt');
    final ms = _cloudMs(d);
    if (ms > 0) {
      m['updated_at_ms'] = ms;
    }
    return CompletionModel.fromMap(m);
  }

  StreakModel _streakFromRemote(Map<String, dynamic> d) {
    final m = Map<String, dynamic>.from(d);
    m.remove('cloudUpdatedAt');
    final ms = _cloudMs(d);
    if (ms > 0) {
      m['updated_at_ms'] = ms;
    }
    return StreakModel.fromMap(m);
  }

  /// İki yönlü senkron: yerel ve bulut arasında son güncelleyen kazanır.
  @override
  Future<void> fullSync(String uid) async {
    // #region agent log
    debugSessionLog(
      hypothesisId: 'H3',
      location: 'cloud_sync_service.dart:fullSync',
      message: 'sync_start',
      data: {'uidLen': uid.length},
    );
    // #endregion
    try {
      final root = _recordsRoot(uid);
      var localRecords = await _records.getAllForSync();
    final remoteSnap = await root.get();
    final remoteById = {for (final d in remoteSnap.docs) d.id: d.data()};

    for (final local in localRecords) {
      final remote = remoteById[local.id];
      final remoteMs = _cloudMs(remote);
      if (remote == null || local.updatedAtMs >= remoteMs) {
        await root.doc(local.id).set(_recordPayload(local));
      } else {
        await _records.applyRemoteRecord(_recordFromRemote(remote));
      }
    }

    for (final entry in remoteById.entries) {
      if (!localRecords.any((r) => r.id == entry.key)) {
        await _records.applyRemoteRecord(_recordFromRemote(entry.value));
      }
    }

    localRecords = await _records.getAllForSync();
    final recordIds = localRecords.map((r) => r.id).toSet();

    final localsC = await _completions.getAll();
    for (final c in localsC) {
      if (!recordIds.contains(c.recordId)) continue;
      final doc = root.doc(c.recordId).collection('completions').doc(c.id);
      final snap = await doc.get();
      final remoteMs = _cloudMs(snap.data());
      if (!snap.exists || c.updatedAtMs >= remoteMs) {
        await doc.set(_completionPayload(c));
      } else {
        await _completions.applyRemoteCompletion(
          _completionFromRemote(snap.data()!),
        );
      }
    }

    final localIds = {for (final c in await _completions.getAll()) c.id};
    for (final rid in recordIds) {
      final snap = await root.doc(rid).collection('completions').get();
      for (final d in snap.docs) {
        if (!localIds.contains(d.id)) {
          await _completions.applyRemoteCompletion(
            _completionFromRemote(d.data()),
          );
        }
      }
    }

    final localStreaks = await _streaks.getAll();
    for (final s in localStreaks) {
      if (!recordIds.contains(s.recordId)) continue;
      final doc = root
          .doc(s.recordId)
          .collection('streak')
          .doc(_streakDocId);
      final snap = await doc.get();
      final remoteMs = _cloudMs(snap.data());
      if (!snap.exists || s.updatedAtMs >= remoteMs) {
        await doc.set(_streakPayload(s));
      } else {
        await _streaks.applyRemoteStreak(_streakFromRemote(snap.data()!));
      }
    }

    for (final rid in recordIds) {
      final doc = root.doc(rid).collection('streak').doc(_streakDocId);
      final snap = await doc.get();
      if (!snap.exists) continue;
      final local = await _streaks.getByRecordId(rid);
      if (local == null) {
        await _streaks.applyRemoteStreak(_streakFromRemote(snap.data()!));
      }
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('syncState')
        .doc('main')
        .set(
      {'lastFullSyncAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
    // #region agent log
    debugSessionLog(
      hypothesisId: 'H3',
      location: 'cloud_sync_service.dart:fullSync',
      message: 'sync_ok',
      data: const {},
    );
    // #endregion
    } catch (e) {
      // #region agent log
      debugSessionLog(
        hypothesisId: 'H3',
        location: 'cloud_sync_service.dart:fullSync',
        message: 'sync_fail',
        data: {
          'type': e.runtimeType.toString(),
          'error': e.toString(),
        },
      );
      // #endregion
      rethrow;
    }
  }
}

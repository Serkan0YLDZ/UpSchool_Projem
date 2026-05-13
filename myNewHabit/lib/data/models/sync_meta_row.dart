// Sprint V2: Yerel senkron durumu (Firestore ile eşleştirme için meta satırı).

/// `sync_meta` tablosundaki tek satırın okunmuş hali.
class SyncMetaRow {
  const SyncMetaRow({
    required this.pendingSync,
    this.lastLocalMutationMs,
    this.lastSuccessfulCloudSyncMs,
  });

  final bool pendingSync;
  final int? lastLocalMutationMs;
  final int? lastSuccessfulCloudSyncMs;

  bool get hasEverSynced => lastSuccessfulCloudSyncMs != null;
}

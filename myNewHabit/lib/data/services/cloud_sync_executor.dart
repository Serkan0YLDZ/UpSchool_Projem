// Sprint V2: Bulut tam senkronu — test ve DI için soyutlama.

/// [CloudSyncService] tarafından uygulanır; widget testlerinde fake ile değiştirilir.
abstract class CloudSyncExecutor {
  Future<void> fullSync(String uid);
}

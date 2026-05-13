/// `completions` satırı için kararlı birincil anahtar: kayıt + takvim günü başına tek satır.
abstract final class CompletionRowId {
  static String forRecordAndDate(String recordId, String ymd) =>
      '${recordId}_$ymd';
}
